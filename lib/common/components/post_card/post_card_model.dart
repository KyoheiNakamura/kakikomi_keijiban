import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';
import 'package:kakikomi_keijiban/domain/reply_to_reply.dart';

class PostCardModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser?.uid;
  bool isLoading = false;

  Future<void> getRepliesToPost(Post post) async {
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
    // postドメインにrepliesを持たせているので、postCardでpost.repliesに入れてやってる
    post.replies = replies;
    notifyListeners();
  }

  Future<void> getAllRepliesToPost(Post post) async {
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
    // postドメインにrepliesを持たせているので、postCardでpost.repliesに入れてやってる
    post.replies = replies;

    for (int i = 0; i < replies.length; i++) {
      var reply = replies[i];
      var _querySnapshot = await _firestore
          .collection('users')
          .doc(reply.uid)
          .collection('posts')
          .doc(reply.postId)
          .collection('replies')
          .doc(reply.id)
          .collection('repliesToReply')
          .orderBy('createdAt')
          .get();
      var _docs = _querySnapshot.docs;
      var _repliesToReplies = _docs.map((doc) => ReplyToReply(doc)).toList();
      reply.repliesToReply = _repliesToReplies;
    }
    notifyListeners();

    // // indexed forでもよい。listが必要なわけではないので。
    // replies.map((reply) async {
    //   var _querySnapshot = await _firestore
    //       .collection('users')
    //       .doc(reply.uid)
    //       .collection('posts')
    //       .doc(reply.postId)
    //       .collection('replies')
    //       .doc(reply.id)
    //       .collection('repliesToReply')
    //       .orderBy('createdAt')
    //       .get();
    //   var _docs = _querySnapshot.docs;
    //   var _repliesToReplies = _docs.map((doc) => ReplyToReply(doc)).toList();
    //   reply.repliesToReply = _repliesToReplies;
    // }).toList();
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
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final bookmarkedPostRef =
        userRef.collection('bookmarkedPosts').doc(post.id);
    await bookmarkedPostRef.set({
      /// bookmarkedPosts自身のIDにはpostIdと同じIDをsetしている
      'id': post.id,
      'postId': post.id,
      'userId': uid,
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
    final postRef = userRef.collection('posts').doc(post.id);
    await postRef.delete();
    await _deleteBookmarkedPostsForAllUsers(post);
    final replies = (await postRef.collection('replies').get()).docs;
    for (int i = 0; i < replies.length; i++) {
      replies[i].reference.delete();
    }
    notifyListeners();
  }
}
