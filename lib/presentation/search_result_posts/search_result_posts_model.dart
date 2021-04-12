import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';
import 'package:kakikomi_keijiban/domain/reply_to_reply.dart';

class SearchResultPostsModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser?.uid;

  List<Post> _searchedPosts = [];
  List<Post> get posts => _searchedPosts;

  Map<String, List<Reply>> _repliesToSearchedPosts = {};
  Map<String, List<Reply>> get replies => _repliesToSearchedPosts;

  List<Reply> _rawReplies = [];
  Map<String, List<ReplyToReply>> _repliesToReply = {};
  Map<String, List<ReplyToReply>> get repliesToReply => _repliesToReply;

  QueryDocumentSnapshot? lastVisibleOfTheBatch;
  int loadLimit = 10;
  // bool isPostsExisting = false;
  bool canLoadMore = false;
  bool isLoading = false;

  void startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void stopLoading() {
    isLoading = false;
    notifyListeners();
  }

  Future<void> getPostsWithRepliesChosenField(
      {required String postField, required String value}) async {
    startLoading();

    final Query queryBatch;
    // postのfieldの値が配列(array)のとき
    // Todo positionも複数選択に変える予定なので、おいおいこっちの条件に||で追加するはず
    if (postField == 'categories') {
      queryBatch = _firestore
          .collectionGroup('posts')
          .where(postField, arrayContains: value)
          .orderBy('createdAt', descending: true)
          .limit(loadLimit);
    } else {
      queryBatch = _firestore
          .collectionGroup('posts')
          .where(postField, isEqualTo: value)
          .orderBy('createdAt', descending: true)
          .limit(loadLimit);
    }
    final querySnapshot = await queryBatch.get();
    final docs = querySnapshot.docs;
    _searchedPosts.clear();
    this._rawReplies.clear();
    if (docs.length == 0) {
      // isPostsExisting = false;
      canLoadMore = false;
      _searchedPosts = [];
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      canLoadMore = false;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      _searchedPosts = docs.map((doc) => Post(doc)).toList();
    } else {
      // isPostsExisting = true;
      canLoadMore = true;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      _searchedPosts = docs.map((doc) => Post(doc)).toList();
    }
    await _addBookmarkToPosts();
    await _getRepliesToPosts();
    await _getRepliesToReplies();

    stopLoading();
    notifyListeners();
  }

  Future<void> loadPostsWithRepliesChosenField(
      {required String postField, required String value}) async {
    startLoading();

    final Query queryBatch;
    // postのfieldの値が配列(array)のとき
    // Todo positionも複数選択に変える予定なので、おいおいこっちの条件に||で追加するはず
    if (postField == 'categories') {
      queryBatch = _firestore
          .collectionGroup('posts')
          .where(postField, arrayContains: value)
          .orderBy('createdAt', descending: true)
          .startAfterDocument(lastVisibleOfTheBatch!)
          .limit(loadLimit);
    } else {
      queryBatch = _firestore
          .collectionGroup('posts')
          .where(postField, isEqualTo: value)
          .orderBy('createdAt', descending: true)
          .startAfterDocument(lastVisibleOfTheBatch!)
          .limit(loadLimit);
    }
    final querySnapshot = await queryBatch.get();
    final docs = querySnapshot.docs;
    if (docs.length == 0) {
      // isPostsExisting = false;
      canLoadMore = false;
      _searchedPosts = [];
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      canLoadMore = false;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      _searchedPosts = docs.map((doc) => Post(doc)).toList();
    } else {
      // isPostsExisting = true;
      canLoadMore = true;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      _searchedPosts = docs.map((doc) => Post(doc)).toList();
    }
    await _addBookmarkToPosts();
    await _getRepliesToPosts();
    await _getRepliesToReplies();

    stopLoading();
    notifyListeners();
  }

  Future<void> _getRepliesToPosts() async {
    if (_searchedPosts.isNotEmpty) {
      for (final post in _searchedPosts) {
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
        this._rawReplies += replies;
        _repliesToSearchedPosts[post.id] = replies;
      }
    }
  }

  Future<void> _getRepliesToReplies() async {
    if (_rawReplies.isNotEmpty) {
      for (final reply in _rawReplies) {
        final querySnapshot = await _firestore
            .collection('users')
            .doc(reply.uid)
            .collection('posts')
            .doc(reply.postId)
            .collection('replies')
            .doc(reply.id)
            .collection('repliesToReply')
            .orderBy('createdAt')
            .get();
        final docs = querySnapshot.docs;
        final repliesToReply = docs.map((doc) => ReplyToReply(doc)).toList();
        _repliesToReply[reply.id] = repliesToReply;
      }
    }
  }

  Future<void> _addBookmarkToPosts() async {
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

    for (int i = 0; i < _searchedPosts.length; i++) {
      for (QueryDocumentSnapshot bookmarkedPostDoc in bookmarkedPostDocs) {
        if (_searchedPosts[i].id == bookmarkedPostDoc.id) {
          _searchedPosts[i].isBookmarked = true;
        }
      }
    }
  }
}
