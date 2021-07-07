import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';
import 'package:kakikomi_keijiban/common/mixin/provide_common_posts_method_mixin.dart';
import 'package:kakikomi_keijiban/entity/post.dart';

class MyPostsModel extends ChangeNotifier with ProvideCommonPostsMethodMixin {
  List<Post> _myPosts = [];
  List<Post> get posts => _myPosts;

  Future<void> get getPostsWithReplies => _getMyPostsWithReplies();
  Future<void> get loadPostsWithReplies => _loadMyPostsWithReplies();

  QueryDocumentSnapshot? lastVisibleOfTheBatch;
  int loadLimit = 5;
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

    final queryBatch = firestore
        .collection('users')
        .doc(auth.currentUser?.uid)
        .collection('posts')
        .orderBy('updatedAt', descending: true)
        .limit(loadLimit);
    final querySnapshot = await queryBatch.get();
    final docs = querySnapshot.docs;
    _myPosts.clear();
    if (docs.isEmpty) {
      // isPostsExisting = false;
      canLoadMore = false;
      _myPosts = [];
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      canLoadMore = false;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      _myPosts = docs.map((doc) => Post.fromDoc(doc)).toList();
    } else {
      // isPostsExisting = true;
      canLoadMore = true;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      _myPosts = docs.map((doc) => Post.fromDoc(doc)).toList();
    }

    final bookmarkedPostsIds = await getBookmarkedPostsIds();
    final empathizedPostsIds = await getEmpathizedPostsIds();

    await addBookmark(_myPosts, bookmarkedPostsIds);
    await addEmpathy(_myPosts, empathizedPostsIds);
    await getReplies(_myPosts, empathizedPostsIds);

    stopLoading();
    notifyListeners();
  }

  Future<void> _loadMyPostsWithReplies() async {
    startLoading();

    final queryBatch = firestore
        .collection('users')
        .doc(auth.currentUser?.uid)
        .collection('posts')
        .orderBy('updatedAt', descending: true)
        .startAfterDocument(lastVisibleOfTheBatch!)
        .limit(loadLimit);
    final querySnapshot = await queryBatch.get();
    final docs = querySnapshot.docs;
    if (docs.isEmpty) {
      // isPostsExisting = false;
      canLoadMore = false;
      _myPosts += [];
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      canLoadMore = false;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      _myPosts += docs.map((doc) => Post.fromDoc(doc)).toList();
    } else {
      // isPostsExisting = true;
      canLoadMore = true;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      _myPosts += docs.map((doc) => Post.fromDoc(doc)).toList();
    }

    final bookmarkedPostsIds = await getBookmarkedPostsIds();
    final empathizedPostsIds = await getEmpathizedPostsIds();

    await addBookmark(_myPosts, bookmarkedPostsIds);
    await addEmpathy(_myPosts, empathizedPostsIds);
    await getReplies(_myPosts, empathizedPostsIds);

    stopLoading();
    notifyListeners();
  }

  Future<void> refreshThePostOfPostsAfterUpdated({
    required Post oldPost,
    required int indexOfPost,
  }) async {
    await refreshThePostAfterUpdated(
      posts: _myPosts,
      oldPost: oldPost,
      indexOfPost: indexOfPost,
    );

    notifyListeners();
  }

  void removeThePostOfPostsAfterDeleted(Post post) {
    _myPosts.remove(post);
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
