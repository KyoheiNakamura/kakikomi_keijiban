import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';

class SearchResultPostsModel extends ChangeNotifier {
  static final searchPage = 'SearchPage';
  final _firestore = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser?.uid;

  List<Post> _searchedPosts = [];
  List<Post> get searchedPosts => _searchedPosts;

  Map<String, List<Reply>> _repliesToSearchedPosts = {};
  Map<String, List<Reply>> get repliesToSearchedPosts =>
      _repliesToSearchedPosts;

  List<Post> _bookmarkedPosts = [];
  List<Post> get bookmarkedPosts => _bookmarkedPosts;

  Future<void> getPostsWithRepliesChosenField(
      {required String postField, required String value}) async {
    final QuerySnapshot querySnapshot;
    // postのfieldの値が配列(array)のとき
    // Todo positionも複数選択に変える予定なので、おいおいこっちの条件に||で追加するはず
    if (postField == 'categories') {
      querySnapshot = await _firestore
          .collectionGroup('posts')
          .where(postField, arrayContains: value)
          .orderBy('createdAt', descending: true)
          .get();
    } else {
      querySnapshot = await _firestore
          .collectionGroup('posts')
          .where(postField, isEqualTo: value)
          .orderBy('createdAt', descending: true)
          .get();
    }
    final docs = querySnapshot.docs;
    final posts = docs.map((doc) => Post(doc)).toList();
    _searchedPosts = posts;
    await _getBookmarkedPosts();
    for (int i = 0; i < _searchedPosts.length; i++) {
      for (Post bookmarkedPost in _bookmarkedPosts) {
        if (_searchedPosts[i].id == bookmarkedPost.id) {
          _searchedPosts[i].isBookmarked = true;
        }
      }
    }
    for (final post in posts) {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(post.uid)
          .collection('posts')
          .doc(post.id)
          .collection('replies')
          .orderBy('createdAt')
          .get();
      final docs = querySnapshot.docs;
      final replies = docs.map((doc) => Reply(doc)).toList();
      _repliesToSearchedPosts[post.id] = replies;
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
