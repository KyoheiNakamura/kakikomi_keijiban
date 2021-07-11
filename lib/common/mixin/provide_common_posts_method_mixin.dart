import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';
import 'package:kakikomi_keijiban/entity/empathized_post.dart';
import 'package:kakikomi_keijiban/entity/post.dart';
import 'package:kakikomi_keijiban/entity/reply.dart';
import 'package:kakikomi_keijiban/entity/reply_to_reply.dart';

mixin ProvideCommonPostsMethodMixin {
  Future<List<String>> getBookmarkedPostsIds() async {
    final bookmarkedPostsSnapshot = await firestore
        .collection('users')
        .doc(auth.currentUser?.uid)
        .collection('bookmarkedPosts')
        .get();
    final bookmarkedPostsIds = bookmarkedPostsSnapshot.docs
        .map((bookmarkedPost) => bookmarkedPost.id)
        .toList();
    return bookmarkedPostsIds;
  }

  Future<void> addBookmark(
    List<dynamic> list,
    List<String> bookmarkedPostsIds,
  ) async {
    for (var i = 0; i < list.length; i++) {
      for (var n = 0; n < bookmarkedPostsIds.length; n++) {
        if (list[i].id == bookmarkedPostsIds[n]) {
          list[i].isBookmarked = true;
        }
      }
    }
  }

  Future<List<String>> getEmpathizedPostsIds() async {
    final empathizedPostsSnapshot = await firestore
        .collection('users')
        .doc(auth.currentUser?.uid)
        .collection('empathizedPosts')
        .get();
    final empathizedPostsIds = empathizedPostsSnapshot.docs
        .map((empathizedPost) => empathizedPost.id)
        .toList();
    return empathizedPostsIds;
  }

  Future<void> addEmpathy(
      List<dynamic> list, List<String> empathizedPostsIds) async {
    for (var i = 0; i < list.length; i++) {
      for (var n = 0; n < empathizedPostsIds.length; n++) {
        if (list[i].id == empathizedPostsIds[n]) {
          list[i].isEmpathized = true;
        }
      }
    }
  }

  Future<void> getReplies(
      List<Post> _posts, List<String> empathizedPostsId) async {
    for (var i = 0; i < _posts.length; i++) {
      final post = _posts[i];
      final querySnapshot = await firestore
          .collection('users')
          .doc(post.userId)
          .collection('posts')
          .doc(post.id)
          .collection('replies')
          .orderBy('createdAt')
          .get();
      final docs = querySnapshot.docs;
      final _replies = docs.map((doc) => Reply(doc)).toList();
      await addEmpathy(_replies, empathizedPostsId);
      post.replies = _replies;

      await _getRepliesToReply(_replies, empathizedPostsId);
    }
  }

  Future<void> _getRepliesToReply(
      List<Reply> _replies, List<String> empathizedPostsId) async {
    for (var i = 0; i < _replies.length; i++) {
      final reply = _replies[i];
      final _querySnapshot = await firestore
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
      await addEmpathy(_repliesToReplies, empathizedPostsId);
      reply.repliesToReply = _repliesToReplies;
    }
  }

  // bookmarkedPosts を取得
  // Todo bookmarkedPosts/{bookmarkedPost_id}にbookmarkしたpostのidのみじゃなくて、中身を全部持たせる。
  Future<List<Post>> getBookmarkedPosts(
      List<QueryDocumentSnapshot> docs) async {
    final postSnapshots = await Future.wait(docs
        .map((bookmarkedPost) => firestore
            .collectionGroup('posts')
            .where('id', isEqualTo: bookmarkedPost['id'])
            // .orderBy('createdAt', descending: true)
            .get())
        .toList());
    final bookmarkedPostDocs = postSnapshots.map((postSnapshot) {
      if (postSnapshot.docs.isNotEmpty) {
        return postSnapshot.docs[0];
      } else {
        return null;
      }
    }).toList()
      // bookmarkedPostDocsからnullを全て削除
      ..removeWhere((element) => element == null);
    final bookmarkedPosts =
        bookmarkedPostDocs.map((doc) => Post.fromDoc(doc!)).toList();
    _addBookmarkToBookmarkedPosts(bookmarkedPosts);
    return bookmarkedPosts;
  }

  void _addBookmarkToBookmarkedPosts(List<Post> bookmarkedPosts) {
    for (var i = 0; i < bookmarkedPosts.length; i++) {
      bookmarkedPosts[i].isBookmarked = true;
    }
  }

  // empathizedPosts を取得
  Future<List<EmpathizedPost>> fetchEmpathizedPosts(
      List<QueryDocumentSnapshot> docs) async {
    final _empathizedPosts =
        docs.map((doc) => EmpathizedPostInfo(doc)).toList();
    final empathizedPostDocs =
        await Future.wait(_empathizedPosts.map((empathizedPost) async {
      if (empathizedPost.postType == 'post') {
        final querySanpshot = await firestore
            .collectionGroup('posts')
            .where('id', isEqualTo: empathizedPost.postId)
            .get();
        final docs = querySanpshot.docs;
        if (docs.isNotEmpty) {
          return docs.first;
          // final doc = docs.first;
          // if (doc.exists) {
          //   return Post.fromDoc(doc);
          // }
        }
      } else if (empathizedPost.postType == 'reply') {
        final querySanpshot = await firestore
            .collectionGroup('replies')
            .where('id', isEqualTo: empathizedPost.replyId)
            .get();
        final docs = querySanpshot.docs;
        if (docs.isNotEmpty) {
          return docs.first;
          // final doc = docs.first;
          // if (doc.exists) {
          //   return Reply(doc);
          // }
        }
        // } else if (empathizedPost.postType == 'replyToReply') {
      } else {
        final querySanpshot = await firestore
            .collectionGroup('repliesToReply')
            .where('id', isEqualTo: empathizedPost.replyToReplyId)
            .get();
        final docs = querySanpshot.docs;
        if (docs.isNotEmpty) {
          return docs.first;
          // final doc = docs.first;
          // if (doc.exists) {
          //   return ReplyToReply(doc);
          // }
        }
      }
    }).toList())
          ..removeWhere((element) => element == null);
    final empathizedPosts =
        empathizedPostDocs.map((doc) => EmpathizedPost(doc!)).toList();
    _addEmpathyToEmpathizedPosts(empathizedPosts);
    return empathizedPosts;
  }

  void _addEmpathyToEmpathizedPosts(List<EmpathizedPost> empathizedPosts) {
    for (var i = 0; i < empathizedPosts.length; i++) {
      empathizedPosts[i].isEmpathized = true;
    }
  }

  // empathizedPosts を取得
  // Future<List<dynamic>> fetchEmpathizedPosts(
  //     List<QueryDocumentSnapshot> docs) async {
  //   final _empathizedPosts =
  //       docs.map((doc) => EmpathizedPostInfo(doc)).toList();
  //   final empathizedPosts =
  //       await Future.wait(_empathizedPosts.map((empathizedPost) async {
  //     if (empathizedPost.postType == 'post') {
  //       final querySanpshot = await firestore
  //           .collectionGroup('posts')
  //           .where('id', isEqualTo: empathizedPost.postId)
  //           .get();
  //       final docs = querySanpshot.docs;
  //       if (docs.isNotEmpty) {
  //         final doc = docs.first;
  //         if (doc.exists) {
  //           return Post.fromDoc(doc);
  //         }
  //       }
  //     } else if (empathizedPost.postType == 'reply') {
  //       final querySanpshot = await firestore
  //           .collectionGroup('reply')
  //           .where('id', isEqualTo: empathizedPost.replyId)
  //           .get();
  //       final docs = querySanpshot.docs;
  //       if (docs.isNotEmpty) {
  //         final doc = docs.first;
  //         if (doc.exists) {
  //           return Reply(doc);
  //         }
  //       }
  //       // } else if (empathizedPost.postType == 'replyToReply') {
  //     } else {
  //       final querySanpshot = await firestore
  //           .collectionGroup('repliesToReply')
  //           .where('id', isEqualTo: empathizedPost.replyToReplyId)
  //           .get();
  //       final docs = querySanpshot.docs;
  //       if (docs.isNotEmpty) {
  //         final doc = docs.first;
  //         if (doc.exists) {
  //           return ReplyToReply(doc);
  //         }
  //       }
  //     }
  //   }).toList())
  //         ..removeWhere((element) => element == null);
  //   _addEmpathyToEmpathizedPosts(empathizedPosts);
  //   return empathizedPosts;
  // }

  // void _addEmpathyToEmpathizedPosts(List<dynamic> empathizedPosts) {
  //   for (var i = 0; i < empathizedPosts.length; i++) {
  //     empathizedPosts[i].isEmpathized = true;
  //   }
  // }

  Future<List<Post>> getRepliedPosts(List<QueryDocumentSnapshot> docs) async {
    final postIds = docs.map((doc) => doc.reference.parent.parent!.id).toSet();
    final postSnapshots = await Future.wait(postIds
        .map((postId) => firestore
            .collectionGroup('posts')
            .where('id', isEqualTo: postId)
            .get())
        .toList());
    final repliedPostDocs =
        postSnapshots.map((postSnapshot) => postSnapshot.docs[0]).toList();
    final repliedPosts =
        repliedPostDocs.map((doc) => Post.fromDoc(doc)).toList();
    return repliedPosts;
  }

// empathyとbookmark付ける
  Future<void> refreshThePostAfterUpdated({
    required List<Post> posts,
    required Post oldPost,
    required int indexOfPost,
  }) async {
    final empathizedPostsIds = await getEmpathizedPostsIds();
    final bookmarkedPostsIds = await getBookmarkedPostsIds();
    // 更新後のpostを取得
    final doc = await firestore
        .collection('users')
        .doc(oldPost.userId)
        .collection('posts')
        .doc(oldPost.id)
        .get();
    final newPost = Post.fromDoc(doc);
    await addBookmark(<Post>[newPost], bookmarkedPostsIds);
    await addEmpathy(<Post>[newPost], empathizedPostsIds);
    await getReplies([newPost], empathizedPostsIds);

    posts
      // 更新前のpostをpostsから削除
      ..removeAt(indexOfPost)
      // 更新後のpostをpostsに追加
      ..insert(indexOfPost, newPost);
  }

  void removeThePostAfterDeleted(
      {required List<Post> posts, required Post post}) {
    posts.remove(post);
  }
}
