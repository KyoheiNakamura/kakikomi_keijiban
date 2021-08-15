import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/components/common_loading_spinner.dart';
import 'package:kakikomi_keijiban/common/components/common_posts/common_posts_model.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/mixin/provide_common_posts_method_mixin.dart';
import 'package:kakikomi_keijiban/entity/post.dart';
import 'package:kakikomi_keijiban/entity/post_tab.dart';
import 'package:kakikomi_keijiban/manager/firestore_manager.dart';
import 'package:kakikomi_keijiban/repository/bookmark_repository.dart';
import 'package:kakikomi_keijiban/repository/empathy_repository.dart';
import 'package:kakikomi_keijiban/repository/post_repository.dart';

class HomePageModel extends ChangeNotifier with ProvideCommonPostsMethodMixin {
  final NewPostTab newPostTab = NewPostTab();
  final EmpathizedPostTab empathizedPostTab = EmpathizedPostTab();
  final BookmarkedPostTab bookmarkedPostTab = BookmarkedPostTab();

  final int loadLimit = 10;

  final ScrollController newScrollController = ScrollController();
  final ScrollController empathizedScrollController = ScrollController();
  final ScrollController bookmarkedScrollController = ScrollController();

  Future<void> init(BuildContext context) async {
    await EmpathyRepository.instance.init();
    await BookmarkRepository.instance.init();
    await getPosts(type: CommonPostsType.newPosts);
    await getPosts(type: CommonPostsType.empathizedPosts);
    await getPosts(type: CommonPostsType.bookmarkedPosts);
  }

  /// 最新の投稿を取得してページトップまでスクロールする
  Future<void> reloadTab(
    BuildContext context, {
    required CommonPostsType type,
  }) async {
    // ignore: unawaited_futures
    CommonLoadingDialog.instance.showDialog(context);
    try {
      await getPosts(type: type);
      // ページのトップまでスクロールする      
      final scrollController = getScrollController(type);
      scrollController?.jumpTo(scrollController.position.minScrollExtent);
    } on Exception catch (_) {
      // エラーが出ても何もしない
    } finally {
      CommonLoadingDialog.instance.closeDialog();
    }
  }

  ScrollController? getScrollController(CommonPostsType type) {
    switch (type) {
      case CommonPostsType.newPosts:
        return newScrollController;
      case CommonPostsType.empathizedPosts:
        return empathizedScrollController;
      case CommonPostsType.bookmarkedPosts:
        return bookmarkedScrollController;
      // ignore: no_default_cases
      default:
        break;
    }
  }

  QueryDocumentSnapshot? lastVisibleOfTheBatch(CommonPostsType type) {
    return getPostTab(type).lastVisibleOfTheBatch;
  }

  bool isLoading(CommonPostsType type) {
    return getPostTab(type).isLoading;
  }

  bool canLoadMore(CommonPostsType type) {
    return getPostTab(type).canLoadMore;
  }

  List<Post> posts(CommonPostsType type) {
    return getPostTab(type).posts;
  }

  PostTab getPostTab(CommonPostsType type) {
    switch (type) {
      case CommonPostsType.newPosts:
        return newPostTab;
      case CommonPostsType.empathizedPosts:
        return empathizedPostTab;
      case CommonPostsType.bookmarkedPosts:
        return bookmarkedPostTab;
      // ignore: no_default_cases
      default:
        return newPostTab;
    }
  }

