import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/mixin/provide_common_posts_method_mixin.dart';
import 'package:kakikomi_keijiban/domain/post.dart';

class MyPostsModel extends ChangeNotifier with ProvideCommonPostsMethodMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Post> _myPosts = [];
  List<Post> get posts => _myPosts;

  Future<void> get getPostsWithReplies => _getMyPostsWithReplies();
  Future<void> get loadPostsWithReplies => _loadMyPostsWithReplies();

  QueryDocumentSnapshot? lastVisibleOfTheBatch;
  int loadLimit = 10;
  // bool isPostsExisting = false;
  bool canLoadMore = false;
  bool isLoading = false;
  bool isModalLoading = false;

  Future<void> init() async {
    startModalLoading();
    await _getMyPostsWithReplies();
    stopModalLoading();
  }

  Future<void> _getMyPostsWithReplies() async {
    startLoading();

    Query queryBatch = _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('posts')
        .orderBy('updatedAt', descending: true)
        .limit(loadLimit);
    final querySnapshot = await queryBatch.get();
    final docs = querySnapshot.docs;
    this._myPosts.clear();
    if (docs.length == 0) {
      // isPostsExisting = false;
      this.canLoadMore = false;
      this._myPosts = [];
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      this.canLoadMore = false;
      this.lastVisibleOfTheBatch = docs[docs.length - 1];
      this._myPosts = docs.map((doc) => Post(doc)).toList();
    } else {
      // isPostsExisting = true;
      this.canLoadMore = true;
      this.lastVisibleOfTheBatch = docs[docs.length - 1];
      this._myPosts = docs.map((doc) => Post(doc)).toList();
    }

    await addBookmark(this._myPosts);
    await addEmpathy(this._myPosts);
    await getReplies(this._myPosts);

    stopLoading();
    notifyListeners();
  }

  Future<void> _loadMyPostsWithReplies() async {
    startLoading();

    Query queryBatch = _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('posts')
        .orderBy('updatedAt', descending: true)
        .startAfterDocument(lastVisibleOfTheBatch!)
        .limit(loadLimit);
    final querySnapshot = await queryBatch.get();
    final docs = querySnapshot.docs;
    if (docs.length == 0) {
      // isPostsExisting = false;
      this.canLoadMore = false;
      this._myPosts += [];
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      this.canLoadMore = false;
      this.lastVisibleOfTheBatch = docs[docs.length - 1];
      this._myPosts += docs.map((doc) => Post(doc)).toList();
    } else {
      // isPostsExisting = true;
      this.canLoadMore = true;
      this.lastVisibleOfTheBatch = docs[docs.length - 1];
      this._myPosts += docs.map((doc) => Post(doc)).toList();
    }

    await addBookmark(this._myPosts);
    await addEmpathy(this._myPosts);
    await getReplies(this._myPosts);

    stopLoading();
    notifyListeners();
  }

  Future<void> refreshThePostOfPostsAfterUpdated({
    required Post oldPost,
    required int indexOfPost,
  }) async {
    await refreshThePostAfterUpdated(
      posts: this._myPosts,
      oldPost: oldPost,
      indexOfPost: indexOfPost,
    );

    notifyListeners();
  }

  void removeThePostOfPostsAfterDeleted(Post post) {
    this._myPosts.remove(post);
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
}
