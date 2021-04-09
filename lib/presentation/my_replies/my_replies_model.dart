import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';

class MyRepliesModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser?.uid;

  List<Post> _postsWithMyReplies = [];
  List<Post> get posts => _postsWithMyReplies;

  Map<String, List<Reply>> _repliesToMyPosts = {};
  Map<String, List<Reply>> get replies => _repliesToMyPosts;

  Future<void> get getPostsWithReplies => _getPostsWithMyReplies();
  Future<void> get loadPostsWithReplies => _loadPostsWithMyReplies();

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

  Future<void> _getPostsWithMyReplies() async {
    startLoading();

    Query queryBatch = _firestore
        .collectionGroup('replies')
        .where('replierId', isEqualTo: uid)
        .orderBy('updatedAt', descending: true)
        .limit(loadLimit);
    final querySnapshot = await queryBatch.get();
    final docs = querySnapshot.docs;
    _postsWithMyReplies.clear();
    if (docs.length == 0) {
      // isPostsExisting = false;
      canLoadMore = false;
      _postsWithMyReplies = [];
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      canLoadMore = false;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      _postsWithMyReplies = await _getRepliedPosts(docs);
    } else {
      // isPostsExisting = true;
      canLoadMore = true;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      _postsWithMyReplies = await _getRepliedPosts(docs);
    }
    await _addBookmarkToPosts();
    await _getRepliesToPosts();

    stopLoading();
    notifyListeners();
  }

  Future<void> _loadPostsWithMyReplies() async {
    startLoading();

    Query queryBatch = _firestore
        .collectionGroup('replies')
        .where('replierId', isEqualTo: uid)
        .orderBy('updatedAt', descending: true)
        .startAfterDocument(lastVisibleOfTheBatch!)
        .limit(loadLimit);
    final querySnapshot = await queryBatch.get();
    final docs = querySnapshot.docs;
    if (docs.length == 0) {
      // isPostsExisting = false;
      canLoadMore = false;
      _postsWithMyReplies += [];
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      canLoadMore = false;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      _postsWithMyReplies += await _getRepliedPosts(docs);
    } else {
      // isPostsExisting = true;
      canLoadMore = true;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      _postsWithMyReplies += await _getRepliedPosts(docs);
    }
    await _addBookmarkToPosts();
    await _getRepliesToPosts();

    stopLoading();
    notifyListeners();
  }

  Future<List<Post>> _getRepliedPosts(List<QueryDocumentSnapshot> docs) async {
    final postSnapshots = await Future.wait(docs
        .map((repliedPost) => _firestore
            .collectionGroup('posts')
            .where('id', isEqualTo: repliedPost['postId'])
            .get())
        .toList());
    final repliedPostDocs =
        postSnapshots.map((postSnapshot) => postSnapshot.docs[0]).toList();
    return repliedPostDocs.map((doc) => Post(doc)).toList();
  }

  Future<void> _addBookmarkToPosts() async {
    // List<Post> _bookmarkedPosts = [];
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

    // これで十分疑惑
    for (int i = 0; i < _postsWithMyReplies.length; i++) {
      for (QueryDocumentSnapshot bookmarkedPostDoc in bookmarkedPostDocs) {
        if (_postsWithMyReplies[i].id == bookmarkedPostDoc.id) {
          _postsWithMyReplies[i].isBookmarked = true;
        }
      }
    }
  }

  Future<void> _getRepliesToPosts() async {
    if (_postsWithMyReplies.isNotEmpty) {
      for (final post in _postsWithMyReplies) {
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
        _repliesToMyPosts[post.id] = replies;
      }
    }
  }
}
