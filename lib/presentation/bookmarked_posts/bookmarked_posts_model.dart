import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';
import 'package:kakikomi_keijiban/domain/reply_to_reply.dart';

class BookmarkedPostsModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Post> _bookmarkedPosts = [];
  List<Post> get posts => _bookmarkedPosts;

  Future<void> get getPostsWithReplies => _getBookmarkedPostsWithReplies();
  Future<void> get loadPostsWithReplies => _loadBookmarkedPostsWithReplies();

  QueryDocumentSnapshot? lastVisibleOfTheBatch;
  int loadLimit = 10;
  // bool isPostsExisting = false;
  bool canLoadMore = false;
  bool isLoading = false;
  bool isModalLoading = false;

  Future<void> refreshThePostOfPostsAfterUpdated({
    required Post oldPost,
    required int indexOfPost,
  }) async {
    // 更新後のpostを取得
    final doc = await _firestore
        .collection('users')
        .doc(oldPost.userId)
        .collection('posts')
        .doc(oldPost.id)
        .get();
    final post = Post(doc);
    final querySnapshot = await _firestore
        .collection('users')
        .doc(post.userId)
        .collection('posts')
        .doc(post.id)
        .collection('replies')
        .orderBy('createdAt')
        .get();
    final docs = querySnapshot.docs;
    final _replies = docs.map((doc) => Reply(doc)).toList();
    post.replies = _replies;

    for (int i = 0; i < _replies.length; i++) {
      final reply = _replies[i];
      final _querySnapshot = await _firestore
          .collection('users')
          .doc(reply.userId)
          .collection('posts')
          .doc(reply.postId)
          .collection('replies')
          .doc(reply.id)
          .collection('repliesToReply')
          .orderBy('createdAt')
          .get();
      final _docs = _querySnapshot.docs;
      final _repliesToReplies = _docs.map((doc) => ReplyToReply(doc)).toList();
      reply.repliesToReply = _repliesToReplies;
    }
    // 更新前のpostをpostsから削除
    this._bookmarkedPosts.removeAt(indexOfPost);
    // 更新後のpostをpostsに追加
    this._bookmarkedPosts.insert(indexOfPost, post);
    notifyListeners();
  }

  void removeThePostOfPostsAfterDeleted(Post post) {
    this._bookmarkedPosts.remove(post);
    notifyListeners();
  }

  void startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void stopLoading() {
    isLoading = false;
    notifyListeners();
  }

  void startModalLoading() {
    isModalLoading = true;
    notifyListeners();
  }

  void stopModalLoading() {
    isModalLoading = false;
    notifyListeners();
  }

  Future<void> init() async {
    startModalLoading();
    await _getBookmarkedPostsWithReplies();
    stopModalLoading();
  }

  Future<void> _getBookmarkedPostsWithReplies() async {
    startModalLoading();

    Query queryBatch = _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('bookmarkedPosts')
        .orderBy('createdAt', descending: true)
        .limit(loadLimit);
    final querySnapshot = await queryBatch.get();
    final docs = querySnapshot.docs;
    this._bookmarkedPosts.clear();
    if (docs.length == 0) {
      // isPostsExisting = false;
      this.canLoadMore = false;
      this._bookmarkedPosts = [];
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      this.canLoadMore = false;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      this._bookmarkedPosts = await _getBookmarkedPosts(docs);
      _addBookmarkToPosts(this._bookmarkedPosts);
    } else {
      // isPostsExisting = true;
      this.canLoadMore = true;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      this._bookmarkedPosts = await _getBookmarkedPosts(docs);
      _addBookmarkToPosts(this._bookmarkedPosts);
    }

    await _getReplies();

    stopModalLoading();
    notifyListeners();
  }

  Future<void> _loadBookmarkedPostsWithReplies() async {
    startLoading();

    Query queryBatch = _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('bookmarkedPosts')
        .orderBy('createdAt', descending: true)
        .startAfterDocument(lastVisibleOfTheBatch!)
        .limit(loadLimit);
    final querySnapshot = await queryBatch.get();
    final docs = querySnapshot.docs;
    if (docs.length == 0) {
      // isPostsExisting = false;
      this.canLoadMore = false;
      this._bookmarkedPosts += [];
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      this.canLoadMore = false;
      this.lastVisibleOfTheBatch = docs[docs.length - 1];
      this._bookmarkedPosts += await _getBookmarkedPosts(docs);
      _addBookmarkToPosts(this._bookmarkedPosts);
    } else {
      // isPostsExisting = true;
      this.canLoadMore = true;
      this.lastVisibleOfTheBatch = docs[docs.length - 1];
      this._bookmarkedPosts += await _getBookmarkedPosts(docs);
      _addBookmarkToPosts(this._bookmarkedPosts);
    }

    await _getReplies();

    stopLoading();
    notifyListeners();
  }

  // Todo bookmarkedPosts/{bookmarkedPost_id}にbookmarkしたpostのidのみじゃなくて、中身を全部持たせる。
  Future<List<Post>> _getBookmarkedPosts(
      List<QueryDocumentSnapshot> docs) async {
    final postSnapshots = await Future.wait(docs
        .map((bookmarkedPost) => _firestore
            .collectionGroup('posts')
            .where('id', isEqualTo: bookmarkedPost['postId'])
            // .orderBy('createdAt', descending: true)
            .get())
        .toList());
    final bookmarkedPostDocs = postSnapshots.map((postSnapshot) {
      if (postSnapshot.docs.isNotEmpty) {
        return postSnapshot.docs[0];
      } else {
        return null;
      }
    }).toList();
    // bookmarkedPostDocsからnullを全て削除
    bookmarkedPostDocs.removeWhere((element) => element == null);
    final bookmarkedPosts =
        bookmarkedPostDocs.map((doc) => Post(doc!)).toList();
    return bookmarkedPosts;
  }

  void _addBookmarkToPosts(List<Post> bookmarkedPosts) {
    for (int i = 0; i < this._bookmarkedPosts.length; i++) {
      this._bookmarkedPosts[i].isBookmarked = true;
    }
  }

  Future<void> _getReplies() async {
    for (int i = 0; i < _bookmarkedPosts.length; i++) {
      final post = _bookmarkedPosts[i];
      final querySnapshot = await _firestore
          .collection('users')
          .doc(post.userId)
          .collection('posts')
          .doc(post.id)
          .collection('replies')
          .orderBy('createdAt')
          .get();
      final docs = querySnapshot.docs;
      final _replies = docs.map((doc) => Reply(doc)).toList();
      post.replies = _replies;

      for (int i = 0; i < _replies.length; i++) {
        final reply = _replies[i];
        final _querySnapshot = await _firestore
            .collection('users')
            .doc(reply.userId)
            .collection('posts')
            .doc(reply.postId)
            .collection('replies')
            .doc(reply.id)
            .collection('repliesToReply')
            .orderBy('createdAt')
            .get();
        final _docs = _querySnapshot.docs;
        final _repliesToReplies =
            _docs.map((doc) => ReplyToReply(doc)).toList();
        reply.repliesToReply = _repliesToReplies;
      }
    }
  }
}
