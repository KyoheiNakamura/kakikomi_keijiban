import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';
import 'package:kakikomi_keijiban/common/mixin/provide_common_posts_method_mixin.dart';
import 'package:kakikomi_keijiban/entity/notice.dart';
import 'package:kakikomi_keijiban/entity/post.dart';

class PostDetailModel extends ChangeNotifier
    with ProvideCommonPostsMethodMixin {
  late String posterId;
  late String postId;
  Post? post;

  bool isModalLoading = false;

  Future<void> init(dynamic entity) async {
    posterId = entity.posterId;
    postId = entity.postId;
    // startModalLoading();
    await getPost();
    // stopModalLoading();
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

    final empathizedPostsIds = await getEmpathizedPostsIds();
    await addEmpathy(<Post>[post!], empathizedPostsIds);
    notifyListeners();

    final bookmarkedPostsIds = await getBookmarkedPostsIds();
    await addBookmark(<Post>[post!], bookmarkedPostsIds);
    notifyListeners();

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
