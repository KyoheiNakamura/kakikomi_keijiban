import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';

class BookmarkedPostsModel extends ChangeNotifier {
  static final bookmarkedPostsPage = 'BookmarkedPostsPage';
  final _firestore = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  List<Post> _bookmarkedPosts = [];
  List<Post> get posts => _bookmarkedPosts;

  Map<String, List<Reply>> _repliesToBookmarkedPosts = {};
  Map<String, List<Reply>> get replies => _repliesToBookmarkedPosts;

  Future<void> get getPostsWithReplies => _getBookmarkedPostsWithReplies();

  Future<void> _getBookmarkedPostsWithReplies() async {
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
    for (int i = 0; i < _bookmarkedPosts.length; i++) {
      _bookmarkedPosts[i].isBookmarked = true;
    }
    for (final bookmarkedPost in _bookmarkedPosts) {
      // final querySnapshot = await _firestore
      //     .collectionGroup('replies')
      //     .where('postId', isEqualTo: bookmarkedPost.id)
      //     .orderBy('createdAt')
      //     .get();
      final querySnapshot = await _firestore
          .collection('users')
          .doc(bookmarkedPost.uid)
          .collection('posts')
          .doc(bookmarkedPost.id)
          .collection('replies')
          .orderBy('createdAt')
          .get();
      final docs = querySnapshot.docs;
      final replies = docs.map((doc) => Reply(doc)).toList();
      _repliesToBookmarkedPosts[bookmarkedPost.id] = replies;
    }
    notifyListeners();
  }

  Future<void> deleteBookmarkedPost(Post post) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final bookmarkedPosts = userRef.collection('bookmarkedPosts').doc(post.id);
    await bookmarkedPosts.delete();
  }
}
