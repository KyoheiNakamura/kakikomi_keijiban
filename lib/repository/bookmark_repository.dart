import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';

class BookmarkRepository {
  BookmarkRepository._();
  static BookmarkRepository instance = BookmarkRepository._();

  List<String> bookmarkedPostsIds = [];

  /// 初期化処理
  Future<void> init() async {
    await _getBookmarkedPostsIds();
    _subscribeBookmarkedPostsIdsChange();
  }

  /// ユーザーの「ブックマーク」一覧をキャッシュから取得する
  Future<void> _getBookmarkedPostsIds() async {
    try {
      final bookmarkedPostsSnapshot = await firestore
          .collection('users')
          .doc(auth.currentUser?.uid)
          .collection('bookmarkedPosts')
          .get(const GetOptions(source: Source.cache));
      bookmarkedPostsIds = bookmarkedPostsSnapshot.docs
          .map((bookmarkedPost) => bookmarkedPost.id)
          .toList();
    } on Exception catch (_) {
      // キャッシュにデータが無ければエラーが出るのでここで処理。
      // 何もしない。
    }
  }

  /// ユーザーの「ブックマーク」をリッスンする
  void _subscribeBookmarkedPostsIdsChange() {
    firestore
        .collection('users')
        .doc(auth.currentUser?.uid)
        .collection('bookmarkedPosts')
        .snapshots()
        .listen((snapshot) {
      bookmarkedPostsIds = snapshot.docs.map((bookmarkedPost) {
        return bookmarkedPost.id;
      }).toList();
    });
  }
}
