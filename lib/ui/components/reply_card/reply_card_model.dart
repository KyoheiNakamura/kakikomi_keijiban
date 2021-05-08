import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';
import 'package:kakikomi_keijiban/entity/reply.dart';
import 'package:kakikomi_keijiban/entity/reply_to_reply.dart';

class ReplyCardModel extends ChangeNotifier {
  bool isLoading = false;

  Future<void> getRepliesToReply(Reply reply) async {
    final querySnapshot = await firestore
        .collection('users')
        .doc(reply.userId)
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

  void turnOnEmpathyButton(Reply reply) {
    reply.isEmpathized = true;
    notifyListeners();
  }

  void turnOffEmpathyButton(Reply reply) {
    reply.isEmpathized = false;
    notifyListeners();
  }

  // １回のみワカルできる
  Future<void> addEmpathizedPost(Reply reply) async {
    reply.empathyCount = reply.empathyCount + 1;
    notifyListeners();

    final userRef = firestore.collection('users').doc(auth.currentUser?.uid);
    final empathizedPostsRef =
        userRef.collection('empathizedPosts').doc(reply.id);
    await empathizedPostsRef.set({
      /// empathizedPosts自身のIDにはreplyIdと同じIDをsetしている
      'id': reply.id,
      'userId': reply.userId,
      'myEmpathyCount': 1,
      'createdAt': serverTimestamp(),
    });

    final replyRef = firestore
        .collection('users')
        .doc(reply.userId)
        .collection('posts')
        .doc(reply.postId)
        .collection('replies')
        .doc(reply.id);

    final replySnapshot = await replyRef.get();
    print(replySnapshot.data());
    final currentEmpathyCount = replySnapshot['empathyCount'];

    await replyRef.update({
      'empathyCount': currentEmpathyCount + 1,
    });
  }

  Future<void> deleteEmpathizedPost(Reply reply) async {
    reply.empathyCount = reply.empathyCount - 1;
    notifyListeners();

    final userRef = firestore.collection('users').doc(auth.currentUser?.uid);
    final empathizedPostsRef =
        userRef.collection('empathizedPosts').doc(reply.id);
    await empathizedPostsRef.delete();

    final replyRef = firestore
        .collection('users')
        .doc(reply.userId)
        .collection('posts')
        .doc(reply.postId)
        .collection('replies')
        .doc(reply.id);

    final replySnapshot = await replyRef.get();
    final currentEmpathyCount = replySnapshot['empathyCount'];

    if (currentEmpathyCount > 0) {
      await replyRef.update({
        'empathyCount': currentEmpathyCount - 1,
      });
    }
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
  //   final userRef = firestore.collection('users').doc(uid);
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
  //   final userRef = firestore.collection('users').doc(uid);
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
