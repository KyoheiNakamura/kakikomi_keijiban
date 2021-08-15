import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';
import 'package:kakikomi_keijiban/entity/empathized_post.dart';
import 'package:kakikomi_keijiban/entity/post.dart';
import 'package:kakikomi_keijiban/entity/reply.dart';
import 'package:kakikomi_keijiban/entity/reply_to_reply.dart';
import 'package:kakikomi_keijiban/repository/bookmark_repository.dart';
import 'package:kakikomi_keijiban/repository/empathy_repository.dart';
import 'package:kakikomi_keijiban/repository/post_repository.dart';

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

  void addBookmark(
    List<dynamic> list,
    // List<String> bookmarkedPostsIds,
  ) {
    final bookmarkedPostsIds = BookmarkRepository.instance.bookmarkedPostsIds;
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

  void addEmpathy(
    List<dynamic> list,
    // List<String> empathizedPostsIds,
  ) {
    final empathizedPostsIds = EmpathyRepository.instance.empathizedPostsIds;
    for (var i = 0; i < list.length; i++) {
      for (var n = 0; n < empathizedPostsIds.length; n++) {
        if (list[i].id == empathizedPostsIds[n]) {
          list[i].isEmpathized = true;
        }
      }
    }
  }

  Query<Map<String, dynamic>> getRepliesQuery({
    required Post post,
    required int loadLimit,
  }) {
    return firestore
        .collection('users')
        .doc(post.userId)
        .collection('posts')
        .doc(post.id)
        .collection('replies')
        .orderBy('createdAt')
        .limit(loadLimit);
  }

  Query<Map<String, dynamic>> loadRepliesQuery({
    required Post post,
    required int loadLimit,
    required DocumentSnapshot<Object?> lastVisibleOfTheBatch,
  }) {
    return firestore
        .collection('users')
        .doc(post.userId)
        .collection('posts')
        .doc(post.id)
        .collection('replies')
        .orderBy('createdAt')
        .startAfterDocument(lastVisibleOfTheBatch)
        .limit(loadLimit);
  }

  Future<List<Reply>> getReplies(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final replies = docs.map((doc) => Reply(doc)).toList();
    addEmpathy(replies);
    await getRepliesToReply(replies);
    return replies;
  }

  // Future<void> getReplies(Post post) async {
  //   final querySnapshot = await firestore
  //       .collection('users')
  //       .doc(post.userId)
  //       .collection('posts')
  //       .doc(post.id)
  //       .collection('replies')
  //       .orderBy('createdAt')
  //       .get();
  //   final docs = querySnapshot.docs;
  //   final replies = docs.map((doc) => Reply(doc)).toList();
  //   addEmpathy(replies);
  //   post.replies = replies;

  //   await getRepliesToReply(replies);
  // }

  // Future<void> getReplies(
  //   List<Post> _posts,
  //   // List<String> empathizedPostsIds,
  // ) async {
  //   for (var i = 0; i < _posts.length; i++) {
  //     final post = _posts[i];
  //     final querySnapshot = await firestore
  //         .collection('users')
  //         .doc(post.userId)
  //         .collection('posts')
  //         .doc(post.id)
  //         .collection('replies')
  //         .orderBy('createdAt')
  //         .get();
  //     final docs = querySnapshot.docs;
  //     final _replies = docs.map((doc) => Reply(doc)).toList();
  //     addEmpathy(_replies);
  //     post.replies = _replies;

  //     await getRepliesToReply(_replies);
  //   }
  // }

  Future<void> getRepliesToReply(
    List<Reply> replies,
    // List<String> empathizedPostsId,
  ) async {
    for (var i = 0; i < replies.length; i++) {
      final reply = replies[i];
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
      final repliesToReplies = docs.map((doc) => ReplyToReply(doc)).toList();
      addEmpathy(repliesToReplies);
      reply.repliesToReply = repliesToReplies;
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
    addBookmark(<Post>[newPost]);
    addEmpathy(<Post>[newPost]);
    // await getReplies(newPost);

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
