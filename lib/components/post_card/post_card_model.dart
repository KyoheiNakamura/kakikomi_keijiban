import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';

class PostCardModel extends ChangeNotifier {
  final uid = FirebaseAuth.instance.currentUser?.uid;

  Future<void> addBookmarkedPost(Post post) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final bookmarkedPostRef =
        userRef.collection('bookmarkedPosts').doc(post.id);
    await bookmarkedPostRef.set({
      'postId': post.id,
      'postRef': userRef.collection('posts').doc(post.id),
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

  Future<void> deletePostAndReplies(Post post) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final _post = userRef.collection('posts').doc(post.id);
    final replies = (await _post.collection('replies').get()).docs;
    for (int i = 0; i < replies.length; i++) {
      replies[i].reference.delete();
    }
    await _post.delete();
    notifyListeners();
  }

  Future<void> deleteReply(Reply existingReply) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final post = userRef.collection('posts').doc(existingReply.postId);
    final reply = post.collection('replies').doc(existingReply.id);
    await reply.delete();
    notifyListeners();
  }
}
