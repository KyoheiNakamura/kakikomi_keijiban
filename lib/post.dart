import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Post {
  Post(DocumentSnapshot doc) {
    this.id = doc.id;
    this.title = doc['title'];
    this.textBody = doc['textBody'];
    this.nickname = doc['nickname'];
    this.gender = doc['gender'];
    this.emotion = doc['emotion'];
    this.age = doc['age'];
    this.position = doc['position'];
    this.area = doc['area'];
    final date = doc['createdAt'].toDate();
    this._createdAt = date;
  }

  String id = '';
  String title = '';
  String textBody = '';
  String nickname = '';
  String gender = '';
  String emotion = '';
  String age = '';
  String position = '';
  String area = '';
  DateTime _createdAt = DateTime.now();

  String get createdAt => _formatDate();

  String _formatDate() {
    final formatter = DateFormat('yyyy年MM月dd日 HH時mm分');
    return formatter.format(_createdAt);
  }
}
