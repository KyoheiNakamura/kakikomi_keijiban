import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';

class User {
  User(DocumentSnapshot doc) {
    id = doc.id;
    nickname = doc['nickname'] as String;
    position = (doc['position'] as String).isNotEmpty
        ? doc['position'] as String
        : kPleaseSelect;
    gender = (doc['gender'] as String).isNotEmpty
        ? doc['gender'] as String
        : kPleaseSelect;
    age = (doc['age'] as String).isNotEmpty
        ? doc['age'] as String
        : kPleaseSelect;
    area = (doc['area'] as String).isNotEmpty
        ? doc['area'] as String
        : kPleaseSelect;
    postCount = doc['postCount'] as int;
    final _topics = doc['topics'] as List<dynamic>;
    topics = List<String>.from(_topics);
    final _pushNoticesSetting = doc['pushNoticesSetting'] as List<dynamic>;
    pushNoticesSetting = List<String>.from(_pushNoticesSetting);
    final _badges = doc['badges'] as Map<String, dynamic>;
    badges = Map<String, bool>.from(_badges);
    // topics = doc['topics'] as List<String>;
    // pushNoticesSetting = doc['pushNoticesSetting'] as List<String>;
    // badges = doc['badges'] as Map<String, bool>;
    // createdDate = (doc['createdAt'] as Timestamp).toDate();
    // updatedDate = (doc['updatedAt'] as Timestamp).toDate();
  }

  String id = '';
  String nickname = '';
  String position = '';
  String gender = '';
  String age = '';
  String area = '';
  int postCount = 0;
  List<String> topics = [];
  List<String> pushNoticesSetting = [];
  Map<String, bool> badges = {};
  // DateTime createdDate = DateTime.now();
  // DateTime updatedDate = DateTime.now();

  // String get createdAt => _formatDate(createdDate);
  // String get updatedAt => _formatDate(updatedDate);

  // String _formatDate(DateTime date) {
  //   final formatter = DateFormat('yyyy/MM/dd HH:mm');
  //   return formatter.format(date);
  // }

  bool? isCurrentUserAnonymous() {
    final currentUser = auth.currentUser;
    return currentUser?.isAnonymous;
  }

  String? get email => getEmail();

  String? getEmail() {
    final currentUser = auth.currentUser;
    return currentUser?.email;
  }
}
