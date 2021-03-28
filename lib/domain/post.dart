import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Post {
  Post(DocumentSnapshot doc) {
    this.id = doc.id;
    this.title = doc['title'];
    this.textBody = doc['textBody'];
    this.nickname = doc['nickname'];
    this.emotion = doc['emotion'];
    this.position = doc['position'];
    this.gender = doc['gender'] != '' ? doc['gender'] : '';
    this.age = doc['age'] != '' ? doc['age'] : '';
    this.area = doc['area'] != '' ? doc['area'] : '';
    this.uid = doc['uid'] != '' ? doc['uid'] : '';
    final createdDate = doc['createdAt'].toDate();
    this._createdAt = createdDate;
    if (doc['updatedAt'] != null) {
      final updatedDate = doc['updatedAt'].toDate();
      this._updatedAt = updatedDate;
    }
  }

  String id = '';
  String title = '';
  String textBody = '';
  String nickname = '';
  String emotion = '';
  String position = '';
  String gender = '';
  String age = '';
  String area = '';
  String uid = '';
  DateTime? _createdAt;
  DateTime? _updatedAt;

  String get createdAt => _formatDate(_createdAt);
  String get updatedAt => _formatDate(_updatedAt);

  String _formatDate(date) {
    final formatter = DateFormat('yyyy年MM月dd日 HH時mm分');
    return date != null ? formatter.format(date) : '';
  }
}
