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

  QueryDocumentSnapshot? lastVisibleOfTheBatch;
  int loadLimit = 10;
  // bool isPostsExisting = false;
  bool canLoadMore = false;
  bool isLoading = false;

  Future<void> refreshThePostOfPostsAfterUpdated({
    required Post oldPost,
    required int indexOfPost,
  }) async {
    // 更新後のpostを取得
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('posts')
        .doc(oldPost.id)
        .get();
    final newPost = Post(doc);
    // 更新前のpostをpostsから削除
    this._searchedPosts.removeAt(indexOfPost);
    // 更新後のpostをpostsに追加
    this._searchedPosts.insert(indexOfPost, newPost);
    notifyListeners();
  }

  void removeThePostOfPostsAfterDeleted(Post post) {
    this._searchedPosts.remove(post);
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

  Future<void> getPostsWithRepliesChosenField({
    required String postField,
    required String value,
  }) async {
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
    this._searchedPosts.clear();
    if (docs.length == 0) {
      // isPostsExisting = false;
      this.canLoadMore = false;
      this._searchedPosts = [];
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      this.canLoadMore = false;
      this.lastVisibleOfTheBatch = docs[docs.length - 1];
      this._searchedPosts = docs.map((doc) => Post(doc)).toList();
    } else {
      // isPostsExisting = true;
      this.canLoadMore = true;
      this.lastVisibleOfTheBatch = docs[docs.length - 1];
      this._searchedPosts = docs.map((doc) => Post(doc)).toList();
    }
    await _addBookmarkToPosts();
    await _getReplies();

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
      this.canLoadMore = false;
      this._searchedPosts = [];
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      this.canLoadMore = false;
      this.lastVisibleOfTheBatch = docs[docs.length - 1];
      this._searchedPosts = docs.map((doc) => Post(doc)).toList();
    } else {
      // isPostsExisting = true;
      this.canLoadMore = true;
      this.lastVisibleOfTheBatch = docs[docs.length - 1];
      this._searchedPosts = docs.map((doc) => Post(doc)).toList();
    }
    await _addBookmarkToPosts();
    await _getReplies();

    stopLoading();
    notifyListeners();
  }

  Future<void> _addBookmarkToPosts() async {
    final bookmarkedPostsSnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('bookmarkedPosts')
        // .orderBy('createdAt', descending: true)
        .get();

    final List<String> bookmarkedPostsIds = bookmarkedPostsSnapshot.docs
        .map((bookmarkedPost) => bookmarkedPost.id)
        .toList();
    for (int i = 0; i < posts.length; i++) {
      for (int n = 0; n < bookmarkedPostsIds.length; n++) {
        if (this._searchedPosts[i].id == bookmarkedPostsIds[n]) {
          this._searchedPosts[i].isBookmarked = true;
        }
      }
    }
  }

  Future<void> _getReplies() async {
    for (int i = 0; i < _searchedPosts.length; i++) {
      final post = _searchedPosts[i];
      final querySnapshot = await _firestore
          .collection('users')
          .doc(post.uid)
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
            .doc(reply.uid)
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
        reply.repliesToReply = _repliesToReplies;
      }
    }
  }
}
