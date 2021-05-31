import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';
import 'package:kakikomi_keijiban/common/mixin/provide_common_posts_method_mixin.dart';
import 'package:kakikomi_keijiban/domain/post.dart';

class SearchResultPostsModel extends ChangeNotifier
    with ProvideCommonPostsMethodMixin {
  List<Post> _searchedPosts = [];
  List<Post> get posts => _searchedPosts;

  QueryDocumentSnapshot? lastVisibleOfTheBatch;
  int loadLimit = 5;
  // bool isPostsExisting = false;
  bool canLoadMore = false;
  bool isLoading = false;
  bool isModalLoading = false;

  String postField = '';
  String searchWord = '';

  Future<void> init(String _searchWord) async {
    startModalLoading();
    searchWord = _searchWord;
    getPostField(searchWord);
    await getPostsWithRepliesChosenField();
    stopModalLoading();
  }

  void getPostField(String searchWord) {
    if (kCategoryList.contains(searchWord)) {
      postField = 'categories';
    } else if (kEmotionList.contains(searchWord)) {
      postField = 'emotion';
    } else if (kPositionList.contains(searchWord)) {
      postField = 'position';
    } else if (kGenderList.contains(searchWord)) {
      postField = 'gender';
    } else if (kAgeList.contains(searchWord)) {
      postField = 'age';
    } else if (kAreaList.contains(searchWord)) {
      postField = 'area';
    } else {
      postField = '';
    }
  }

  Future<void> getPostsWithRepliesChosenField() async {
    startModalLoading();

    final Query queryBatch;
    // postのfieldの値が配列(array)のとき
    // Todo positionも複数選択に変える予定なので、おいおいこっちの条件に||で追加するはず
    if (postField == 'categories') {
      queryBatch = firestore
          .collectionGroup('posts')
          .where(postField, arrayContains: searchWord)
          .orderBy('createdAt', descending: true)
          .limit(loadLimit);
    } else {
      queryBatch = firestore
          .collectionGroup('posts')
          .where(postField, isEqualTo: searchWord)
          .orderBy('createdAt', descending: true)
          .limit(loadLimit);
    }
    final querySnapshot = await queryBatch.get();
    final docs = querySnapshot.docs;
    _searchedPosts.clear();
    if (docs.length == 0) {
      // isPostsExisting = false;
      canLoadMore = false;
      _searchedPosts = [];
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      canLoadMore = false;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      _searchedPosts = docs.map((doc) => Post(doc)).toList();
    } else {
      // isPostsExisting = true;
      canLoadMore = true;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      _searchedPosts = docs.map((doc) => Post(doc)).toList();
    }

    final bookmarkedPostsIds = await getBookmarkedPostsIds();
    final empathizedPostsIds = await getEmpathizedPostsIds();

    await addBookmark(_searchedPosts, bookmarkedPostsIds);
    await addEmpathy(_searchedPosts, empathizedPostsIds);
    await getReplies(_searchedPosts, empathizedPostsIds);

    stopModalLoading();
    notifyListeners();
  }

  Future<void> loadPostsWithRepliesChosenField() async {
    startLoading();

    final Query queryBatch;
    // postのfieldの値が配列(array)のとき
    // Todo positionも複数選択に変える予定なので、おいおいこっちの条件に||で追加するはず
    if (postField == 'categories') {
      queryBatch = firestore
          .collectionGroup('posts')
          .where(postField, arrayContains: searchWord)
          .orderBy('createdAt', descending: true)
          .startAfterDocument(lastVisibleOfTheBatch!)
          .limit(loadLimit);
    } else {
      queryBatch = firestore
          .collectionGroup('posts')
          .where(postField, isEqualTo: searchWord)
          .orderBy('createdAt', descending: true)
          .startAfterDocument(lastVisibleOfTheBatch!)
          .limit(loadLimit);
    }
    final querySnapshot = await queryBatch.get();
    final docs = querySnapshot.docs;
    if (docs.length == 0) {
      // isPostsExisting = false;
      canLoadMore = false;
      _searchedPosts = [];
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      canLoadMore = false;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      _searchedPosts = docs.map((doc) => Post(doc)).toList();
    } else {
      // isPostsExisting = true;
      canLoadMore = true;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      _searchedPosts = docs.map((doc) => Post(doc)).toList();
    }

    final bookmarkedPostsIds = await getBookmarkedPostsIds();
    final empathizedPostsIds = await getEmpathizedPostsIds();

    await addBookmark(_searchedPosts, bookmarkedPostsIds);
    await addEmpathy(_searchedPosts, empathizedPostsIds);
    await getReplies(_searchedPosts, empathizedPostsIds);

    stopLoading();
    notifyListeners();
  }

  Future<void> refreshThePostOfPostsAfterUpdated({
    required Post oldPost,
    required int indexOfPost,
  }) async {
    await refreshThePostAfterUpdated(
      posts: _searchedPosts,
      oldPost: oldPost,
      indexOfPost: indexOfPost,
    );

    notifyListeners();
  }

  void removeThePostOfPostsAfterDeleted(Post post) {
    _searchedPosts.remove(post);
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
