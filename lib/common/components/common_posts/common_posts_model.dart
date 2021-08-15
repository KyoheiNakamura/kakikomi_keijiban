import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/mixin/provide_common_posts_method_mixin.dart';
import 'package:kakikomi_keijiban/entity/post.dart';
import 'package:kakikomi_keijiban/manager/firestore_manager.dart';

class CommonPostsModel extends ChangeNotifier
    with ProvideCommonPostsMethodMixin {
  CommonPostsModel({
    required this.type,
    this.searchWord,
  });

  final CommonPostsType type;
  final String? searchWord;

  List<Post> _posts = [];
  List<Post> get posts => _posts;

  QueryDocumentSnapshot? lastVisibleOfTheBatch;
  int loadLimit = 5;
  // bool isPostsExisting = false;
  bool canLoadMore = false;
  bool isLoading = false;
  bool isModalLoading = false;

  String postField = '';

  Future<void> init() async {
    // startModalLoading();
    if (searchWord != null) {
      postField = _getPostField(searchWord!);
    }
    await getPostsWithReplies();
    // stopModalLoading();
  }

  Future<void> getPostsWithReplies() async {
    // startModalLoading();

    try {
      final queryBatch = FireStoreManager.instance.getCommonPostsQuery(
        type: type,
        loadLimit: loadLimit,
        postField: postField,
        searchWord: searchWord,
      );
      final querySnapshot = await queryBatch.get();
      final docs = querySnapshot.docs;
      _posts.clear();
      if (docs.isEmpty) {
        // isPostsExisting = false;
        canLoadMore = false;
        _posts = [];
      } else if (docs.length < loadLimit) {
        // isPostsExisting = true;
        canLoadMore = false;
        lastVisibleOfTheBatch = docs[docs.length - 1];
        _posts = await _getPosts(docs);
      } else {
        // isPostsExisting = true;
        canLoadMore = true;
        lastVisibleOfTheBatch = docs[docs.length - 1];
        _posts = await _getPosts(docs);
      }

      notifyListeners();

      if (type != CommonPostsType.bookmarkedPosts) {
        // final bookmarkedPostsIds = await getBookmarkedPostsIds();
        addBookmark(_posts);
      }

      notifyListeners();

      // final empathizedPostsIds = await getEmpathizedPostsIds();
      addEmpathy(_posts);

      await Future.delayed(const Duration(seconds: 3), () {});

      // notifyListeners();

      // await getReplies(_posts, empathizedPostsIds);

      // stopModalLoading();
      notifyListeners();
    } catch (e) {
      // エラーが出ても何もしない
      // dispose() 後に notifyListeners() が呼ばれる時の例外を処理するため。
      print('ゲットオオオオオオオオ');
      print(e.toString());
    }
  }

  Future<void> loadPostsWithReplies() async {
    startLoading();

    try {
      final queryBatch = FireStoreManager.instance.loadCommonPostsQuery(
        type: type,
        loadLimit: loadLimit,
        lastVisibleOfTheBatch: lastVisibleOfTheBatch!,
        postField: postField,
        searchWord: searchWord,
      );
      final querySnapshot = await queryBatch.get();
      final docs = querySnapshot.docs;
      if (docs.isEmpty) {
        // isPostsExisting = false;
        canLoadMore = false;
        _posts += [];
      } else if (docs.length < loadLimit) {
        // isPostsExisting = true;
        canLoadMore = false;
        lastVisibleOfTheBatch = docs[docs.length - 1];
        _posts += await _getPosts(docs);
      } else {
        // isPostsExisting = true;
        canLoadMore = true;
        lastVisibleOfTheBatch = docs[docs.length - 1];
        _posts += await _getPosts(docs);
      }

      notifyListeners();

      if (type != CommonPostsType.bookmarkedPosts) {
        // final bookmarkedPostsIds = await getBookmarkedPostsIds();
        addBookmark(_posts);
      }

      notifyListeners();

      // final empathizedPostsIds = await getEmpathizedPostsIds();
      addEmpathy(_posts);

      await Future.delayed(const Duration(seconds: 3), () {});

      // notifyListeners();

      // await getReplies(_posts, empathizedPostsIds);

      // stopLoading();
      notifyListeners();
    } catch (e) {
      // エラーが出ても何もしない
      // dispose() 後に notifyListeners() が呼ばれる時の例外を処理するため。
      print('ロードオオオオオオオオオオオオ');
      print(e.toString());
    } finally {
      stopLoading();
    }
  }

  Future<void> refreshThePostOfPostsAfterUpdated({
    required Post oldPost,
    required int indexOfPost,
  }) async {
    await refreshThePostAfterUpdated(
      posts: _posts,
      oldPost: oldPost,
      indexOfPost: indexOfPost,
    );

    notifyListeners();
  }

  void removeThePostOfPostsAfterDeleted(Post post) {
    _posts.remove(post);
    notifyListeners();
  }

  String _getPostField(String searchWord) {
    if (kCategoryList.contains(searchWord)) {
      return 'categories';
    } else if (kEmotionList.contains(searchWord)) {
      return 'emotion';
    } else if (kPositionList.contains(searchWord)) {
      return 'position';
    } else if (kGenderList.contains(searchWord)) {
      return 'gender';
    } else if (kAgeList.contains(searchWord)) {
      return 'age';
    } else if (kAreaList.contains(searchWord)) {
      return 'area';
    } else {
      return '';
    }
  }

  Future<List<Post>> _getPosts(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    if (type == CommonPostsType.bookmarkedPosts) {
      return getBookmarkedPosts(docs);
    } else if (type == CommonPostsType.myReplies) {
      return getRepliedPosts(docs);
    } else {
      return docs.map((doc) => Post.fromDoc(doc)).toList();
    }
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
