import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';
import 'package:kakikomi_keijiban/common/mixin/provide_common_posts_method_mixin.dart';
import 'package:kakikomi_keijiban/entity/infinite_scroll.dart';
import 'package:kakikomi_keijiban/entity/post.dart';
import 'package:kakikomi_keijiban/entity/reply.dart';
import 'package:kakikomi_keijiban/manager/firestore_manager.dart';
import 'package:kakikomi_keijiban/repository/post_repository.dart';

/// PostDetailPage2 の状態を管理する
class PostDetailModel2 extends ChangeNotifier
    with ProvideCommonPostsMethodMixin {
  PostDetailModel2({required this.post});

  final Post post;

  bool canLoadMore = false;
  QueryDocumentSnapshot? lastVisibleOfTheBatch;
  bool isLoading = false;
  final int loadLimit = 10;

  // final ScrollController scrollController = ScrollController();

  // final StreamController<Post> streamController = StreamController();
  final StreamController<void> streamController = StreamController();

  // Future<void> init() async {
  // WidgetsBinding.instance?.addPostFrameCallback((_) {
  //   scrollController.jumpTo(scrollController.position.maxScrollExtent);
  // });
  // subscribePostChange();
  // await reloadReplies();
  // notifyListeners();
  // subscribeRepliesChange();
  // await Future(() {
  //   scrollController.jumpTo(scrollController.position.maxScrollExtent);
  // });
  // }

  // void subscribePostChange() {
  //   PostRepository.instance.subscribePostChange(
  //     post: post,
  //     streamController: streamController,
  //   );
  //   streamController.stream.listen((changedPost) {
  //     print('いえあいえhじldjfklじゃlkdjごはあああああああああああああああああああ');
  //     post = changedPost;
  //     notifyListeners();
  //   });
  // }

  /// 返信を取得する
  Future<void> getLimitedReplies() async {
    startLoading();

    try {
      final queryBatch = getRepliesQuery(
        post: post,
        loadLimit: loadLimit,
      );
      final querySnapshot = await queryBatch.get();
      final docs = querySnapshot.docs;
      post.replies.clear();
      if (docs.isEmpty) {
        // isPostsExisting = false;
        canLoadMore = false;
        post.replies = [];
      } else if (docs.length < loadLimit) {
        // isPostsExisting = true;
        canLoadMore = false;
        lastVisibleOfTheBatch = docs[docs.length - 1];
        post.replies = await getReplies(docs);
      } else {
        // isPostsExisting = true;
        canLoadMore = true;
        lastVisibleOfTheBatch = docs[docs.length - 1];
        post.replies = await getReplies(docs);
      }

      notifyListeners();
    } catch (e) {
      // エラーが出ても何もしない
      // dispose() 後に notifyListeners() が呼ばれる時の例外を処理するため。
      print(e.toString());
    } finally {
      stopLoading();
    }
  }

  /// 投稿をさらに取得する
  Future<void> loadPostsWithReplies() async {
    startLoading();

    try {
      final queryBatch = loadRepliesQuery(
        post: post,
        loadLimit: loadLimit,
        lastVisibleOfTheBatch: lastVisibleOfTheBatch!,
      );
      final querySnapshot = await queryBatch.get();
      final docs = querySnapshot.docs;
      if (docs.isEmpty) {
        // isPostsExisting = false;
        canLoadMore = false;
        post.replies += [];
      } else if (docs.length < loadLimit) {
        // isPostsExisting = true;
        canLoadMore = false;
        lastVisibleOfTheBatch = docs[docs.length - 1];
        post.replies += await getReplies(docs);
      } else {
        // isPostsExisting = true;
        canLoadMore = true;
        lastVisibleOfTheBatch = docs[docs.length - 1];
        post.replies += await getReplies(docs);
      }

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

  // void subscribeRepliesChange() {
  //   PostRepository.instance.subscribeRepliesChange(
  //     post: post,
  //     streamController: streamController,
  //   );
  //   streamController.stream.listen((_) {
  //     print('いえあいえhじldjfklじゃlkdjごはあああああああああああああああああああ');
  //     notifyListeners();
  //   });
  // }

  // Future<void> reloadReplies() async {
  //   // final empathizedPostsIds = await getEmpathizedPostsIds();
  //   await getReplies([post]);
  //   notifyListeners();
  // }

  void startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void stopLoading() {
    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    // scrollController.dispose();
    streamController.close();
    PostRepository.instance.unsubscribeRepliesChange();
    super.dispose();
  }
}

/// 削除予定いいいいいいいいいいいいいいいいいいいいいいいい
class PostDetailModel extends ChangeNotifier
    with ProvideCommonPostsMethodMixin {
  PostDetailModel({
    required this.posterId,
    required this.postId,
  });

  final String posterId;
  final String postId;

  Post? post;

  Future<void> init() async {
    await getPost();
    notifyListeners();
  }

  Future<void> getPost() async {
    final snapshot = await firestore
        .collection('users')
        .doc(posterId)
        .collection('posts')
        .doc(postId)
        .get();
    post = Post.fromDoc(snapshot);
    notifyListeners();

    // final empathizedPostsIds = await getEmpathizedPostsIds();
    addEmpathy(<Post>[post!]);
    notifyListeners();

    // final bookmarkedPostsIds = await getBookmarkedPostsIds();
    addBookmark(<Post>[post!]);
    notifyListeners();

    // await getReplies([post!]);
    notifyListeners();
  }
}
