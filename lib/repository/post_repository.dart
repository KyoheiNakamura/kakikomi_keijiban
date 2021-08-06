import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';
import 'package:kakikomi_keijiban/entity/post.dart';

class PostRepository {
  PostRepository._();
  static PostRepository instance = PostRepository._();

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
