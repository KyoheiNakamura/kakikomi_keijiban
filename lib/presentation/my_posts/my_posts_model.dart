import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';
import 'package:kakikomi_keijiban/domain/reply_to_reply.dart';

class MyPostsModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Post> _myPosts = [];
  List<Post> get posts => _myPosts;

  Future<void> get getPostsWithReplies => _getMyPostsWithReplies();
  Future<void> get loadPostsWithReplies => _loadMyPostsWithReplies();

  QueryDocumentSnapshot? lastVisibleOfTheBatch;
  int loadLimit = 10;
  // bool isPostsExisting = false;
  bool canLoadMore = false;
  bool isLoading = false;
  bool isModalLoading = false;

  Future<void> init() async {
    startModalLoading();
    await _getMyPostsWithReplies();
    stopModalLoading();
  }

  Future<void> _getMyPostsWithReplies() async {
    startLoading();

    Query queryBatch = _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('posts')
        .orderBy('updatedAt', descending: true)
        .limit(loadLimit);
    final querySnapshot = await queryBatch.get();
    final docs = querySnapshot.docs;
    this._myPosts.clear();
    if (docs.length == 0) {
      // isPostsExisting = false;
      this.canLoadMore = false;
      this._myPosts = [];
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      this.canLoadMore = false;
      this.lastVisibleOfTheBatch = docs[docs.length - 1];
      this._myPosts = docs.map((doc) => Post(doc)).toList();
    } else {
      // isPostsExisting = true;
      this.canLoadMore = true;
      this.lastVisibleOfTheBatch = docs[docs.length - 1];
      this._myPosts = docs.map((doc) => Post(doc)).toList();
    }
    await _addBookmarkToPosts();
    await _addEmpathyToMyPosts();
    await _getReplies();

    stopLoading();
    notifyListeners();
  }

  Future<void> _loadMyPostsWithReplies() async {
    startLoading();

    Query queryBatch = _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('posts')
        .orderBy('updatedAt', descending: true)
        .startAfterDocument(lastVisibleOfTheBatch!)
        .limit(loadLimit);
    final querySnapshot = await queryBatch.get();
    final docs = querySnapshot.docs;
    if (docs.length == 0) {
      // isPostsExisting = false;
      this.canLoadMore = false;
      this._myPosts += [];
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      this.canLoadMore = false;
      this.lastVisibleOfTheBatch = docs[docs.length - 1];
      this._myPosts += docs.map((doc) => Post(doc)).toList();
    } else {
      // isPostsExisting = true;
      this.canLoadMore = true;
      this.lastVisibleOfTheBatch = docs[docs.length - 1];
      this._myPosts += docs.map((doc) => Post(doc)).toList();
    }
    await _addBookmarkToPosts();
    await _addEmpathyToMyPosts();
    await _getReplies();

    stopLoading();
    notifyListeners();
  }

  Future<void> _addEmpathyToMyPosts() async {
    final empathizedPostsSnapshot = await _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('empathizedPosts')
        .get();
    final List<String> empathizedPostsIds = empathizedPostsSnapshot.docs
        .map((empathizedPost) => empathizedPost.id)
        .toList();
    for (int i = 0; i < this._myPosts.length; i++) {
      for (int n = 0; n < empathizedPostsIds.length; n++) {
        if (this._myPosts[i].id == empathizedPostsIds[n]) {
          this._myPosts[i].isEmpathized = true;
        }
      }
    }
  }

  Future<void> _addBookmarkToPosts() async {
    final bookmarkedPostsSnapshot = await _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('bookmarkedPosts')
        // .orderBy('createdAt', descending: true)
        .get();
    final List<String> bookmarkedPostsIds = bookmarkedPostsSnapshot.docs
        .map((bookmarkedPost) => bookmarkedPost.id)
        .toList();
    for (int i = 0; i < posts.length; i++) {
      for (int n = 0; n < bookmarkedPostsIds.length; n++) {
        if (this._myPosts[i].id == bookmarkedPostsIds[n]) {
          this._myPosts[i].isBookmarked = true;
        }
      }
    }
  }

  Future<List<String>> _getEmpathizedPostsIds() async {
    final empathizedPostsSnapshot = await _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('empathizedPosts')
        .get();
    final List<String> empathizedPostsIds = empathizedPostsSnapshot.docs
        .map((empathizedPost) => empathizedPost.id)
        .toList();
    return empathizedPostsIds;
  }

  Future<void> _getReplies() async {
    final List<String> empathizedPostsIds = await _getEmpathizedPostsIds();
    for (int i = 0; i < _myPosts.length; i++) {
      final post = _myPosts[i];
      final querySnapshot = await _firestore
          .collection('users')
          .doc(post.userId)
          .collection('posts')
          .doc(post.id)
          .collection('replies')
          .orderBy('createdAt')
          .get();
      final docs = querySnapshot.docs;
      final _replies = docs.map((doc) => Reply(doc)).toList();
      for (int i = 0; i < _replies.length; i++) {
        for (int n = 0; n < empathizedPostsIds.length; n++) {
          if (_replies[i].id == empathizedPostsIds[n]) {
            _replies[i].isEmpathized = true;
          }
        }
      }
      post.replies = _replies;

      for (int i = 0; i < _replies.length; i++) {
        final reply = _replies[i];
        final _querySnapshot = await _firestore
            .collection('users')
            .doc(reply.userId)
            .collection('posts')
            .doc(reply.postId)
            .collection('replies')
            .doc(reply.id)
            .collection('repliesToReply')
            .orderBy('createdAt')
            .get();
        final _docs = _querySnapshot.docs;
        final _repliesToReplies =
            _docs.map((doc) => ReplyToReply(doc)).toList();
        for (int i = 0; i < _repliesToReplies.length; i++) {
          for (int n = 0; n < empathizedPostsIds.length; n++) {
            if (_repliesToReplies[i].id == empathizedPostsIds[n]) {
              _repliesToReplies[i].isEmpathized = true;
            }
          }
        }
        reply.repliesToReply = _repliesToReplies;
      }
    }
  }

  Future<void> refreshThePostOfPostsAfterUpdated({
    required Post oldPost,
    required int indexOfPost,
  }) async {
    // 更新後のpostを取得
    final doc = await _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('posts')
        .doc(oldPost.id)
        .get();
    final post = Post(doc);
    final querySnapshot = await _firestore
        .collection('users')
        .doc(post.userId)
        .collection('posts')
        .doc(post.id)
        .collection('replies')
        .orderBy('createdAt')
        .get();
    final docs = querySnapshot.docs;
    final _replies = docs.map((doc) => Reply(doc)).toList();
    post.replies = _replies;

    for (int i = 0; i < _replies.length; i++) {
      final reply = _replies[i];
      final _querySnapshot = await _firestore
          .collection('users')
          .doc(reply.userId)
          .collection('posts')
          .doc(reply.postId)
          .collection('replies')
          .doc(reply.id)
          .collection('repliesToReply')
          .orderBy('createdAt')
          .get();
      final _docs = _querySnapshot.docs;
      final _repliesToReplies = _docs.map((doc) => ReplyToReply(doc)).toList();
      reply.repliesToReply = _repliesToReplies;
    }

    // 更新前のpostをpostsから削除
    this._myPosts.removeAt(indexOfPost);
    // 更新後のpostをpostsに追加
    this._myPosts.insert(indexOfPost, post);

    notifyListeners();
  }

  void removeThePostOfPostsAfterDeleted(Post post) {
    this._myPosts.remove(post);
    notifyListeners();
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
