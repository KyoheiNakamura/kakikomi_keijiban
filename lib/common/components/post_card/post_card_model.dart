import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';
import 'package:kakikomi_keijiban/domain/reply_to_reply.dart';

class PostCardModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;
  final List<Reply> repliesToPost = [];

  Future<void> getAllRepliesToPost(Post post) async {
    final querySnapshot = await _firestore
        .collection('users')
        .doc(post.userId)
        .collection('posts')
        .doc(post.id)
        .collection('replies')
        .orderBy('createdAt')
        .get();
    final docs = querySnapshot.docs;
    final replies = docs.map((doc) => Reply(doc)).toList();
    // postドメインにrepliesを持たせているので、postCardでpost.repliesに入れてやってる
    post.replies = replies;

    for (int i = 0; i < replies.length; i++) {
      final reply = replies[i];
      final _querySnapshot = await _firestore
          .collection('users')
          .doc(reply.userId)
          .collection('posts')
          .doc(reply.postId)
          .collection('replies')
          .doc(reply.id)
          .collection('repliesToReply')
          .orderBy('createdAt')
          .get();
      final _docs = _querySnapshot.docs;
      final _repliesToReplies = _docs.map((doc) => ReplyToReply(doc)).toList();
      // replyドメインにrepliesToReplyを持たせているので、postCardでreply.repliesToReplyに入れてやってる
      reply.repliesToReply = _repliesToReplies;
    }
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

  void openReplies(Post post) {
    post.isReplyShown = true;
    notifyListeners();
  }

  void closeReplies(Post post) {
    post.isReplyShown = false;
    notifyListeners();
  }

  void turnOnStar(Post post) {
    post.isBookmarked = true;
    notifyListeners();
  }

  void turnOffStar(Post post) {
    post.isBookmarked = false;
    notifyListeners();
  }

  Future<void> addBookmarkedPost(Post post) async {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser?.uid);
    final bookmarkedPostRef =
        userRef.collection('bookmarkedPosts').doc(post.id);
    await bookmarkedPostRef.set({
      /// bookmarkedPosts自身のIDにはpostIdと同じIDをsetしている
      'id': post.id,
      'userId': post.userId,
      'createdAt': FieldValue.serverTimestamp(),

      // Todo やっぱりbookmarkしたpostの中身を全部持たせよう
      /// 参照元のデータが更新されたことをCloud FunctionsのFirestoreトリガーで検出し、
      /// 参照元のデータを持つドキュメントを各ドキュメントのサブコレクションから抽出し、データを更新する。
      // 'title': post.title,
      // 'body': post.body,
      // 'nickname': post.nickname,
      // 'emotion': post.emotion,
      // 'position': post.position,
      // 'gender': post.gender,
      // 'age': post.age,
      // 'area': post.area,
      // 'categories': post.categories,
      // 'posterId': post.uid,
      // 'replyCount': 0,
      // 'isDraft': post.isDraft,
    });
    notifyListeners();
  }

  Future<void> deleteBookmarkedPost(Post post) async {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser?.uid);
    final bookmarkedPostsRef =
        userRef.collection('bookmarkedPosts').doc(post.id);
    await bookmarkedPostsRef.delete();
    notifyListeners();
  }

  void turnOnEmpathyButton(Post post) {
    post.isEmpathized = true;
    notifyListeners();
  }

  void turnOffEmpathyButton(Post post) {
    post.isEmpathized = false;
    notifyListeners();
  }

  // 10回までワカルできる
  // Future<void> addEmpathizedPost(Post post) async {
  //   WriteBatch _batch = _firestore.batch();
  //
  //   final userRef = FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(_auth.currentUser?.uid);
  //   final empathizedPostRef =
  //       userRef.collection('empathizedPosts').doc(post.id);
  //   final empathizedPostSnapshot = await empathizedPostRef.get();
  //   int myEmpathyCount = 0;
  //   if (empathizedPostSnapshot.exists) {
  //     myEmpathyCount = empathizedPostSnapshot['myEmpathyCount'];
  //   }
  //   final postRef = FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(post.userId)
  //       .collection('posts')
  //       .doc(post.id);
  //   final postSnapshot = await postRef.get();
  //   final currentEmpathyCount = postSnapshot['empathyCount'];
  //
  //   if (myEmpathyCount == 0) {
  //     _batch.set(empathizedPostRef, {
  //       /// empathizedPosts自身のIDにはpostIdと同じIDをsetしている
  //       'id': post.id,
  //       'userId': post.userId,
  //       'myEmpathyCount': myEmpathyCount + 1,
  //       'createdAt': FieldValue.serverTimestamp(),
  //     });
  //     _batch.update(postRef, {
  //       'empathyCount': currentEmpathyCount + 1,
  //     });
  //     post.empathyCount = post.empathyCount + 1;
  //   } else if (myEmpathyCount != 0 && myEmpathyCount < 10) {
  //     _batch.update(empathizedPostRef, {
  //       'myEmpathyCount': myEmpathyCount + 1,
  //     });
  //     _batch.update(postRef, {
  //       'empathyCount': currentEmpathyCount + 1,
  //     });
  //     post.empathyCount = currentEmpathyCount + 1;
  //   }
  //
  //   // try {
  //   await _batch.commit();
  //   // } on Exception catch (e) {
  //   //   print('addEmpathizedPostのバッチ処理中のエラーです');
  //   //   print(e.toString());
  //   //   throw ('addEmpathizedPostのバッチ処理中のエラーです\nスルーでok');
  //   // } finally {
  //   // }
  //
  //   notifyListeners();
  // }

  // １回のみワカルできる
  Future<void> addEmpathizedPost(Post post) async {
    post.empathyCount = post.empathyCount + 1;
    notifyListeners();

    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser?.uid);
    final empathizedPostsRef =
        userRef.collection('empathizedPosts').doc(post.id);
    await empathizedPostsRef.set({
      /// empathizedPosts自身のIDにはpostIdと同じIDをsetしている
      'id': post.id,
      'userId': post.userId,
      'myEmpathyCount': 1,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final postRef = FirebaseFirestore.instance
        .collection('users')
        .doc(post.userId)
        .collection('posts')
        .doc(post.id);

    final postSnapshot = await postRef.get();
    final currentEmpathyCount = postSnapshot['empathyCount'];

    await postRef.update({
      'empathyCount': currentEmpathyCount + 1,
    });
  }

  Future<void> deleteEmpathizedPost(Post post) async {
    post.empathyCount = post.empathyCount - 1;
    notifyListeners();

    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser?.uid);
    final empathizedPostsRef =
        userRef.collection('empathizedPosts').doc(post.id);
    await empathizedPostsRef.delete();

    final postRef = FirebaseFirestore.instance
        .collection('users')
        .doc(post.userId)
        .collection('posts')
        .doc(post.id);

    final postSnapshot = await postRef.get();
    final currentEmpathyCount = postSnapshot['empathyCount'];

    if (currentEmpathyCount > 0) {
      await postRef.update({
        'empathyCount': currentEmpathyCount - 1,
      });
    }
  }

  // Future<void> _deleteBookmarkedPostsForAllUsers(Post post) async {
  //   List<Future> futures = [];
  //   final querySnapshot = await _firestore
  //       .collectionGroup('bookmarkedPosts')
  //       .where('postId', isEqualTo: post.id)
  //       .get();
  //   final bookmarkedPosts =
  //       querySnapshot.docs.map((doc) => doc.reference).toList();
  //   for (int i = 0; i < bookmarkedPosts.length; i++) {
  //     futures.add(bookmarkedPosts[i].delete());
  //   }
  //   await Future.wait(futures);
  // }
  //
  // Future<void> deletePostAndReplies(Post post) async {
  //   final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
  //   final postRef = userRef.collection('posts').doc(post.id);
  //   await postRef.delete();
  //   await _deleteBookmarkedPostsForAllUsers(post);
  //   final replies = (await postRef.collection('replies').get()).docs;
  //   for (int i = 0; i < replies.length; i++) {
  //     replies[i].reference.delete();
  //   }
  //   notifyListeners();
  // }
}
