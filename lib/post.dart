import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kakikomi_keijiban/constants.dart';

class Post {
  Post(DocumentSnapshot doc) {
    this.id = doc.id;
    this.title = doc['title'];
    this.textBody = doc['textBody'];
    this.nickname = doc['nickname'];
    this.emotion = doc['emotion'];
    this.position = doc['position'];
    this.gender =
        doc['gender'] != kPleaseSelect && doc['gender'] != kDoNotSelect
            ? doc['gender']
            : '';
    this.age = doc['age'] != kPleaseSelect && doc['age'] != kDoNotSelect
        ? doc['age']
        : '';
    this.area = doc['area'] != kPleaseSelect && doc['area'] != kDoNotSelect
        ? doc['area']
        : '';
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
  DateTime? _createdAt;
  DateTime? _updatedAt;

  String get createdAt => _formatDate(_createdAt);
  String get updatedAt => _formatDate(_updatedAt);

  String _formatDate(date) {
    final formatter = DateFormat('yyyy年MM月dd日 HH時mm分');
    return date != null ? formatter.format(date) : '';
  }
}
