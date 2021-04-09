import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';

class PostCardModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser?.uid;
  bool isLoading = false;

  void startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void stopLoading() {
    isLoading = false;
    notifyListeners();
  }

  Future<void> addBookmarkedPost(Post post) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final bookmarkedPostRef =
        userRef.collection('bookmarkedPosts').doc(post.id);
    await bookmarkedPostRef.set({
      /// bookmarkedPosts自身のIDにはpostIdと同じIDをsetしている
      'userId': bookmarkedPostRef.id,
      'postId': post.id,
      // 'postRef': userRef.collection('posts').doc(post.id),
      'createdAt': FieldValue.serverTimestamp(),
    });
    notifyListeners();
  }

  Future<void> deleteBookmarkedPost(Post post) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final bookmarkedPosts = userRef.collection('bookmarkedPosts').doc(post.id);
    await bookmarkedPosts.delete();
    notifyListeners();
  }

  Future<void> _deleteBookmarkedPostsForAllUsers(Post post) async {
    List<Future> futures = [];
    final querySnapshot = await _firestore
        .collectionGroup('bookmarkedPosts')
        .where('postId', isEqualTo: post.id)
        .get();
    final bookmarkedPosts =
        querySnapshot.docs.map((doc) => doc.reference).toList();
    for (int i = 0; i < bookmarkedPosts.length; i++) {
      futures.add(bookmarkedPosts[i].delete());
    }
    await Future.wait(futures);
  }

  Future<void> deletePostAndReplies(Post post) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final _post = userRef.collection('posts').doc(post.id);
    await _post.delete();
    await _deleteBookmarkedPostsForAllUsers(post);
    final replies = (await _post.collection('replies').get()).docs;
    for (int i = 0; i < replies.length; i++) {
      replies[i].reference.delete();
    }
    notifyListeners();
  }

  Future<void> deleteReply(Reply existingReply) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final postRef = userRef.collection('posts').doc(existingReply.postId);
    final reply = postRef.collection('replies').doc(existingReply.id);
    await reply.delete();

    final DocumentSnapshot postDoc = await postRef.get();
    await postRef.update({
      'replyCount': postDoc['replyCount'] - 1,
    });
    notifyListeners();
  }
}
