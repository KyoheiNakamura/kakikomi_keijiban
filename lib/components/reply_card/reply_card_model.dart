import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';

class ReplyCardModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser?.uid;
  bool isLoading = false;
  bool isRepliesShown = false;

  void toggleIsRepliesShown() {
    isRepliesShown = !isRepliesShown;
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

  Future<void> deleteReplyToReply(Reply existingReply) async {
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
