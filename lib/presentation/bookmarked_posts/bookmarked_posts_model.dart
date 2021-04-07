import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';

class BookmarkedPostsModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  List<Post> _bookmarkedPosts = [];
  List<Post> get posts => _bookmarkedPosts;

  Map<String, List<Reply>> _repliesToBookmarkedPosts = {};
  Map<String, List<Reply>> get replies => _repliesToBookmarkedPosts;

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
    _bookmarkedPosts = [];
    List<Post> posts;
    if (docs.length == 0) {
      // isPostsExisting = false;
      canLoadMore = false;
      posts = [];
      _bookmarkedPosts = posts;
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      canLoadMore = false;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      final postSnapshots = await Future.wait(docs
          .map((bookmarkedPost) => _firestore
              .collectionGroup('posts')
              .where('id', isEqualTo: bookmarkedPost['postId'])
              // .orderBy('createdAt', descending: true)
              .get())
          .toList());
      final bookmarkedPostDocs =
          postSnapshots.map((postSnapshot) => postSnapshot.docs[0]).toList();
      posts = bookmarkedPostDocs.map((doc) => Post(doc)).toList();
      _bookmarkedPosts = posts;
      for (int i = 0; i < _bookmarkedPosts.length; i++) {
        _bookmarkedPosts[i].isBookmarked = true;
      }
    } else {
      // isPostsExisting = true;
      canLoadMore = true;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      final postSnapshots = await Future.wait(docs
          .map((bookmarkedPost) => _firestore
              .collectionGroup('posts')
              .where('id', isEqualTo: bookmarkedPost['postId'])
              // .orderBy('createdAt', descending: true)
              .get())
          .toList());
      final bookmarkedPostDocs =
          postSnapshots.map((postSnapshot) => postSnapshot.docs[0]).toList();
      posts = bookmarkedPostDocs.map((doc) => Post(doc)).toList();
      _bookmarkedPosts = posts;
      for (int i = 0; i < _bookmarkedPosts.length; i++) {
        _bookmarkedPosts[i].isBookmarked = true;
      }
    }
    // await _addBookmarkToPosts();
    await _getRepliesToPosts();

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
    List<Post> posts;
    if (docs.length == 0) {
      // isPostsExisting = false;
      canLoadMore = false;
      posts = [];
      _bookmarkedPosts += posts;
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      canLoadMore = false;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      final postSnapshots = await Future.wait(docs
          .map((bookmarkedPost) => _firestore
              .collectionGroup('posts')
              .where('id', isEqualTo: bookmarkedPost['postId'])
              // .orderBy('createdAt', descending: true)
              .get())
          .toList());
      final bookmarkedPostDocs =
          postSnapshots.map((postSnapshot) => postSnapshot.docs[0]).toList();
      posts = bookmarkedPostDocs.map((doc) => Post(doc)).toList();
      _bookmarkedPosts += posts;
      for (int i = 0; i < _bookmarkedPosts.length; i++) {
        _bookmarkedPosts[i].isBookmarked = true;
      }
    } else {
      // isPostsExisting = true;
      canLoadMore = true;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      final postSnapshots = await Future.wait(docs
          .map((bookmarkedPost) => _firestore
              .collectionGroup('posts')
              .where('id', isEqualTo: bookmarkedPost['postId'])
              // .orderBy('createdAt', descending: true)
              .get())
          .toList());
      final bookmarkedPostDocs =
          postSnapshots.map((postSnapshot) => postSnapshot.docs[0]).toList();
      posts = bookmarkedPostDocs.map((doc) => Post(doc)).toList();
      _bookmarkedPosts += posts;
      for (int i = 0; i < _bookmarkedPosts.length; i++) {
        _bookmarkedPosts[i].isBookmarked = true;
      }
    }
    // await _addBookmarkToPosts();
    await _getRepliesToPosts();

    stopLoading();
    notifyListeners();
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
        _repliesToBookmarkedPosts[post.id] = replies;
      }
    }
  }

  // Future<void> _getBookmarkedPostsWithReplies() async {
  //   final bookmarkedPostsSnapshot = await _firestore
  //       .collection('users')
  //       .doc(uid)
  //       .collection('bookmarkedPosts')
  //       .orderBy('createdAt', descending: true)
  //       .get();
  //   final postSnapshots = await Future.wait(bookmarkedPostsSnapshot.docs
  //       .map((bookmarkedPost) => _firestore
  //       .collectionGroup('posts')
  //       .where('id', isEqualTo: bookmarkedPost['postId'])
  //   // .orderBy('createdAt', descending: true)
  //       .get())
  //       .toList());
  //   final bookmarkedPostDocs =
  //   postSnapshots.map((postSnapshot) => postSnapshot.docs[0]).toList();
  //   _bookmarkedPosts = bookmarkedPostDocs.map((doc) => Post(doc)).toList();
  //   for (int i = 0; i < _bookmarkedPosts.length; i++) {
  //     _bookmarkedPosts[i].isBookmarked = true;
  //   }
  //   for (final bookmarkedPost in _bookmarkedPosts) {
  //     // final querySnapshot = await _firestore
  //     //     .collectionGroup('replies')
  //     //     .where('postId', isEqualTo: bookmarkedPost.id)
  //     //     .orderBy('createdAt')
  //     //     .get();
  //     final querySnapshot = await _firestore
  //         .collection('users')
  //         .doc(bookmarkedPost.uid)
  //         .collection('posts')
  //         .doc(bookmarkedPost.id)
  //         .collection('replies')
  //         .orderBy('createdAt')
  //         .get();
  //     final docs = querySnapshot.docs;
  //     final replies = docs.map((doc) => Reply(doc)).toList();
  //     _repliesToBookmarkedPosts[bookmarkedPost.id] = replies;
  //   }
  //   notifyListeners();
  // }
}
