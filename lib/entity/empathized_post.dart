import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EmpathizedPostInfo {
  EmpathizedPostInfo(DocumentSnapshot doc) {
    final map = doc.data()! as Map<String, dynamic>;
    id = map['id'];
    userId = map['userId'];
    postId = map['postId'];
    replyId = map['replyId'];
    replyToReplyId = map['replyToReplyId'];
    postType = map['postType'];
    createdDate = (map['createdAt'] as Timestamp).toDate();
  }

  String id = '';
  String userId = '';
  String postId = '';
  String replyId = '';
  String replyToReplyId = '';
  String postType = '';
  DateTime createdDate = DateTime.now();
  // int myEmpathyCount = 0;

  String get createdAt => _formatDate(createdDate);

  String _formatDate(date) {
    final formatter = DateFormat('yyyy/MM/dd/ HH:mm');
    return formatter.format(date);
  }
}

class EmpathizedPost {
  EmpathizedPost(DocumentSnapshot doc) {
    final map = doc.data()! as Map<String, dynamic>;
    posterId = map['userId'];
    // Postモデルでは id が postId であるため
    postId = map['postId'] != null ? map['postId'] : map['id'];
    replierId = map['replierId'] != null ? map['replierId'] : '';
    emotion = map['emotion'] != null ? map['emotion'] : '';
    title = map['title'] != null ? map['title'] : '';
    body = map['body'];
    nickname = map['nickname'];
    createdDate = (map['createdAt'] as Timestamp).toDate();
  }

  String posterId = '';
  String postId = '';
  String replierId = '';
  String title = '';
  String body = '';
  String nickname = '';
  String emotion = '';
  DateTime createdDate = DateTime.now();

  bool isEmpathized = false;

  String get createdAt => _formatDate(createdDate);

  String _formatDate(DateTime date) {
    final formatter = DateFormat('yyyy/MM/dd/ HH:mm');
    return formatter.format(date);
  }
}
