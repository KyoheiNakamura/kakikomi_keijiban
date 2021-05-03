import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/mixin/provide_common_posts_method_mixin.dart';
import 'package:kakikomi_keijiban/domain/post.dart';

class SearchResultPostsModel extends ChangeNotifier
    with ProvideCommonPostsMethodMixin {
  final _firestore = FirebaseFirestore.instance;

  List<Post> _searchedPosts = [];
  List<Post> get posts => _searchedPosts;

  QueryDocumentSnapshot? lastVisibleOfTheBatch;
  int loadLimit = 10;
  // bool isPostsExisting = false;
  bool canLoadMore = false;
  bool isLoading = false;
  bool isModalLoading = false;

  String postField = '';
  String searchWord = '';

  Future<void> init(String searchWord) async {
    startModalLoading();
    this.searchWord = searchWord;
    getPostField(searchWord);
    await getPostsWithRepliesChosenField();
    stopModalLoading();
  }

  void getPostField(String searchWord) {
    if (kCategoryList.contains(searchWord)) {
      this.postField = 'categories';
    } else if (kEmotionList.contains(searchWord)) {
      this.postField = 'emotion';
    } else if (kPositionList.contains(searchWord)) {
      this.postField = 'position';
    } else if (kGenderList.contains(searchWord)) {
      this.postField = 'gender';
    } else if (kAgeList.contains(searchWord)) {
      this.postField = 'age';
    } else if (kAreaList.contains(searchWord)) {
      this.postField = 'area';
    } else {
      this.postField = '';
    }
  }

  Future<void> getPostsWithRepliesChosenField() async {
    startModalLoading();

    final Query queryBatch;
    // postのfieldの値が配列(array)のとき
    // Todo positionも複数選択に変える予定なので、おいおいこっちの条件に||で追加するはず
    if (postField == 'categories') {
      queryBatch = _firestore
          .collectionGroup('posts')
          .where(this.postField, arrayContains: this.searchWord)
          .orderBy('createdAt', descending: true)
          .limit(loadLimit);
    } else {
      queryBatch = _firestore
          .collectionGroup('posts')
          .where(this.postField, isEqualTo: this.searchWord)
          .orderBy('createdAt', descending: true)
          .limit(loadLimit);
    }
    final querySnapshot = await queryBatch.get();
    final docs = querySnapshot.docs;
    this._searchedPosts.clear();
    if (docs.length == 0) {
      // isPostsExisting = false;
      this.canLoadMore = false;
      this._searchedPosts = [];
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      this.canLoadMore = false;
      this.lastVisibleOfTheBatch = docs[docs.length - 1];
      this._searchedPosts = docs.map((doc) => Post(doc)).toList();
    } else {
      // isPostsExisting = true;
      this.canLoadMore = true;
      this.lastVisibleOfTheBatch = docs[docs.length - 1];
      this._searchedPosts = docs.map((doc) => Post(doc)).toList();
    }

    await addBookmark(this._searchedPosts);
    await addEmpathy(this._searchedPosts);
    await getReplies(this._searchedPosts);

    stopModalLoading();
    notifyListeners();
  }

  Future<void> loadPostsWithRepliesChosenField() async {
    startLoading();

    final Query queryBatch;
    // postのfieldの値が配列(array)のとき
    // Todo positionも複数選択に変える予定なので、おいおいこっちの条件に||で追加するはず
    if (this.postField == 'categories') {
      queryBatch = _firestore
          .collectionGroup('posts')
          .where(this.postField, arrayContains: this.searchWord)
          .orderBy('createdAt', descending: true)
          .startAfterDocument(lastVisibleOfTheBatch!)
          .limit(loadLimit);
    } else {
      queryBatch = _firestore
          .collectionGroup('posts')
          .where(this.postField, isEqualTo: this.searchWord)
          .orderBy('createdAt', descending: true)
          .startAfterDocument(lastVisibleOfTheBatch!)
          .limit(loadLimit);
    }
    final querySnapshot = await queryBatch.get();
    final docs = querySnapshot.docs;
    if (docs.length == 0) {
      // isPostsExisting = false;
      this.canLoadMore = false;
      this._searchedPosts = [];
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      this.canLoadMore = false;
      this.lastVisibleOfTheBatch = docs[docs.length - 1];
      this._searchedPosts = docs.map((doc) => Post(doc)).toList();
    } else {
      // isPostsExisting = true;
      this.canLoadMore = true;
      this.lastVisibleOfTheBatch = docs[docs.length - 1];
      this._searchedPosts = docs.map((doc) => Post(doc)).toList();
    }

    await addBookmark(this._searchedPosts);
    await addEmpathy(this._searchedPosts);
    await getReplies(this._searchedPosts);

    stopLoading();
    notifyListeners();
  }

  Future<void> refreshThePostOfPostsAfterUpdated({
    required Post oldPost,
    required int indexOfPost,
  }) async {
    await refreshThePostAfterUpdated(
      posts: this._searchedPosts,
      oldPost: oldPost,
      indexOfPost: indexOfPost,
    );

    notifyListeners();
  }

  void removeThePostOfPostsAfterDeleted(Post post) {
    this._searchedPosts.remove(post);
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
