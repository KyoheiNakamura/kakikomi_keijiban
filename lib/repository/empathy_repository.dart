import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';

class EmpathyRepository {
  EmpathyRepository._();
  static EmpathyRepository instance = EmpathyRepository._();

  List<String> empathizedPostsIds = [];

  /// 初期化処理
  Future<void> init() async {
    await _getEmpathizedPostsIds();
    _subscribeEmpathizedPostsIdsChange();
  }

  /// ユーザーの「ワカル」一覧をキャッシュから取得する
  Future<void> _getEmpathizedPostsIds() async {
    try {
      final empathizedPostsSnapshot = await firestore
          .collection('users')
          .doc(auth.currentUser?.uid)
          .collection('empathizedPosts')
          .get(const GetOptions(source: Source.cache));
      empathizedPostsIds = empathizedPostsSnapshot.docs
          .map((empathizedPost) => empathizedPost.id)
          .toList();
    } on Exception catch (_) {
      // キャッシュにデータが無ければエラーが出るのでここで処理。
      // 何もしない。
    }
  }

  /// ユーザーの「ワカル」をリッスンする
  void _subscribeEmpathizedPostsIdsChange() {
    firestore
        .collection('users')
        .doc(auth.currentUser?.uid)
        .collection('empathizedPosts')
        .snapshots()
        .listen((snapshot) {
      empathizedPostsIds = snapshot.docs.map((empathizedPost) {
        return empathizedPost.id;
      }).toList();
    });
  }
}
