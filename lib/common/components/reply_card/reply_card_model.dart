import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';
import 'package:kakikomi_keijiban/domain/reply_to_reply.dart';

class ReplyCardModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser?.uid;
  bool isLoading = false;

  Future<void> getRepliesToReply(Reply reply) async {
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
    reply.repliesToReply = repliesToReply;
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

  // Future<void> deleteReplyToReply(ReplyToReply replyToReply) async {
  //   final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
  //   final postRef = userRef.collection('posts').doc(replyToReply.postId);
  //   final replyRef = postRef.collection('replies').doc(replyToReply.replyId);
  //   final replyToRepliesRef =
  //       replyRef.collection('repliesToReply').doc(replyToReply.id);
  //   await replyToRepliesRef.delete();
  //
  //   final DocumentSnapshot postDoc = await postRef.get();
  //   await postRef.update({
  //     'replyCount': postDoc['replyCount'] - 1,
  //   });
  //   notifyListeners();
  // }
  //
  // Future<void> deleteReplyAndRepliesToReply(Reply existingReply) async {
  //   final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
  //   final postRef = userRef.collection('posts').doc(existingReply.postId);
  //   final replyRef = postRef.collection('replies').doc(existingReply.id);
  //
  //   await replyRef.delete();
  //   final repliesToReply =
  //       (await replyRef.collection('repliesToReply').get()).docs;
  //   for (int i = 0; i < repliesToReply.length; i++) {
  //     repliesToReply[i].reference.delete();
  //   }
  //
  //   final numberOfRepliesToReply = existingReply.repliesToReply.length;
  //   final DocumentSnapshot postDoc = await postRef.get();
  //   await postRef.update({
  //     'replyCount': postDoc['replyCount'] - (1 + numberOfRepliesToReply),
  //   });
  //   notifyListeners();
  // }
}
