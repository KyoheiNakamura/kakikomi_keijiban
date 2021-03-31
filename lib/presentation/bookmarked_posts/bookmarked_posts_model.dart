import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as Auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/domain/post.dart';

// class BookmarkedPostsModel extends ChangeNotifier {
// final _firestore = FirebaseFirestore.instance;
// final _auth = FirebaseAuth.instance;
// final uid = FirebaseAuth.instance.currentUser!.uid;
// Auth.User? loggedInUser;
//
// List<Post> _bookmarkedPosts = [];
// List<Post> get bookmarkedPosts => _bookmarkedPosts;
//
// Future<void> getBookmarkedPosts() async {
//   final bookmarkedPostsSnapshot = await _firestore
//       .collection('users')
//       .doc(uid)
//       .collection('bookmarkedPosts')
//       .orderBy('createdAt', descending: true)
//       .get();
//   final postSnapshotList = await Future.wait(bookmarkedPostsSnapshot.docs
//       .map((bookmarkedPost) => _firestore
//           .collectionGroup('posts')
//           .where('id', isEqualTo: bookmarkedPost['postId'])
//           // .orderBy('createdAt', descending: true)
//           .get())
//       .toList());
//   final bookmarkedPosts =
//       postSnapshotList.map((postSnapshot) => postSnapshot.docs[0]).toList();
//   print(bookmarkedPosts);
//   _bookmarkedPosts = bookmarkedPosts.map((doc) => Post(doc)).toList();
//   for (int i = 0; i < _bookmarkedPosts.length; i++) {
//     _bookmarkedPosts[i].isBookmarked = true;
//   }
//   notifyListeners();
// }

// Future<void> deleteBookmarkedPost(Post post) async {
//   final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
//   final bookmarkedPosts = userRef.collection('bookmarkedPosts').doc(post.id);
//   await bookmarkedPosts.delete();
// }
// }
