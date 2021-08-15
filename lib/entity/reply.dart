import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';
import 'package:kakikomi_keijiban/entity/reply_to_reply.dart';
import 'package:kakikomi_keijiban/util/date_util.dart';

class Reply {
  Reply(DocumentSnapshot doc) {
    id = doc.id;
    postId = doc['postId'] as String;
    userId = doc['userId'] as String;
    replierId = doc['replierId'] as String;
    body = doc['body'] as String;
    nickname = doc['nickname'] as String;
    emotion = doc['emotion'] as String;
    position = doc['position'] != '' ? doc['position'] as String : '';
    gender = doc['gender'] != '' ? doc['gender'] as String : '';
    age = doc['age'] != '' ? doc['age'] as String : '';
    area = doc['area'] != '' ? doc['area'] as String : '';
    replyCount = doc['replyCount'] as int;
    empathyCount = doc['empathyCount'] as int;
    // createdDate = (doc['createdAt'] as Timestamp).toDate();
    createdDate = doc['createdAt'] as Timestamp? ?? Timestamp.now();
    // updatedDate = (doc['updatedAt'] as Timestamp).toDate();
    updatedDate = doc['updatedAt'] as Timestamp? ?? Timestamp.now();
  }

  String id = '';
  String userId = '';
  String postId = '';
  String replierId = '';
  String body = '';
  String nickname = '';
  String emotion = '';
  String position = '';
  String gender = '';
  String age = '';
  String area = '';
  int replyCount = 0;
  int empathyCount = 0;
  Timestamp createdDate = Timestamp.now();
  Timestamp updatedDate = Timestamp.now();

  bool isDraft = false;
  bool isEmpathized = false;
  List<ReplyToReply> repliesToReply = [];

  String get createdAt => DateUtil.formatTimestampToString(createdDate);
  String get updatedAt => DateUtil.formatTimestampToString(createdDate);

  String _formatDate(DateTime date) {
    final formatter = DateFormat('yyyy/MM/dd HH:mm');
    return formatter.format(date);
  }

  bool isMe() {
    final currentUser = auth.currentUser;
    return replierId == currentUser?.uid;
  }
}
