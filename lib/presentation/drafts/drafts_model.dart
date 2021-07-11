import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';
import 'package:kakikomi_keijiban/entity/post.dart';
import 'package:kakikomi_keijiban/entity/reply.dart';
import 'package:kakikomi_keijiban/entity/reply_to_reply.dart';

class DraftsModel extends ChangeNotifier {
  List<Post> _drafts = [];
  List<Post> get posts => _drafts;

  bool isLoading = false;
  bool isModalLoading = false;

  Future<void> init() async {
    // startModalLoading();
    await getDrafts();
    // stopModalLoading();
  }

  Future<void> getDrafts() async {
    _drafts.clear();
    await _getDraftPosts();
    await _getDraftReplies();
    await _getDraftedRepliesToReply();
    _drafts.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
    notifyListeners();
  }

  Future<void> _getDraftPosts() async {
    final querySnapshot = await firestore
        .collection('users')
        .doc(auth.currentUser?.uid)
        .collection('draftedPosts')
        .get();
    final docs = querySnapshot.docs;
    final draftedPosts = docs.map((doc) {
      final post = Post.fromDoc(doc)..isDraft = true;
      return post;
    }).toList();
    _drafts += draftedPosts;
  }

  Future<void> _getDraftReplies() async {
    final querySnapshot = await firestore
        .collection('users')
        .doc(auth.currentUser?.uid)
        .collection('draftedReplies')
        .get();
    final docs = querySnapshot.docs;
    final draftedReplies = docs.map((doc) {
      final reply = Reply(doc)..isDraft = true;
      return reply;
    }).toList();

    for (var i = 0; i < draftedReplies.length; i++) {
      final reply = draftedReplies[i];
      final userId = reply.userId;
      final postId = reply.postId;
      final postDoc = await firestore
          .collection('users')
          .doc(userId)
          .collection('posts')
          .doc(postId)
          .get();
      final post = Post.fromDoc(postDoc);
      post.replies.add(reply);
      _drafts.add(post);
    }
  }

  Future<void> _getDraftedRepliesToReply() async {
    final querySnapshot = await firestore
        .collection('users')
        .doc(auth.currentUser?.uid)
        .collection('draftedRepliesToReply')
        .get();
    final docs = querySnapshot.docs;
    final draftedRepliesToReply = docs.map((doc) {
      final replyToReply = ReplyToReply(doc)..isDraft = true;
      return replyToReply;
    }).toList();

    final futures = draftedRepliesToReply.map((replyToReply) async {
      final userId = replyToReply.userId;
      final postId = replyToReply.postId;
      final replyId = replyToReply.replyId;
      final replyDoc = await firestore
          .collection('users')
          .doc(userId)
          .collection('posts')
          .doc(postId)
          .collection('replies')
          .doc(replyId)
          .get();
      final reply = Reply(replyDoc);
      final querySnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('posts')
          .doc(postId)
          .collection('replies')
          .doc(replyId)
          .collection('repliesToReply')
          .get();
      final docs = querySnapshot.docs;
      final repliesToReply = docs.map((doc) => ReplyToReply(doc)).toList()
        ..add(replyToReply)
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      reply.repliesToReply.addAll(repliesToReply);
      return reply;
    }).toList();

    final replies = await Future.wait(futures);

    for (var i = 0; i < replies.length; i++) {
      final reply = replies[i];
      final userId = reply.userId;
      final postId = reply.postId;
      final postDoc = await firestore
          .collection('users')
          .doc(userId)
          .collection('posts')
          .doc(postId)
          .get();
      final post = Post.fromDoc(postDoc);
      post.replies.add(reply);
      _drafts.add(post);
    }
  }

  // // Todo ここをいじればいい感じに再描画されるはず。
  // // てか全取得しなおしても良きかも。下書きなんてそんな数書かないだろ。Twitterじゃあるめぇし。
  // Future<void> refreshThePostOfPostsAfterUpdated({
  //   required Post oldPost,
  //   required int indexOfPost,
  // }) async {
  //   await _getDrafts();
  //   // // 更新後のpostを取得
  //   // final doc = await firestore
  //   //     .collection('users')
  //   //     .doc(uid)
  //   //     .collection('draftedPosts')
  //   //     .doc(oldPost.id)
  //   //     .get();
  //   // final post = Post.fromDoc(doc);
  //   // post.isDraft = true;
  //   // final querySnapshot = await firestore
  //   //     .collection('users')
  //   //     .doc(post.userId)
  //   //     .collection('posts')
  //   //     .doc(post.id)
  //   //     .collection('replies')
  //   //     .orderBy('createdAt')
  //   //     .get();
  //   // final docs = querySnapshot.docs;
  //   // final _replies = docs.map((doc) => Reply(doc)).toList();
  //   // post.replies = _replies;
  //   //
  //   // for (int i = 0; i < _replies.length; i++) {
  //   //   final reply = _replies[i];
  //   //   final _querySnapshot = await firestore
  //   //       .collection('users')
  //   //       .doc(reply.userId)
  //   //       .collection('posts')
  //   //       .doc(reply.postId)
  //   //       .collection('replies')
  //   //       .doc(reply.id)
  //   //       .collection('repliesToReply')
  //   //       .orderBy('createdAt')
  //   //       .get();
  //   //   final _docs = _querySnapshot.docs;
  //   //   final _repliesToReplies = _docs.map((doc) => ReplyToReply(doc)).toList();
  //   //   reply.repliesToReply = _repliesToReplies;
  //   // }
  //   // // 更新前のpostをpostsから削除
  //   // _drafts.removeAt(indexOfPost);
  //   // // 更新後のpostをpostsに追加
  //   // _drafts.insert(indexOfPost, post);
  //   // notifyListeners();
  // }

  // postはthis._drafts.remove(post);するために必ず渡す
  Future<void> removeDraft(
      {required Post post, Reply? reply, ReplyToReply? replyToReply}) async {
    _drafts.remove(post);
    if (post.isDraft == true) {
      final draftedPostRef = firestore
          .collection('users')
          .doc(post.userId)
          .collection('draftedPosts')
          .doc(post.id);
      await draftedPostRef.delete();
    } else if (reply != null && reply.isDraft == true) {
      final draftedReplyRef = firestore
          .collection('users')
          .doc(reply.userId)
          .collection('draftedReplies')
          .doc(reply.id);
      await draftedReplyRef.delete();
    } else if (replyToReply != null && replyToReply.isDraft == true) {
      final draftedReplyToReplyRef = firestore
          .collection('users')
          .doc(replyToReply.userId)
          .collection('draftedRepliesToReply')
          .doc(replyToReply.id);
      await draftedReplyToReplyRef.delete();
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

  void startModalLoading() {
    isModalLoading = true;
    notifyListeners();
  }

  void stopModalLoading() {
    isModalLoading = false;
    notifyListeners();
  }
}
