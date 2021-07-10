import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Notice {
  Notice(DocumentSnapshot doc) {
    id = doc.id;
    userId = doc['userId'] as String;
    postId = doc['postId'] as String;
    posterId = doc['posterId'] as String;
    title = doc['title'] as String;
    body = doc['body'] as String;
    nickname = doc['nickname'] as String;
    emotion = doc['emotion'] as String;
    isRead = doc['isRead'] as bool;
    createdDate = (doc['createdAt'] as Timestamp).toDate();
  }

  String id = '';
  String userId = '';
  String postId = '';
  String posterId = '';
  String title = '';
  String body = '';
  String nickname = '';
  String emotion = '';
  bool isRead = false;
  DateTime createdDate = DateTime.now();

  String get createdAt => _formatDate(createdDate);

  String _formatDate(DateTime date) {
    final formatter = DateFormat('yyyy/MM/dd HH:mm');
    return formatter.format(date);
  }
}
