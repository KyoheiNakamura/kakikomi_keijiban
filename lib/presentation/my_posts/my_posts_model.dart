import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';

class MyPostsModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser?.uid;

  List<Post> _myPosts = [];
  List<Post> get posts => _myPosts;

  Map<String, List<Reply>> _repliesToMyPosts = {};
  Map<String, List<Reply>> get replies => _repliesToMyPosts;

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
        .orderBy('createdAt', descending: true)
        .limit(loadLimit);
    final querySnapshot = await queryBatch.get();
    final docs = querySnapshot.docs;
    _myPosts = [];
    List<Post> posts;
    if (docs.length == 0) {
      // isPostsExisting = false;
      canLoadMore = false;
      posts = [];
      _myPosts = posts;
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      canLoadMore = false;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      posts = docs.map((doc) => Post(doc)).toList();
      _myPosts = posts;
    } else {
      // isPostsExisting = true;
      canLoadMore = true;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      posts = docs.map((doc) => Post(doc)).toList();
      _myPosts = posts;
    }
    await _addBookmarkToPosts();
    await _getRepliesToPosts();

    stopLoading();
    notifyListeners();
  }

  Future<void> _loadMyPostsWithReplies() async {
    startLoading();

    Query queryBatch = _firestore
        .collection('users')
        .doc(uid)
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .startAfterDocument(lastVisibleOfTheBatch!)
        .limit(loadLimit);
    final querySnapshot = await queryBatch.get();
    final docs = querySnapshot.docs;
    List<Post> posts;
    if (docs.length == 0) {
      // isPostsExisting = false;
      canLoadMore = false;
      posts = [];
      _myPosts += posts;
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      canLoadMore = false;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      posts = docs.map((doc) => Post(doc)).toList();
      _myPosts += posts;
    } else {
      // isPostsExisting = true;
      canLoadMore = true;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      posts = docs.map((doc) => Post(doc)).toList();
      _myPosts += posts;
    }
    await _addBookmarkToPosts();
    await _getRepliesToPosts();

    stopLoading();
    notifyListeners();
  }

  Future<void> _addBookmarkToPosts() async {
    List<Post> _bookmarkedPosts = [];
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
    _bookmarkedPosts = bookmarkedPostDocs.map((doc) => Post(doc)).toList();
    // postCardでブックマークアイコンの切り替えのために書いてる
    for (int i = 0; i < _bookmarkedPosts.length; i++) {
      _bookmarkedPosts[i].isBookmarked = true;
    }
    for (int i = 0; i < _myPosts.length; i++) {
      for (Post bookmarkedPost in _bookmarkedPosts) {
        if (_myPosts[i].id == bookmarkedPost.id) {
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

  // Future<void> _getMyPostsWithReplies() async {
  //   final querySnapshot = await _firestore
  //       .collection('users')
  //       .doc(uid)
  //       .collection('posts')
  //       .orderBy('createdAt', descending: true)
  //       .get();
  //   final docs = querySnapshot.docs;
  //   final posts = docs.map((doc) => Post(doc)).toList();
  //   _myPosts = posts;
  //   // ブックマークを付けてる
  //   await _getBookmarkedPosts();
  //   for (int i = 0; i < _myPosts.length; i++) {
  //     for (Post bookmarkedPost in _bookmarkedPosts) {
  //       if (_myPosts[i].id == bookmarkedPost.id) {
  //         _myPosts[i].isBookmarked = true;
  //       }
  //     }
  //   }
  //   for (final post in posts) {
  //     // final querySnapshot = await _firestore
  //     //     .collectionGroup('replies')
  //     //     .where('postId', isEqualTo: post.id)
  //     //     .orderBy('createdAt')
  //     //     .get();
  //     final querySnapshot = await _firestore
  //         .collection('users')
  //         .doc(post.uid)
  //         .collection('posts')
  //         .doc(post.id)
  //         .collection('replies')
  //         .orderBy('createdAt')
  //         .get();
  //     final docs = querySnapshot.docs;
  //     final replies = docs.map((doc) => Reply(doc)).toList();
  //     _repliesToMyPosts[post.id] = replies;
  //   }
  //   notifyListeners();
  // }
}
