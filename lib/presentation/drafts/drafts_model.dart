import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';
import 'package:kakikomi_keijiban/domain/reply_to_reply.dart';

class DraftsModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser?.uid;

  List<Post> _drafts = [];
  List<Post> get posts => _drafts;

  bool isLoading = false;
  bool isModalLoading = false;

  Future<void> init() async {
    startModalLoading();
    await getDrafts();
    stopModalLoading();
  }

  Future<void> getDrafts() async {
    await _getDraftPosts();
    await _getDraftReplies();
    await _getDraftedRepliesToReply();
    this._drafts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> _getDraftPosts() async {
    final querySnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('draftedPosts')
        .get();
    final docs = querySnapshot.docs;
    List<Post> draftedPosts = docs.map((doc) => Post(doc)).toList();
    this._drafts += draftedPosts;
  }

  Future<void> _getDraftReplies() async {
    final querySnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('draftedReplies')
        .get();
    final docs = querySnapshot.docs;
    final List<Reply> draftedReplies = docs.map((doc) => Reply(doc)).toList();

    for (int i = 0; i < draftedReplies.length; i++) {
      final reply = draftedReplies[i];
      final userId = reply.userId;
      final postId = reply.postId;
      final postDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('posts')
          .doc(postId)
          .get();
      final post = Post(postDoc);
      post.replies.add(reply);
      this._drafts.add(post);
    }
  }

  Future<void> _getDraftedRepliesToReply() async {
    final querySnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('draftedRepliesToReply')
        .get();
    final docs = querySnapshot.docs;
    final List<ReplyToReply> draftedRepliesToReply =
        docs.map((doc) => ReplyToReply(doc)).toList();

    final futures = draftedRepliesToReply.map((replyToReply) async {
      final userId = replyToReply.userId;
      final postId = replyToReply.postId;
      final replyId = replyToReply.replyId;
      final replyDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('posts')
          .doc(postId)
          .collection('replies')
          .doc(replyId)
          .get();
      final reply = Reply(replyDoc);
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('posts')
          .doc(postId)
          .collection('replies')
          .doc(replyId)
          .collection('repliesToReply')
          .get();
      final docs = querySnapshot.docs;
      final List<ReplyToReply> repliesToReply =
          docs.map((doc) => ReplyToReply(doc)).toList();
      repliesToReply.add(replyToReply);
      repliesToReply.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      reply.repliesToReply.addAll(repliesToReply);
      return reply;
    }).toList();

    final List<Reply> replies = await Future.wait(futures);

    for (int i = 0; i < replies.length; i++) {
      final reply = replies[i];
      final userId = reply.userId;
      final postId = reply.postId;
      final postDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('posts')
          .doc(postId)
          .get();
      final post = Post(postDoc);
      post.replies.add(reply);
      this._drafts.add(post);
    }
  }

  Future<void> refreshThePostOfPostsAfterUpdated({
    required Post oldPost,
    required int indexOfPost,
  }) async {
    // 更新後のpostを取得
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('draftedPosts')
        .doc(oldPost.id)
        .get();
    final post = Post(doc);
    final querySnapshot = await _firestore
        .collection('users')
        .doc(post.userId)
        .collection('posts')
        .doc(post.id)
        .collection('replies')
        .orderBy('createdAt')
        .get();
    final docs = querySnapshot.docs;
    final _replies = docs.map((doc) => Reply(doc)).toList();
    post.replies = _replies;

    for (int i = 0; i < _replies.length; i++) {
      final reply = _replies[i];
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
      reply.repliesToReply = _repliesToReplies;
    }
    // 更新前のpostをpostsから削除
    this._drafts.removeAt(indexOfPost);
    // 更新後のpostをpostsに追加
    this._drafts.insert(indexOfPost, post);
    notifyListeners();
  }

  void removeThePostOfPostsAfterDeleted(Post post) {
    this._drafts.remove(post);
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

  void startModalLoading() {
    isModalLoading = true;
    notifyListeners();
  }

  void stopModalLoading() {
    isModalLoading = false;
    notifyListeners();
  }
}
