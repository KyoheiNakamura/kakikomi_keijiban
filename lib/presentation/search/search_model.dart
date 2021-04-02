import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';

class SearchModel extends ChangeNotifier {
  static final searchPage = 'SearchPage';
  final _firestore = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser?.uid;

  List<Post> _chosenCategoryPosts = [];
  List<Post> get chosenCategoryPosts => _chosenCategoryPosts;

  Map<String, List<Reply>> _repliesToChosenCategoryPosts = {};
  Map<String, List<Reply>> get repliesToChosenCategoryPosts =>
      _repliesToChosenCategoryPosts;

  List<Post> _bookmarkedPosts = [];
  List<Post> get bookmarkedPosts => _bookmarkedPosts;

  Future<void> getPostsWithRepliesChosenCategory(String category) async {
    final querySnapshot = await _firestore
        .collectionGroup('posts')
        .where('categories', arrayContains: category)
        .orderBy('createdAt', descending: true)
        .get();
    final docs = querySnapshot.docs;
    final posts = docs.map((doc) => Post(doc)).toList();
    _chosenCategoryPosts = posts;
    // ブックマークを付けてる
    await _getBookmarkedPosts();
    for (int i = 0; i < _chosenCategoryPosts.length; i++) {
      for (Post bookmarkedPost in _bookmarkedPosts) {
        if (_chosenCategoryPosts[i].id == bookmarkedPost.id) {
          _chosenCategoryPosts[i].isBookmarked = true;
        }
      }
    }
    for (final post in posts) {
      final querySnapshot = await _firestore
          .collectionGroup('replies')
          .where('postId', isEqualTo: post.id)
          .orderBy('createdAt')
          .get();
      final docs = querySnapshot.docs;
      final replies = docs.map((doc) => Reply(doc)).toList();
      _repliesToChosenCategoryPosts[post.id] = replies;
    }
    notifyListeners();
  }

  Future<void> _getBookmarkedPosts() async {
    final bookmarkedPostsSnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('bookmarkedPosts')
        .orderBy('createdAt', descending: true)
        .get();
    final postSnapshots = await Future.wait(bookmarkedPostsSnapshot.docs
        .map((bookmarkedPost) => _firestore
            .collectionGroup('posts')
            .where('id', isEqualTo: bookmarkedPost['postId'])
            // .orderBy('createdAt', descending: true)
            .get())
        .toList());
    final bookmarkedPostDocs =
        postSnapshots.map((postSnapshot) => postSnapshot.docs[0]).toList();
    _bookmarkedPosts = bookmarkedPostDocs.map((doc) => Post(doc)).toList();
  }
}
