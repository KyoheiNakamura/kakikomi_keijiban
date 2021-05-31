import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';
import 'package:kakikomi_keijiban/common/mixin/provide_common_posts_method_mixin.dart';
import 'package:kakikomi_keijiban/domain/notice.dart';
import 'package:kakikomi_keijiban/domain/post.dart';

class PostDetailModel extends ChangeNotifier
    with ProvideCommonPostsMethodMixin {
  late String posterId;
  late String postId;
  Post? post;

  bool isModalLoading = false;

  Future<void> init(Notice notice) async {
    posterId = notice.posterId;
    postId = notice.postId;
    startModalLoading();
    await getPost();
    stopModalLoading();
  }

  Future<void> getPost() async {
    final empathizedPostsIds = await getEmpathizedPostsIds();
    final bookmarkedPostsIds = await getBookmarkedPostsIds();

    final snapshot = await firestore
        .collection('users')
        .doc(posterId)
        .collection('posts')
        .doc(postId)
        .get();
    post = Post(snapshot);

    await addBookmark(<Post>[post!], bookmarkedPostsIds);
    await addEmpathy(<Post>[post!], empathizedPostsIds);
    await getReplies([post!], empathizedPostsIds);

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
