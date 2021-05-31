import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';
import 'package:kakikomi_keijiban/domain/notice.dart';

class NoticesModel extends ChangeNotifier {
  List<Notice> notices = [];

  QueryDocumentSnapshot? lastVisibleOfTheBatch;
  int loadLimit = 15;
  // bool isPostsExisting = false;
  bool canLoadMore = false;
  bool isLoading = false;
  bool isModalLoading = false;

  Future<void> init() async {
    startModalLoading();
    await getMyNotices();
    stopModalLoading();
    await _removeNoticeBadgeIcon();
  }

  Future<void> getMyNotices() async {
    startLoading();

    final queryBatch = firestore
        .collection('users')
        .doc(auth.currentUser?.uid)
        .collection('notices')
        .orderBy('createdAt', descending: true)
        .limit(loadLimit);
    final querySnapshot = await queryBatch.get();
    final docs = querySnapshot.docs;
    notices.clear();
    if (docs.length == 0) {
      // isPostsExisting = false;
      canLoadMore = false;
      notices = [];
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      canLoadMore = false;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      notices = docs.map((doc) => Notice(doc)).toList();
    } else {
      // isPostsExisting = true;
      canLoadMore = true;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      notices = docs.map((doc) => Notice(doc)).toList();
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