  /// 投稿を取得する
  Future<void> getPosts({
    required CommonPostsType type,
  }) async {
    final postTab = getPostTab(type);
    try {
      final queryBatch = FireStoreManager.instance.getCommonPostsQuery(
        type: type,
        loadLimit: loadLimit,
      );
      final querySnapshot = await queryBatch.get();
      final docs = querySnapshot.docs;
      postTab.posts.clear();
      if (docs.isEmpty) {
        // isPostsExisting = false;
        postTab
          ..canLoadMore = false
          ..posts = [];
      } else if (docs.length < loadLimit) {
        // isPostsExisting = true;
        postTab
          ..canLoadMore = false
          ..lastVisibleOfTheBatch = docs[docs.length - 1]
          ..posts = await _getPosts(type: type, docs: docs);
      } else {
        // isPostsExisting = true;
        postTab
          ..canLoadMore = true
          ..lastVisibleOfTheBatch = docs[docs.length - 1]
          ..posts = await _getPosts(type: type, docs: docs);
      }

      notifyListeners();

      if (type != CommonPostsType.bookmarkedPosts) {
        // final bookmarkedPostsIds = await getBookmarkedPostsIds();
        addBookmark(postTab.posts);
      }

      notifyListeners();

      // final empathizedPostsIds = await getEmpathizedPostsIds();
      addEmpathy(postTab.posts);

      notifyListeners();
    } catch (e) {
      // エラーが出ても何もしない
      // dispose() 後に notifyListeners() が呼ばれる時の例外を処理するため。
      print(e.toString());
    }
  }

  /// 投稿をさらに取得する
  Future<void> loadPostsWithReplies({
    required CommonPostsType type,
  }) async {
    final postTab = getPostTab(type);
    startLoading(postTab);

    try {
      final queryBatch = FireStoreManager.instance.loadCommonPostsQuery(
        type: CommonPostsType.newPosts,
        loadLimit: loadLimit,
        lastVisibleOfTheBatch: lastVisibleOfTheBatch(type)!,
      );
      final querySnapshot = await queryBatch.get();
      final docs = querySnapshot.docs;
      if (docs.isEmpty) {
        // isPostsExisting = false;
        postTab
          ..canLoadMore = false
          ..posts += [];
      } else if (docs.length < loadLimit) {
        // isPostsExisting = true;
        postTab
          ..canLoadMore = false
          ..lastVisibleOfTheBatch = docs[docs.length - 1]
          ..posts += await _getPosts(type: type, docs: docs);
      } else {
        // isPostsExisting = true;
        postTab
          ..canLoadMore = true
          ..lastVisibleOfTheBatch = docs[docs.length - 1]
          ..posts += await _getPosts(type: type, docs: docs);
      }

      notifyListeners();

      if (type != CommonPostsType.bookmarkedPosts) {
        // final bookmarkedPostsIds = await getBookmarkedPostsIds();
        addBookmark(postTab.posts);
      }

      notifyListeners();

      // final empathizedPostsIds = await getEmpathizedPostsIds();
      addEmpathy(postTab.posts);

      // await Future.delayed(const Duration(seconds: 3), () {});

      // notifyListeners();

      // await getReplies(postTab.posts, empathizedPostsIds);

      // stopLoading();
      notifyListeners();
    } catch (e) {
      // エラーが出ても何もしない
      // dispose() 後に notifyListeners() が呼ばれる時の例外を処理するため。
      print('ロードオオオオオオオオオオオオ');
      print(e.toString());
    } finally {
      stopLoading(postTab);
    }
  }

  Future<void> refreshThePostOfPostsAfterUpdated({
    required CommonPostsType type,
    required Post oldPost,
    required int indexOfPost,
  }) async {
    final postTab = getPostTab(type);
    await refreshThePostAfterUpdated(
      posts: postTab.posts,
      oldPost: oldPost,
      indexOfPost: indexOfPost,
    );

    notifyListeners();
  }

  void removeThePostOfPostsAfterDeleted({
    required CommonPostsType type,
    required Post post,
  }) {
    final postTab = getPostTab(type);
    postTab.posts.remove(post);
    notifyListeners();
  }

  Future<List<Post>> _getPosts({
    required CommonPostsType type,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  }) async {
    if (type == CommonPostsType.bookmarkedPosts) {
      return getBookmarkedPosts(docs);
    } else if (type == CommonPostsType.myReplies) {
      return getRepliedPosts(docs);
    } else {
      return docs.map((doc) => Post.fromDoc(doc)).toList();
    }
  }

  void startLoading(PostTab postTab) {
    postTab.isLoading = true;
    notifyListeners();
  }

  void stopLoading(PostTab postTab) {
    postTab.isLoading = false;
    notifyListeners();
  }
}
