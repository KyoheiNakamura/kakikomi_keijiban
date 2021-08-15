import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';
import 'package:kakikomi_keijiban/entity/post.dart';

class CardMenuButtonModel extends ChangeNotifier {
  Future<void> addBookmarkedPost(Post post) async {
    final userRef = firestore.collection('users').doc(auth.currentUser?.uid);
    final bookmarkedPostRef =
        userRef.collection('bookmarkedPosts').doc(post.id);
    await bookmarkedPostRef.set(<String, dynamic>{
      /// bookmarkedPosts自身のIDにはpostIdと同じIDをsetしている
      'id': post.id,
      'userId': post.userId,
      'createdAt': serverTimestamp(),
    });
    notifyListeners();
  }

  Future<void> deleteBookmarkedPost(Post post) async {
    final userRef = firestore.collection('users').doc(auth.currentUser?.uid);
    final bookmarkedPostsRef =
        userRef.collection('bookmarkedPosts').doc(post.id);
    await bookmarkedPostsRef.delete();
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
}
