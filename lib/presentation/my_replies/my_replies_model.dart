import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';
import 'package:kakikomi_keijiban/common/mixin/provide_common_posts_method_mixin.dart';
import 'package:kakikomi_keijiban/domain/post.dart';

class MyRepliesModel extends ChangeNotifier with ProvideCommonPostsMethodMixin {
  List<Post> _postsWithMyReplies = [];
  List<Post> get posts => _postsWithMyReplies;

  Future<void> get getPostsWithReplies => _getPostsWithMyReplies();
  Future<void> get loadPostsWithReplies => _loadPostsWithMyReplies();

  QueryDocumentSnapshot? lastVisibleOfTheBatch;
  int loadLimit = 10;
  // bool isPostsExisting = false;
  bool canLoadMore = false;
  bool isLoading = false;
  bool isModalLoading = false;

  Future<void> init() async {
    startModalLoading();
    await _getPostsWithMyReplies();
    stopModalLoading();
  }

  Future<void> _getPostsWithMyReplies() async {
    startLoading();

    Query queryBatch = firestore
        .collectionGroup('replies')
        .where('replierId', isEqualTo: auth.currentUser?.uid)
        .orderBy('updatedAt', descending: true)
        .limit(loadLimit);
    final querySnapshot = await queryBatch.get();
    final docs = querySnapshot.docs;
    this._postsWithMyReplies.clear();
    if (docs.length == 0) {
      // isPostsExisting = false;
      this.canLoadMore = false;
      this._postsWithMyReplies = [];
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      this.canLoadMore = false;
      this.lastVisibleOfTheBatch = docs[docs.length - 1];
      this._postsWithMyReplies = await _getRepliedPosts(docs);
    } else {
      // isPostsExisting = true;
      this.canLoadMore = true;
      this.lastVisibleOfTheBatch = docs[docs.length - 1];
      this._postsWithMyReplies = await _getRepliedPosts(docs);
    }

    final bookmarkedPostsIds = await getBookmarkedPostsIds();
    final empathizedPostsIds = await getEmpathizedPostsIds();

    await addBookmark(this._postsWithMyReplies, bookmarkedPostsIds);
    await addEmpathy(this._postsWithMyReplies, empathizedPostsIds);
    await getReplies(this._postsWithMyReplies, empathizedPostsIds);

    stopLoading();
    notifyListeners();
  }

  Future<void> _loadPostsWithMyReplies() async {
    startLoading();

    Query queryBatch = firestore
        .collectionGroup('replies')
        .where('replierId', isEqualTo: auth.currentUser?.uid)
        .orderBy('updatedAt', descending: true)
        .startAfterDocument(lastVisibleOfTheBatch!)
        .limit(loadLimit);
    final querySnapshot = await queryBatch.get();
    final docs = querySnapshot.docs;
    if (docs.length == 0) {
      // isPostsExisting = false;
      this.canLoadMore = false;
      this._postsWithMyReplies += [];
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      this.canLoadMore = false;
      this.lastVisibleOfTheBatch = docs[docs.length - 1];
      this._postsWithMyReplies += await _getRepliedPosts(docs);
    } else {
      // isPostsExisting = true;
      this.canLoadMore = true;
      this.lastVisibleOfTheBatch = docs[docs.length - 1];
      this._postsWithMyReplies += await _getRepliedPosts(docs);
    }

    final bookmarkedPostsIds = await getBookmarkedPostsIds();
    final empathizedPostsIds = await getEmpathizedPostsIds();

    await addBookmark(this._postsWithMyReplies, bookmarkedPostsIds);
    await addEmpathy(this._postsWithMyReplies, empathizedPostsIds);
    await getReplies(this._postsWithMyReplies, empathizedPostsIds);

    stopLoading();
    notifyListeners();
  }

  Future<List<Post>> _getRepliedPosts(List<QueryDocumentSnapshot> docs) async {
    final postSnapshots = await Future.wait(docs
        .map((repliedPost) => firestore
            .collectionGroup('posts')
            .where('id', isEqualTo: repliedPost['postId'])
            .get())
        .toList());
    final repliedPostDocs =
        postSnapshots.map((postSnapshot) => postSnapshot.docs[0]).toList();
    List<Post> repliedPosts = repliedPostDocs.map((doc) => Post(doc)).toList();
    return repliedPosts;
  }

  Future<void> refreshThePostOfPostsAfterUpdated({
    required Post oldPost,
    required int indexOfPost,
  }) async {
    await refreshThePostAfterUpdated(
      posts: this._postsWithMyReplies,
      oldPost: oldPost,
      indexOfPost: indexOfPost,
    );

    notifyListeners();
  }

  void removeThePostOfPostsAfterDeleted(Post post) {
    this._postsWithMyReplies.remove(post);
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
