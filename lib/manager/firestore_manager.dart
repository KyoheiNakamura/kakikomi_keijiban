import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum CommonPostsType {
  homePosts,
  bookmarkedPosts,
  empathizedPosts,
  myPosts,
  myReplies,
  searchResultPosts,
}

class FireStoreManager {
  FireStoreManager._();
  static FireStoreManager instance = FireStoreManager._();

  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  Query<Map<String, dynamic>> getCommonPostsQuery({
    required CommonPostsType type,
    required int loadLimit,
    String? postField,
    String? searchWord,
  }) {
    switch (type) {
      case CommonPostsType.homePosts:
      return _getHomePostsQuery(loadLimit: loadLimit);
      case CommonPostsType.bookmarkedPosts:
        return _getBookmarkedPostsQuery(loadLimit: loadLimit);
        case CommonPostsType.empathizedPosts:
        return _getEmpathizedPostsQuery(loadLimit: loadLimit);
      case CommonPostsType.myPosts:
        return _getMyPostsQuery(loadLimit: loadLimit);
      case CommonPostsType.myReplies:
        return _getMyRepliesQuery(loadLimit: loadLimit);
      case CommonPostsType.searchResultPosts:
        return _getSearchResultPostsQuery(
          loadLimit: loadLimit,
          postField: postField!,
          searchWord: searchWord!,
        );      
    }
  }

  Query<Map<String, dynamic>> loadCommonPostsQuery({
    required CommonPostsType type,
    required int loadLimit,
    required DocumentSnapshot<Object?> lastVisibleOfTheBatch,
    String? postField,
    String? searchWord,
  }) {
    switch (type) {
      case CommonPostsType.homePosts:
      return _loadHomePostsQuery(
          loadLimit: loadLimit,
          lastVisibleOfTheBatch: lastVisibleOfTheBatch,
        );
      case CommonPostsType.bookmarkedPosts:
        return _loadBookmarkedPostsQuery(
          loadLimit: loadLimit,
          lastVisibleOfTheBatch: lastVisibleOfTheBatch,
        );
      case CommonPostsType.empathizedPosts:
        return _loadEmpathizedPostsQuery(
          loadLimit: loadLimit,
          lastVisibleOfTheBatch: lastVisibleOfTheBatch,
        );
      case CommonPostsType.myPosts:
        return _loadMyPostsQuery(
          loadLimit: loadLimit,
          lastVisibleOfTheBatch: lastVisibleOfTheBatch,
        );
      case CommonPostsType.myReplies:
        return _loadMyRepliesQuery(
          loadLimit: loadLimit,
          lastVisibleOfTheBatch: lastVisibleOfTheBatch,
        );
      case CommonPostsType.searchResultPosts:
        return _loadSearchResultPostsQuery(
          loadLimit: loadLimit,
          lastVisibleOfTheBatch: lastVisibleOfTheBatch,
          postField: postField!,
          searchWord: searchWord!,
        );
    }
  }

  Query<Map<String, dynamic>> _getHomePostsQuery({
    required int loadLimit,
  }) {
    return firestore
        .collectionGroup('posts')
        .orderBy('createdAt', descending: true)
        .limit(loadLimit);
  }

  Query<Map<String, dynamic>> _loadHomePostsQuery({
    required int loadLimit,
    required DocumentSnapshot<Object?> lastVisibleOfTheBatch,
  }) {
    return firestore
        .collectionGroup('posts')
        .orderBy('createdAt', descending: true)
        .startAfterDocument(lastVisibleOfTheBatch)
        .limit(loadLimit);
  }

  Query<Map<String, dynamic>> _getBookmarkedPostsQuery({
    required int loadLimit,
  }) {
    return firestore
        .collection('users')
        .doc(auth.currentUser?.uid)
        .collection('bookmarkedPosts')
        .orderBy('createdAt', descending: true)
        .limit(loadLimit);
  }

  Query<Map<String, dynamic>> _loadBookmarkedPostsQuery({
    required int loadLimit,
    required DocumentSnapshot<Object?> lastVisibleOfTheBatch,
  }) {
    return firestore
        .collection('users')
        .doc(auth.currentUser?.uid)
        .collection('bookmarkedPosts')
        .orderBy('createdAt', descending: true)
        .startAfterDocument(lastVisibleOfTheBatch)
        .limit(loadLimit);
  }

