import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';
import 'package:kakikomi_keijiban/domain/reply_to_reply.dart';

class BookmarkedPostsModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  List<Post> _bookmarkedPosts = [];
  List<Post> get posts => _bookmarkedPosts;

  Map<String, List<Reply>> _repliesToBookmarkedPosts = {};
  Map<String, List<Reply>> get replies => _repliesToBookmarkedPosts;

  List<Reply> _rawReplies = [];
  Map<String, List<ReplyToReply>> _repliesToReply = {};
  Map<String, List<ReplyToReply>> get repliesToReply => _repliesToReply;

  Future<void> get getPostsWithReplies => _getBookmarkedPostsWithReplies();
  Future<void> get loadPostsWithReplies => _loadBookmarkedPostsWithReplies();

  QueryDocumentSnapshot? lastVisibleOfTheBatch;
  int loadLimit = 10;
  // bool isPostsExisting = false;
  bool canLoadMore = false;
  bool isLoading = false;

  void startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void stopLoading() {
    isLoading = false;
    notifyListeners();
  }

  Future<void> _getBookmarkedPostsWithReplies() async {
    startLoading();

    Query queryBatch = _firestore
        .collection('users')
        .doc(uid)
        .collection('bookmarkedPosts')
        .orderBy('createdAt', descending: true)
        .limit(loadLimit);
    final querySnapshot = await queryBatch.get();
    final docs = querySnapshot.docs;
    this._bookmarkedPosts.clear();
    this._rawReplies.clear();
    if (docs.length == 0) {
      // isPostsExisting = false;
      canLoadMore = false;
      _bookmarkedPosts = [];
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      canLoadMore = false;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      _bookmarkedPosts = await _getBookmarkedPosts(docs);
      _addBookmarkToPosts(_bookmarkedPosts);
    } else {
      // isPostsExisting = true;
      canLoadMore = true;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      _bookmarkedPosts = await _getBookmarkedPosts(docs);
      _addBookmarkToPosts(_bookmarkedPosts);
    }

    await _getRepliesToPosts();
    await _getRepliesToReplies();

    stopLoading();
    notifyListeners();
  }

  Future<void> _loadBookmarkedPostsWithReplies() async {
    startLoading();

    Query queryBatch = _firestore
        .collection('users')
        .doc(uid)
        .collection('bookmarkedPosts')
        .orderBy('createdAt', descending: true)
        .startAfterDocument(lastVisibleOfTheBatch!)
        .limit(loadLimit);
    final querySnapshot = await queryBatch.get();
    final docs = querySnapshot.docs;
    if (docs.length == 0) {
      // isPostsExisting = false;
      canLoadMore = false;
      _bookmarkedPosts += [];
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      canLoadMore = false;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      _bookmarkedPosts += await _getBookmarkedPosts(docs);
      _addBookmarkToPosts(_bookmarkedPosts);
    } else {
      // isPostsExisting = true;
      canLoadMore = true;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      _bookmarkedPosts += await _getBookmarkedPosts(docs);
      _addBookmarkToPosts(_bookmarkedPosts);
    }

    await _getRepliesToPosts();
    await _getRepliesToReplies();

    stopLoading();
    notifyListeners();
  }

  Future<List<Post>> _getBookmarkedPosts(
      List<QueryDocumentSnapshot> docs) async {
    final postSnapshots = await Future.wait(docs
        .map((bookmarkedPost) => _firestore
            .collectionGroup('posts')
            .where('id', isEqualTo: bookmarkedPost['postId'])
            // .orderBy('createdAt', descending: true)
            .get())
        .toList());
    final bookmarkedPostDocs =
        postSnapshots.map((postSnapshot) => postSnapshot.docs[0]).toList();
    return bookmarkedPostDocs.map((doc) => Post(doc)).toList();
  }

  void _addBookmarkToPosts(List<Post> bookmarkedPosts) {
    for (int i = 0; i < _bookmarkedPosts.length; i++) {
      _bookmarkedPosts[i].isBookmarked = true;
    }
  }

  Future<void> _getRepliesToPosts() async {
    if (_bookmarkedPosts.isNotEmpty) {
      for (final post in _bookmarkedPosts) {
        final querySnapshot = await _firestore
            .collection('users')
            .doc(post.uid)
            .collection('posts')
            .doc(post.id)
            .collection('replies')
            .orderBy('createdAt')
            .get();
        final docs = querySnapshot.docs;
        final replies = docs.map((doc) => Reply(doc)).toList();
        this._rawReplies += replies;
        _repliesToBookmarkedPosts[post.id] = replies;
      }
    }
  }

  Future<void> _getRepliesToReplies() async {
    if (_rawReplies.isNotEmpty) {
      for (final reply in _rawReplies) {
        final querySnapshot = await _firestore
            .collection('users')
            .doc(reply.uid)
            .collection('posts')
            .doc(reply.postId)
            .collection('replies')
            .doc(reply.id)
            .collection('repliesToReply')
            .orderBy('createdAt')
            .get();
        final docs = querySnapshot.docs;
        final repliesToReply = docs.map((doc) => ReplyToReply(doc)).toList();
        _repliesToReply[reply.id] = repliesToReply;
      }
    }
  }
}
