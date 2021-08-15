import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';
import 'package:kakikomi_keijiban/common/mixin/provide_common_posts_method_mixin.dart';
import 'package:kakikomi_keijiban/entity/post.dart';
import 'package:kakikomi_keijiban/entity/reply.dart';

class PostRepository with ProvideCommonPostsMethodMixin {
  PostRepository._();
  static PostRepository instance = PostRepository._();

  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> _postStream;
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _repliesStream;

  /// データベースでの投稿の変更を検知・entityへの変換をして、viewModelに知らせる
  // void subscribePostChange({
  //   required Post post,
  //   required StreamController<Post> streamController,
  // }) async {
  //   print('ぐううううううううううううううううううううううううううううう');
  //   _postStream = firestore
  //       .collection('users')
  //       .doc(post.userId)
  //       .collection('posts')
  //       .doc(post.id)
  //       .snapshots()
  //       .listen((snapshot) {
  //     print('ほっほほほほほっっっっっっっっっっっっっっっh');
  //     if (snapshot.exists) {
  //       print('ああああああああああああああああああああ');
  //       print(snapshot.data());
  //       final post = Post.fromDoc(snapshot);
  //       streamController.add(post);
  //     }
  //   });
  // }

  // void subscribeRepliesChange({
  //   required Post post,
  //   required StreamController<void> streamController,
  // }) async {
  //   print('ぐううううううううううううううううううううううううううううう');
  //   _repliesStream = firestore
  //       .collection('users')
  //       .doc(post.userId)
  //       .collection('posts')
  //       .doc(post.id)
  //       .collection('replies')
  //       .orderBy('createdAt')
  //       .snapshots()
  //       .listen((snapshot) async {
  //     print('ほっほほほほほっっっっっっっっっっっっっっっh');

  //     if (snapshot.size > 0) {
  //       final _replies = snapshot.docs.map((doc) => Reply(doc)).toList();
  //       addEmpathy(_replies);
  //       post.replies = _replies;
  //       await getRepliesToReply(_replies);
  //       streamController.add(null);
  //     }
  //   });
  // }

  // Stream<List<Post>> subscribePostChange() {
  //   return firestore
  //       .collectionGroup('post')
  //       .snapshots()
  //       .asyncMap<List<Post>>((snapshot) {
  //     return snapshot.docs.map((doc) {
  //       return Post.fromDoc(doc);
  //     }).toList();
  //   });
  // }

  /// サブスクをキャンセルする
  void unsubscribePostChange() {
    _postStream.cancel();
  }

  void unsubscribeRepliesChange() {
    _repliesStream.cancel();
  }

  String getCollectionPath(String userId) {
    return 'users/$userId/posts';
  }

  String getDocumentPath({
    required String userId,
    required String postId,
  }) {
    return 'users/$userId/posts/$postId';
  }

  Future<Post> getPost({
    required String userId,
    required String postId,
  }) async {
    final doc = await firestore
        .doc(getDocumentPath(
          userId: userId,
          postId: postId,
        ))
        .get();
    if (doc.exists) {
      return Post.fromMap(doc.data()!);
    } else {
      throw Exception('エラーが発生しました');
    }
  }

  void createPostWithBatch({
    required String userId,
    required Post post,
    required WriteBatch batch,
  }) {
    final postRef = firestore.collection(getCollectionPath(userId)).doc();
    post
      ..id = postRef.id
      ..userId = userId
      ..createdAtFieldValue = FieldValue.serverTimestamp()
      ..updatedAtFieldValue = FieldValue.serverTimestamp();
    batch.set(postRef, post.toMap());
  }

  Future<void> updatePost({
    required String userId,
    required String postId,
    required Post newPost,
  }) async {
    newPost.updatedAtFieldValue = FieldValue.serverTimestamp();
    await firestore
        .doc(getDocumentPath(
          userId: userId,
          postId: postId,
        ))
        .update(newPost.toMap());
  }

  // // 以下未使用
  // Future<void> createPost({
  //   required String userId,
  //   required Post post,
  // }) async {
  //   final postRef = firestore.collection(getCollectionPath(userId)).doc();
  //   post
  //     ..id = postRef.id
  //     ..userId = userId
  //     ..createdAtFieldValue = FieldValue.serverTimestamp()
  //     ..updatedAtFieldValue = FieldValue.serverTimestamp();
  //   postRef.set(post.toMap());
  // }

  // Future<void> deletePost({
  //   required String userId,
  //   required String postId,
  // }) async {
  //   await firestore
  //       .doc(getDocumentPath(
  //         userId: userId,
  //         postId: postId,
  //       ))
  //       .delete();
  // }
}
