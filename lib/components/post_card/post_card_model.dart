import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';

class PostCardModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final List<Reply> replies = [];
  bool isLoading = false;

  Future<List<Reply>> getRepliesToPost(Post post) async {
    final querySnapshot = await _firestore
        .collection('users')
        .doc(post.uid)
        .collection('posts')
        .doc(post.id)
        .collection('replies')
        .orderBy('createdAt')
        .get();
    final docs = querySnapshot.docs;
    // postドメインにrepliesを持たせたので、postCardPageで戻り値をrepliesに入れてやる
    final replies = docs.map((doc) => Reply(doc)).toList();
    return replies;
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
