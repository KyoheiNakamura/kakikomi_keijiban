import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EmpathizedPostInfo {
  EmpathizedPostInfo(DocumentSnapshot doc) {
    final map = doc.data()! as Map<String, dynamic>;
    id = map['id'] as String;
    userId = map['userId'] as String;
    postId = map['postId'] as String;
    replyId = map['replyId'] as String;
    replyToReplyId = map['replyToReplyId'] as String;
    postType = map['postType'] as String;
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

  String _formatDate(DateTime date) {
    final formatter = DateFormat('yyyy/MM/dd/ HH:mm');
    return formatter.format(date);
  }
}

class EmpathizedPost {
  EmpathizedPost(DocumentSnapshot doc) {
    final map = doc.data()! as Map<String, dynamic>;
    posterId = map['userId'] as String;
    // Postモデルでは id が postId であるため
    postId =
        map['postId'] != null ? map['postId'] as String : map['id'] as String;
    replierId = map['replierId'] != null ? map['replierId'] as String : '';
    emotion = map['emotion'] != null ? map['emotion'] as String : '';
    title = map['title'] != null ? map['title'] as String : '';
    body = map['body'] as String;
    nickname = map['nickname'] as String;
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
