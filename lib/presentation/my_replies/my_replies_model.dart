import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';
import 'package:kakikomi_keijiban/common/mixin/provide_common_posts_method_mixin.dart';
import 'package:kakikomi_keijiban/domain/post.dart';

class MyRepliesModel extends ChangeNotifier with ProvideCommonPostsMethodMixin {
  List<Post> _postsWithMyReplies = [];
  List<Post> get posts => _postsWithMyReplies;

  Future<void> get getPostsWithReplies => _getPostsWithMyReplies();
  Future<void> get loadPostsWithReplies => _loadPostsWithMyReplies();

  QueryDocumentSnapshot? lastVisibleOfTheBatch;
  int loadLimit = 5;
  // bool isPostsExisting = false;
  bool canLoadMore = false;
  bool isLoading = false;
  bool isModalLoading = false;

  Future<void> init() async {
    startModalLoading();
    await _getPostsWithMyReplies();
    stopModalLoading();
  }

  Future<void> _getPostsWithMyReplies() async {
    startLoading();

    final queryBatch = firestore
        .collectionGroup('replies')
        .where('replierId', isEqualTo: auth.currentUser?.uid)
        .orderBy('updatedAt', descending: true)
        .limit(loadLimit);
    final querySnapshot = await queryBatch.get();
    final docs = querySnapshot.docs;
    _postsWithMyReplies.clear();
    if (docs.length == 0) {
      // isPostsExisting = false;
      canLoadMore = false;
      _postsWithMyReplies = [];
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      canLoadMore = false;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      _postsWithMyReplies = await getRepliedPosts(docs);
    } else {
      // isPostsExisting = true;
      canLoadMore = true;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      _postsWithMyReplies = await getRepliedPosts(docs);
    }

    final bookmarkedPostsIds = await getBookmarkedPostsIds();
    final empathizedPostsIds = await getEmpathizedPostsIds();

    await addBookmark(_postsWithMyReplies, bookmarkedPostsIds);
    await addEmpathy(_postsWithMyReplies, empathizedPostsIds);
    await getReplies(_postsWithMyReplies, empathizedPostsIds);

    stopLoading();
    notifyListeners();
  }

  Future<void> _loadPostsWithMyReplies() async {
    startLoading();

    final queryBatch = firestore
        .collectionGroup('replies')
        .where('replierId', isEqualTo: auth.currentUser?.uid)
        .orderBy('updatedAt', descending: true)
        .startAfterDocument(lastVisibleOfTheBatch!)
        .limit(loadLimit);
    final querySnapshot = await queryBatch.get();
    final docs = querySnapshot.docs;
    if (docs.length == 0) {
      // isPostsExisting = false;
      canLoadMore = false;
      _postsWithMyReplies += [];
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      canLoadMore = false;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      _postsWithMyReplies += await getRepliedPosts(docs);
    } else {
      // isPostsExisting = true;
      canLoadMore = true;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      _postsWithMyReplies += await getRepliedPosts(docs);
    }

    final bookmarkedPostsIds = await getBookmarkedPostsIds();
    final empathizedPostsIds = await getEmpathizedPostsIds();

    await addBookmark(_postsWithMyReplies, bookmarkedPostsIds);
    await addEmpathy(_postsWithMyReplies, empathizedPostsIds);
    await getReplies(_postsWithMyReplies, empathizedPostsIds);

    stopLoading();
    notifyListeners();
  }

  Future<void> refreshThePostOfPostsAfterUpdated({
    required Post oldPost,
    required int indexOfPost,
  }) async {
    await refreshThePostAfterUpdated(
      posts: _postsWithMyReplies,
      oldPost: oldPost,
      indexOfPost: indexOfPost,
    );

    notifyListeners();
  }

  void removeThePostOfPostsAfterDeleted(Post post) {
    _postsWithMyReplies.remove(post);
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
