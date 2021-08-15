// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:kakikomi_keijiban/common/firebase_util.dart';
// import 'package:kakikomi_keijiban/common/mixin/provide_common_posts_method_mixin.dart';
// import 'package:kakikomi_keijiban/entity/post.dart';

// class BookmarkedPostsModel extends ChangeNotifier
//     with ProvideCommonPostsMethodMixin {
//   List<Post> _bookmarkedPosts = [];
//   List<Post> get posts => _bookmarkedPosts;

//   Future<void> get getPostsWithReplies => _getBookmarkedPostsWithReplies();
//   Future<void> get loadPostsWithReplies => _loadBookmarkedPostsWithReplies();

//   QueryDocumentSnapshot? lastVisibleOfTheBatch;
//   int loadLimit = 5;
//   // bool isPostsExisting = false;
//   bool canLoadMore = false;
//   bool isLoading = false;
//   bool isModalLoading = false;

//   Future<void> init() async {
//     startModalLoading();
//     await _getBookmarkedPostsWithReplies();
//     stopModalLoading();
//   }

//   Future<void> _getBookmarkedPostsWithReplies() async {
//     startModalLoading();

//     final queryBatch = firestore
//         .collection('users')
//         .doc(auth.currentUser?.uid)
//         .collection('bookmarkedPosts')
//         .orderBy('createdAt', descending: true)
//         .limit(loadLimit);
//     final querySnapshot = await queryBatch.get();
//     final docs = querySnapshot.docs;
//     _bookmarkedPosts.clear();
//     if (docs.isEmpty) {
//       // isPostsExisting = false;
//       canLoadMore = false;
//       _bookmarkedPosts = [];
//     } else if (docs.length < loadLimit) {
//       // isPostsExisting = true;
//       canLoadMore = false;
//       lastVisibleOfTheBatch = docs[docs.length - 1];
//       _bookmarkedPosts = await getBookmarkedPosts(docs);
//     } else {
//       // isPostsExisting = true;
//       canLoadMore = true;
//       lastVisibleOfTheBatch = docs[docs.length - 1];
//       _bookmarkedPosts = await getBookmarkedPosts(docs);
//     }

//     final empathizedPostsIds = await getEmpathizedPostsIds();

//     addEmpathy(_bookmarkedPosts, empathizedPostsIds);
//     await getReplies(_bookmarkedPosts, empathizedPostsIds);

//     stopModalLoading();
//     notifyListeners();
//   }

//   Future<void> _loadBookmarkedPostsWithReplies() async {
//     startLoading();

//     final queryBatch = firestore
//         .collection('users')
//         .doc(auth.currentUser?.uid)
//         .collection('bookmarkedPosts')
//         .orderBy('createdAt', descending: true)
//         .startAfterDocument(lastVisibleOfTheBatch!)
//         .limit(loadLimit);
//     final querySnapshot = await queryBatch.get();
//     final docs = querySnapshot.docs;
//     if (docs.isEmpty) {
//       // isPostsExisting = false;
//       canLoadMore = false;
//       _bookmarkedPosts += [];
//     } else if (docs.length < loadLimit) {
//       // isPostsExisting = true;
//       canLoadMore = false;
//       lastVisibleOfTheBatch = docs[docs.length - 1];
//       _bookmarkedPosts += await getBookmarkedPosts(docs);
//     } else {
//       // isPostsExisting = true;
//       canLoadMore = true;
//       lastVisibleOfTheBatch = docs[docs.length - 1];
//       _bookmarkedPosts += await getBookmarkedPosts(docs);
//     }

//     final empathizedPostsIds = await getEmpathizedPostsIds();

//     addEmpathy(_bookmarkedPosts, empathizedPostsIds);
//     await getReplies(_bookmarkedPosts, empathizedPostsIds);

//     stopLoading();
//     notifyListeners();
//   }

//   Future<void> refreshThePostOfPostsAfterUpdated({
//     required Post oldPost,
//     required int indexOfPost,
//   }) async {
//     await refreshThePostAfterUpdated(
//       posts: _bookmarkedPosts,
//       oldPost: oldPost,
//       indexOfPost: indexOfPost,
//     );

//     notifyListeners();
//   }

//   void removeThePostOfPostsAfterDeleted(Post post) {
//     _bookmarkedPosts.remove(post);
//     notifyListeners();
//   }

//   void startLoading() {
//     isLoading = true;
//     notifyListeners();
//   }

//   void stopLoading() {
//     isLoading = false;
//     notifyListeners();
//   }

//   void startModalLoading() {
//     isModalLoading = true;
//     notifyListeners();
//   }

//   void stopModalLoading() {
//     isModalLoading = false;
//     notifyListeners();
//   }
// }
