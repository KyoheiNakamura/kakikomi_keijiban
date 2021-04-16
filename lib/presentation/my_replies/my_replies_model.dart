import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';
import 'package:kakikomi_keijiban/domain/reply_to_reply.dart';

class MyRepliesModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser?.uid;

  List<Post> _postsWithMyReplies = [];
  List<Post> get posts => _postsWithMyReplies;

  Future<void> get getPostsWithReplies => _getPostsWithMyReplies();
  Future<void> get loadPostsWithReplies => _loadPostsWithMyReplies();

  QueryDocumentSnapshot? lastVisibleOfTheBatch;
  int loadLimit = 10;
  // bool isPostsExisting = false;
  bool canLoadMore = false;
  bool isLoading = false;
  bool isModalLoading = false;

  Future<void> _getPostsWithMyReplies() async {
    startLoading();

    Query queryBatch = _firestore
        .collectionGroup('replies')
        .where('replierId', isEqualTo: uid)
        .orderBy('updatedAt', descending: true)
        .limit(loadLimit);
    final querySnapshot = await queryBatch.get();
    final docs = querySnapshot.docs;
    this._postsWithMyReplies.clear();
    if (docs.length == 0) {
      // isPostsExisting = false;
      this.canLoadMore = false;
      this._postsWithMyReplies = [];
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      this.canLoadMore = false;
      this.lastVisibleOfTheBatch = docs[docs.length - 1];
      this._postsWithMyReplies = await _getRepliedPosts(docs);
    } else {
      // isPostsExisting = true;
      this.canLoadMore = true;
      this.lastVisibleOfTheBatch = docs[docs.length - 1];
      this._postsWithMyReplies = await _getRepliedPosts(docs);
    }
    await _addBookmarkToPosts();
    await _getReplies();

    stopLoading();
    notifyListeners();
  }

  Future<void> _loadPostsWithMyReplies() async {
    startLoading();

    Query queryBatch = _firestore
        .collectionGroup('replies')
        .where('replierId', isEqualTo: uid)
        .orderBy('updatedAt', descending: true)
        .startAfterDocument(lastVisibleOfTheBatch!)
        .limit(loadLimit);
    final querySnapshot = await queryBatch.get();
    final docs = querySnapshot.docs;
    if (docs.length == 0) {
      // isPostsExisting = false;
      this.canLoadMore = false;
      this._postsWithMyReplies += [];
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      this.canLoadMore = false;
      this.lastVisibleOfTheBatch = docs[docs.length - 1];
      this._postsWithMyReplies += await _getRepliedPosts(docs);
    } else {
      // isPostsExisting = true;
      this.canLoadMore = true;
      this.lastVisibleOfTheBatch = docs[docs.length - 1];
      this._postsWithMyReplies += await _getRepliedPosts(docs);
    }
    await _addBookmarkToPosts();
    await _getReplies();

    stopLoading();
    notifyListeners();
  }

  Future<List<Post>> _getRepliedPosts(List<QueryDocumentSnapshot> docs) async {
    final postSnapshots = await Future.wait(docs
        .map((repliedPost) => _firestore
            .collectionGroup('posts')
            .where('id', isEqualTo: repliedPost['postId'])
            .get())
        .toList());
    final repliedPostDocs =
        postSnapshots.map((postSnapshot) => postSnapshot.docs[0]).toList();
    return repliedPostDocs.map((doc) => Post(doc)).toList();
  }

  Future<void> _addBookmarkToPosts() async {
    final bookmarkedPostsSnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('bookmarkedPosts')
        // .orderBy('createdAt', descending: true)
        .get();
    final List<String> bookmarkedPostsIds = bookmarkedPostsSnapshot.docs
        .map((bookmarkedPost) => bookmarkedPost.id)
        .toList();
    for (int i = 0; i < posts.length; i++) {
      for (int n = 0; n < bookmarkedPostsIds.length; n++) {
        if (this._postsWithMyReplies[i].id == bookmarkedPostsIds[n]) {
          this._postsWithMyReplies[i].isBookmarked = true;
        }
      }
    }
  }

  Future<void> _getReplies() async {
    for (int i = 0; i < _postsWithMyReplies.length; i++) {
      final post = _postsWithMyReplies[i];
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

  Future<void> refreshThePostOfPostsAfterUpdated({
    required Post oldPost,
    required int indexOfPost,
  }) async {
    // 更新後のpostを取得
    final doc = await _firestore
        .collection('users')
        .doc(uid)
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
    this._postsWithMyReplies.removeAt(indexOfPost);
    // 更新後のpostをpostsに追加
    this._postsWithMyReplies.insert(indexOfPost, post);
    notifyListeners();
  }

  void removeThePostOfPostsAfterDeleted(Post post) {
    this._postsWithMyReplies.remove(post);
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
    await _getPostsWithMyReplies();
    stopModalLoading();
  }
}