  Query<Map<String, dynamic>> _getEmpathizedPostsQuery({
    required int loadLimit,
  }) {
    return firestore
        .collection('users')
        .doc(auth.currentUser?.uid)
        .collection('empathizedPosts')
        .orderBy('createdAt', descending: true)
        .limit(loadLimit);
  }

  Query<Map<String, dynamic>> _loadEmpathizedPostsQuery({
    required int loadLimit,
    required DocumentSnapshot<Object?> lastVisibleOfTheBatch,
  }) {
    return firestore
        .collection('users')
        .doc(auth.currentUser?.uid)
        .collection('empathizedPosts')
        .orderBy('createdAt', descending: true)
        .startAfterDocument(lastVisibleOfTheBatch)
        .limit(loadLimit);
  }

  Query<Map<String, dynamic>> _getMyPostsQuery({
    required int loadLimit,
  }) {
    return firestore
        .collection('users')
        .doc(auth.currentUser?.uid)
        .collection('posts')
        .orderBy('updatedAt', descending: true)
        .limit(loadLimit);
  }

  Query<Map<String, dynamic>> _loadMyPostsQuery({
    required int loadLimit,
    required DocumentSnapshot<Object?> lastVisibleOfTheBatch,
  }) {
    return firestore
        .collection('users')
        .doc(auth.currentUser?.uid)
        .collection('posts')
        .orderBy('updatedAt', descending: true)
        .startAfterDocument(lastVisibleOfTheBatch)
        .limit(loadLimit);
  }

  Query<Map<String, dynamic>> _getMyRepliesQuery({
    required int loadLimit,
  }) {
    return firestore
        .collectionGroup('replies')
        .where('replierId', isEqualTo: auth.currentUser?.uid)
        .orderBy('updatedAt', descending: true)
        .limit(loadLimit);
  }

  Query<Map<String, dynamic>> _loadMyRepliesQuery({
    required int loadLimit,
    required DocumentSnapshot<Object?> lastVisibleOfTheBatch,
  }) {
    return firestore
        .collectionGroup('replies')
        .where('replierId', isEqualTo: auth.currentUser?.uid)
        .orderBy('updatedAt', descending: true)
        .startAfterDocument(lastVisibleOfTheBatch)
        .limit(loadLimit);
  }

  Query<Map<String, dynamic>> _getSearchResultPostsQuery({
    required int loadLimit,
    required String postField,
    required String searchWord,
  }) {
    // postのfieldの値が配列(array)のとき
    // Todo positionも複数選択に変える予定なので、おいおいこっちの条件に||で追加するはず
    if (postField == 'categories') {
      return firestore
          .collectionGroup('posts')
          .where(postField, arrayContains: searchWord)
          .orderBy('createdAt', descending: true)
          .limit(loadLimit);
    } else {
      return firestore
          .collectionGroup('posts')
          .where(postField, isEqualTo: searchWord)
          .orderBy('createdAt', descending: true)
          .limit(loadLimit);
    }
  }

  Query<Map<String, dynamic>> _loadSearchResultPostsQuery({
    required int loadLimit,
    required DocumentSnapshot<Object?> lastVisibleOfTheBatch,
    required String postField,
    required String searchWord,
  }) {
    // postのfieldの値が配列(array)のとき
    // Todo positionも複数選択に変える予定なので、おいおいこっちの条件に||で追加するはず
    if (postField == 'categories') {
      return firestore
          .collectionGroup('posts')
          .where(postField, arrayContains: searchWord)
          .orderBy('createdAt', descending: true)
          .startAfterDocument(lastVisibleOfTheBatch)
          .limit(loadLimit);
    } else {
      return firestore
          .collectionGroup('posts')
          .where(postField, isEqualTo: searchWord)
          .orderBy('createdAt', descending: true)
          .startAfterDocument(lastVisibleOfTheBatch)
          .limit(loadLimit);
    }
  }

  FieldValue serverTimestamp() {
    return FieldValue.serverTimestamp();
  }
}
