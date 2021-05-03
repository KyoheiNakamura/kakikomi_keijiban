import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';
import 'package:kakikomi_keijiban/domain/reply_to_reply.dart';

mixin ProvideCommonPostsMethodMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addBookmark(List<dynamic> list) async {
    final bookmarkedPostsSnapshot = await _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('bookmarkedPosts')
        .get();
    final List<String> bookmarkedPostsIds = bookmarkedPostsSnapshot.docs
        .map((bookmarkedPost) => bookmarkedPost.id)
        .toList();
    for (int i = 0; i < list.length; i++) {
      for (int n = 0; n < bookmarkedPostsIds.length; n++) {
        if (list[i].id == bookmarkedPostsIds[n]) {
          list[i].isBookmarked = true;
        }
      }
    }
  }

  Future<void> addEmpathy(List<dynamic> list) async {
    final empathizedPostsSnapshot = await _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('empathizedPosts')
        .get();
    final List<String> empathizedPostsIds = empathizedPostsSnapshot.docs
        .map((empathizedPost) => empathizedPost.id)
        .toList();
    for (int i = 0; i < list.length; i++) {
      for (int n = 0; n < empathizedPostsIds.length; n++) {
        if (list[i].id == empathizedPostsIds[n]) {
          list[i].isEmpathized = true;
        }
      }
    }
  }

  Future<void> getReplies(List<Post> _posts) async {
    for (int i = 0; i < _posts.length; i++) {
      final post = _posts[i];
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
      await addEmpathy(_replies);
      post.replies = _replies;

      await getRepliesToReply(_replies);
    }
  }

  Future<void> getRepliesToReply(List<Reply> _replies) async {
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
      await addEmpathy(_repliesToReplies);
      reply.repliesToReply = _repliesToReplies;
    }
  }

  // Todo bookmarkedPosts/{bookmarkedPost_id}にbookmarkしたpostのidのみじゃなくて、中身を全部持たせる。
  Future<List<Post>> getBookmarkedPosts(
      List<QueryDocumentSnapshot> docs) async {
    final postSnapshots = await Future.wait(docs
        .map((bookmarkedPost) => _firestore
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
    // 更新後のpostを取得
    final doc = await _firestore
        .collection('users')
        .doc(oldPost.userId)
        .collection('posts')
        .doc(oldPost.id)
        .get();
    Post post = Post(doc);
    await addEmpathy([post]);
    await addBookmark([post]);
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
    await addEmpathy(_replies);
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
      await addEmpathy(_repliesToReplies);
      reply.repliesToReply = _repliesToReplies;
    }
    // 更新前のpostをpostsから削除
    posts.removeAt(indexOfPost);
    // 更新後のpostをpostsに追加
    posts.insert(indexOfPost, post);
  }

  void removeThePostAfterDeleted(
      {required List<Post> posts, required Post post}) {
    posts.remove(post);
  }
}
