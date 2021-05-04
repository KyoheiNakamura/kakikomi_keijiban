import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';
import 'package:kakikomi_keijiban/domain/reply_to_reply.dart';

mixin ProvideCommonPostsMethodMixin {
  Future<List<String>> getBookmarkedPostsIds() async {
    final bookmarkedPostsSnapshot = await firestore
        .collection('users')
        .doc(auth.currentUser?.uid)
        .collection('bookmarkedPosts')
        .get();
    final List<String> bookmarkedPostsIds = bookmarkedPostsSnapshot.docs
        .map((bookmarkedPost) => bookmarkedPost.id)
        .toList();
    return bookmarkedPostsIds;
  }

  Future<void> addBookmark(
      List<dynamic> list, List<String> bookmarkedPostsIds) async {
    for (int i = 0; i < list.length; i++) {
      for (int n = 0; n < bookmarkedPostsIds.length; n++) {
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
    final List<String> empathizedPostsIds = empathizedPostsSnapshot.docs
        .map((empathizedPost) => empathizedPost.id)
        .toList();
    return empathizedPostsIds;
  }

  Future<void> addEmpathy(
      List<dynamic> list, List<String> empathizedPostsIds) async {
    for (int i = 0; i < list.length; i++) {
      for (int n = 0; n < empathizedPostsIds.length; n++) {
        if (list[i].id == empathizedPostsIds[n]) {
          list[i].isEmpathized = true;
        }
      }
    }
  }

  Future<void> getReplies(
      List<Post> _posts, List<String> empathizedPostsId) async {
    for (int i = 0; i < _posts.length; i++) {
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
    for (int i = 0; i < _replies.length; i++) {
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
    }).toList();
    // bookmarkedPostDocsからnullを全て削除
    bookmarkedPostDocs.removeWhere((element) => element == null);
    final bookmarkedPosts =
        bookmarkedPostDocs.map((doc) => Post(doc!)).toList();
    _addBookmarkToBookmarkedPosts(bookmarkedPosts);
    return bookmarkedPosts;
  }

  void _addBookmarkToBookmarkedPosts(List<Post> bookmarkedPosts) {
    for (int i = 0; i < bookmarkedPosts.length; i++) {
      bookmarkedPosts[i].isBookmarked = true;
    }
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
    Post newPost = Post(doc);
    await addBookmark([newPost], bookmarkedPostsIds);
    await addEmpathy([newPost], empathizedPostsIds);
    await getReplies([newPost], empathizedPostsIds);

    // 更新前のpostをpostsから削除
    posts.removeAt(indexOfPost);
    // 更新後のpostをpostsに追加
    posts.insert(indexOfPost, newPost);
  }

  void removeThePostAfterDeleted(
      {required List<Post> posts, required Post post}) {
    posts.remove(post);
  }
}
