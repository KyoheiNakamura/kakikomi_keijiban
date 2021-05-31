import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';
import 'package:kakikomi_keijiban/domain/reply_to_reply.dart';

class Reply {
  Reply(DocumentSnapshot doc) {
    id = doc.id;
    postId = doc['postId'] as String;
    userId = doc['userId'] as String;
    replierId = doc['replierId'] as String;
    body = doc['body'] as String;
    nickname = doc['nickname'] as String;
    position = doc['position'] != '' ? doc['position'] as String : '';
    gender = doc['gender'] != '' ? doc['gender'] as String : '';
    age = doc['age'] != '' ? doc['age'] as String : '';
    area = doc['area'] != '' ? doc['area'] as String : '';
    empathyCount = doc['empathyCount'] as int;
    createdDate = (doc['createdAt'] as Timestamp).toDate();
    updatedDate = (doc['updatedAt'] as Timestamp).toDate();
  }

  String id = '';
  String userId = '';
  String postId = '';
  String replierId = '';
  String body = '';
  String nickname = '';
  String position = '';
  String gender = '';
  String age = '';
  String area = '';
  int empathyCount = 0;
  DateTime createdDate = DateTime.now();
  DateTime updatedDate = DateTime.now();

  bool isDraft = false;
  bool isEmpathized = false;
  List<ReplyToReply> repliesToReply = [];

  String get createdAt => _formatDate(createdDate);
  String get updatedAt => _formatDate(updatedDate);

  String _formatDate(DateTime date) {
    final formatter = DateFormat('yyyy/MM/dd HH:mm');
    return formatter.format(date);
  }

  bool isMe() {
    final currentUser = auth.currentUser;
    return replierId == currentUser?.uid;
  }
}
