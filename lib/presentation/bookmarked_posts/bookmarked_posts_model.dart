import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';
import 'package:kakikomi_keijiban/common/mixin/provide_common_posts_method_mixin.dart';
import 'package:kakikomi_keijiban/domain/post.dart';

class BookmarkedPostsModel extends ChangeNotifier
    with ProvideCommonPostsMethodMixin {
  List<Post> _bookmarkedPosts = [];
  List<Post> get posts => _bookmarkedPosts;

  Future<void> get getPostsWithReplies => _getBookmarkedPostsWithReplies();
  Future<void> get loadPostsWithReplies => _loadBookmarkedPostsWithReplies();

  QueryDocumentSnapshot? lastVisibleOfTheBatch;
  int loadLimit = 8;
  // bool isPostsExisting = false;
  bool canLoadMore = false;
  bool isLoading = false;
  bool isModalLoading = false;

  Future<void> init() async {
    startModalLoading();
    await _getBookmarkedPostsWithReplies();
    stopModalLoading();
  }

  Future<void> _getBookmarkedPostsWithReplies() async {
    startModalLoading();

    Query queryBatch = firestore
        .collection('users')
        .doc(auth.currentUser?.uid)
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
      this._bookmarkedPosts = await getBookmarkedPosts(docs);
    } else {
      // isPostsExisting = true;
      this.canLoadMore = true;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      this._bookmarkedPosts = await getBookmarkedPosts(docs);
    }

    final empathizedPostsIds = await getEmpathizedPostsIds();

    await addEmpathy(this._bookmarkedPosts, empathizedPostsIds);
    await getReplies(this._bookmarkedPosts, empathizedPostsIds);

    stopModalLoading();
    notifyListeners();
  }

  Future<void> _loadBookmarkedPostsWithReplies() async {
    startLoading();

    Query queryBatch = firestore
        .collection('users')
        .doc(auth.currentUser?.uid)
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
      this._bookmarkedPosts += await getBookmarkedPosts(docs);
    } else {
      // isPostsExisting = true;
      this.canLoadMore = true;
      this.lastVisibleOfTheBatch = docs[docs.length - 1];
      this._bookmarkedPosts += await getBookmarkedPosts(docs);
    }

    final empathizedPostsIds = await getEmpathizedPostsIds();

    await addEmpathy(this._bookmarkedPosts, empathizedPostsIds);
    await getReplies(this._bookmarkedPosts, empathizedPostsIds);

    stopLoading();
    notifyListeners();
  }

  Future<void> refreshThePostOfPostsAfterUpdated({
    required Post oldPost,
    required int indexOfPost,
  }) async {
    await refreshThePostAfterUpdated(
      posts: this._bookmarkedPosts,
      oldPost: oldPost,
      indexOfPost: indexOfPost,
    );

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
}
