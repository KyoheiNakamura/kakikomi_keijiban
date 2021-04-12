import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';
import 'package:kakikomi_keijiban/domain/reply_to_reply.dart';

class MyPostsModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser?.uid;

  List<Post> _myPosts = [];
  List<Post> get posts => _myPosts;

  Map<String, List<Reply>> _repliesToMyPosts = {};
  Map<String, List<Reply>> get replies => _repliesToMyPosts;

  List<Reply> _rawReplies = [];
  Map<String, List<ReplyToReply>> _repliesToReply = {};
  Map<String, List<ReplyToReply>> get repliesToReply => _repliesToReply;

  Future<void> get getPostsWithReplies => _getMyPostsWithReplies();
  Future<void> get loadPostsWithReplies => _loadMyPostsWithReplies();

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

  Future<void> _getMyPostsWithReplies() async {
    startLoading();

    Query queryBatch = _firestore
        .collection('users')
        .doc(uid)
        .collection('posts')
        .orderBy('updatedAt', descending: true)
        .limit(loadLimit);
    final querySnapshot = await queryBatch.get();
    final docs = querySnapshot.docs;
    _myPosts.clear();
    if (docs.length == 0) {
      // isPostsExisting = false;
      canLoadMore = false;
      _myPosts = [];
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      canLoadMore = false;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      _myPosts = docs.map((doc) => Post(doc)).toList();
    } else {
      // isPostsExisting = true;
      canLoadMore = true;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      _myPosts = docs.map((doc) => Post(doc)).toList();
    }
    await _addBookmarkToPosts();
    await _getRepliesToPosts();
    await _getRepliesToReplies();

    stopLoading();
    notifyListeners();
  }

  Future<void> _loadMyPostsWithReplies() async {
    startLoading();

    Query queryBatch = _firestore
        .collection('users')
        .doc(uid)
        .collection('posts')
        .orderBy('updatedAt', descending: true)
        .startAfterDocument(lastVisibleOfTheBatch!)
        .limit(loadLimit);
    final querySnapshot = await queryBatch.get();
    final docs = querySnapshot.docs;
    if (docs.length == 0) {
      // isPostsExisting = false;
      canLoadMore = false;
      _myPosts += [];
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      canLoadMore = false;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      _myPosts += docs.map((doc) => Post(doc)).toList();
    } else {
      // isPostsExisting = true;
      canLoadMore = true;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      _myPosts += docs.map((doc) => Post(doc)).toList();
    }
    await _addBookmarkToPosts();
    await _getRepliesToPosts();
    await _getRepliesToReplies();

    stopLoading();
    notifyListeners();
  }

  Future<void> _addBookmarkToPosts() async {
    final bookmarkedPostsSnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('bookmarkedPosts')
        .orderBy('createdAt', descending: true)
        .get();
    final postSnapshots = await Future.wait(bookmarkedPostsSnapshot.docs
        .map((bookmarkedPost) => _firestore
            .collectionGroup('posts')
            .where('id', isEqualTo: bookmarkedPost['postId'])
            // .orderBy('createdAt', descending: true)
            .get())
        .toList());
    final bookmarkedPostDocs =
        postSnapshots.map((postSnapshot) => postSnapshot.docs[0]).toList();

    for (int i = 0; i < _myPosts.length; i++) {
      for (QueryDocumentSnapshot bookmarkedPostDoc in bookmarkedPostDocs) {
        if (_myPosts[i].id == bookmarkedPostDoc.id) {
          _myPosts[i].isBookmarked = true;
        }
      }
    }
  }

  Future<void> _getRepliesToPosts() async {
    if (_myPosts.isNotEmpty) {
      for (final post in _myPosts) {
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
        _repliesToMyPosts[post.id] = replies;
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
