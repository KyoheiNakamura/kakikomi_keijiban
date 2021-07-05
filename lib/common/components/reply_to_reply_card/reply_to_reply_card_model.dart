import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';
import 'package:kakikomi_keijiban/entity/reply.dart';
import 'package:kakikomi_keijiban/entity/reply_to_reply.dart';

class ReplyToReplyCardModel extends ChangeNotifier {
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
    // replyドメインにrepliesToReplyを持たせているので、postCardでreply.repliesToReplyに入れてやる
    reply.repliesToReply = repliesToReply;
    notifyListeners();
  }

  void turnOnEmpathyButton(ReplyToReply replyToReply) {
    replyToReply.isEmpathized = true;
    notifyListeners();
  }

  void turnOffEmpathyButton(ReplyToReply replyToReply) {
    replyToReply.isEmpathized = false;
    notifyListeners();
  }

  // １回のみワカルできる
  Future<void> addEmpathizedPost(ReplyToReply replyToReply) async {
    replyToReply.empathyCount = replyToReply.empathyCount + 1;
    notifyListeners();

    final userRef = firestore.collection('users').doc(auth.currentUser?.uid);
    final empathizedPostsRef =
        userRef.collection('empathizedPosts').doc(replyToReply.id);
    await empathizedPostsRef.set(<String, dynamic>{
      /// empathizedPosts自身のIDにはreplyToReplyIdと同じIDをsetしている
      'id': replyToReply.id,
      'userId': replyToReply.userId,
      'myEmpathyCount': 1,
      'createdAt': serverTimestamp(),
    });

    final replyToReplyRef = firestore
        .collection('users')
        .doc(replyToReply.userId)
        .collection('posts')
        .doc(replyToReply.postId)
        .collection('replies')
        .doc(replyToReply.replyId)
        .collection('repliesToReply')
        .doc(replyToReply.id);

    final replyToReplySnapshot = await replyToReplyRef.get();
    final currentEmpathyCount = replyToReplySnapshot['empathyCount'] as int;

    await replyToReplyRef.update(<String, int>{
      'empathyCount': currentEmpathyCount + 1,
    });
  }

  Future<void> deleteEmpathizedPost(ReplyToReply replyToReply) async {
    replyToReply.empathyCount = replyToReply.empathyCount - 1;
    notifyListeners();

    final userRef = firestore.collection('users').doc(auth.currentUser?.uid);
    final empathizedPostsRef =
        userRef.collection('empathizedPosts').doc(replyToReply.id);
    await empathizedPostsRef.delete();

    final replyToReplyRef = firestore
        .collection('users')
        .doc(replyToReply.userId)
        .collection('posts')
        .doc(replyToReply.postId)
        .collection('replies')
        .doc(replyToReply.replyId)
        .collection('repliesToReply')
        .doc(replyToReply.id);

    final replyToReplySnapshot = await replyToReplyRef.get();
    final currentEmpathyCount = replyToReplySnapshot['empathyCount'] as int;

    if (currentEmpathyCount > 0) {
      await replyToReplyRef.update(<String, int>{
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
  //   final userRef =
  //       firestore.collection('users').doc(replyToReply.userId);
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
  //   final userRef = firestore
  //       .collection('users')
  //       .doc(existingReply.userId);
  //   final postRef = userRef.collection('posts').doc(existingReply.postId);
  //   final replyRef = postRef.collection('replies').doc(existingReply.id);
  //   await replyRef.delete();
  //   final repliesToReply =
  //       (await replyRef.collection('repliesToReply').get()).docs;
  //   for (int i = 0; i < repliesToReply.length; i++) {
  //     repliesToReply[i].reference.delete();
  //   }
  //
  //   final DocumentSnapshot postDoc = await postRef.get();
  //   await postRef.update({
  //     'replyCount': postDoc['replyCount'] - 1,
  //   });
  //   notifyListeners();
  // }
}
