import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Notice {
  Notice(DocumentSnapshot doc) {
    this.id = doc.id;
    this.userId = doc['userId'];
    this.postId = doc['postId'];
    this.posterId = doc['posterId'];
    this.title = doc['title'];
    this.body = doc['body'];
    this.nickname = doc['nickname'];
    this.emotion = doc['emotion'];
    this.isRead = doc['isRead'];
    final Timestamp createdTime = doc['createdAt'];
    this.createdDate = createdTime.toDate();
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

  String _formatDate(date) {
    final formatter = DateFormat('MM/dd HH:mm');
    return date != null ? formatter.format(date) : '';
  }
}
