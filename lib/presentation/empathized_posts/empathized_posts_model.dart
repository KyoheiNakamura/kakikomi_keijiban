import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';
import 'package:kakikomi_keijiban/common/mixin/provide_common_posts_method_mixin.dart';
import 'package:kakikomi_keijiban/entity/empathized_post.dart';

class EmpathizedPostsModel extends ChangeNotifier
    with ProvideCommonPostsMethodMixin {
  List<EmpathizedPost> _empathizedPosts = [];
  List<EmpathizedPost> get empathizedPosts => _empathizedPosts;

  QueryDocumentSnapshot? lastVisibleOfTheBatch;
  int loadLimit = 10;
  // bool isPostsExisting = false;
  bool canLoadMore = false;
  bool isLoading = false;
  bool isModalLoading = false;

  Future<void> init() async {
    // startModalLoading();
    await getEmpathizedPosts();
    // stopModalLoading();
    await _removeNoticeBadgeIcon();
  }

  Future<void> getEmpathizedPosts() async {
    startLoading();

    final queryBatch = firestore
        .collection('users')
        .doc(auth.currentUser?.uid)
        .collection('empathizedPosts')
        .orderBy('createdAt', descending: true)
        .limit(loadLimit);            
    final querySnapshot = await queryBatch.get();
    final docs = querySnapshot.docs;
    _empathizedPosts.clear();
    if (docs.isEmpty) {
      // isPostsExisting = false;
      canLoadMore = false;
      _empathizedPosts = [];
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      canLoadMore = false;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      _empathizedPosts = await fetchEmpathizedPosts(docs);
    } else {
      // isPostsExisting = true;
      canLoadMore = true;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      _empathizedPosts = await fetchEmpathizedPosts(docs);
    }

    stopLoading();
    notifyListeners();
  }

  Future<void> loadEmpathizedPosts() async {
    startLoading();

    final queryBatch = firestore
        .collection('users')
        .doc(auth.currentUser?.uid)
        .collection('empathizedPosts')
        .orderBy('createdAt', descending: true)
        .startAfterDocument(lastVisibleOfTheBatch!)
        .limit(loadLimit);
    final querySnapshot = await queryBatch.get();
    final docs = querySnapshot.docs;
    if (docs.isEmpty) {
      // isPostsExisting = false;
      canLoadMore = false;
      _empathizedPosts += [];
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      canLoadMore = false;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      _empathizedPosts += await fetchEmpathizedPosts(docs);
    } else {
      // isPostsExisting = true;
      canLoadMore = true;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      _empathizedPosts += await fetchEmpathizedPosts(docs);
    }
    stopLoading();
    notifyListeners();
  }

  Future<void> _removeNoticeBadgeIcon() async {
    final userDocRef = firestore.collection('users').doc(auth.currentUser?.uid);
    await userDocRef.update({
      'badges': {'notice': false},
    });
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
