import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class User {
  User(DocumentSnapshot doc) {
    this.id = doc.id;
    this.email = doc['title'];
    this.nickname = doc['nickName'];
    this.password = doc['textBody'];
    final createdDate = doc['createdAt'].toDate();
    this._createdAt = createdDate;
  }

  String id = '';
  String email = '';
  String nickname = '';
  String password = '';
  DateTime? _createdAt;

  String get createdAt => _formatDate(_createdAt);

  String _formatDate(date) {
    final formatter = DateFormat('yyyy年MM月dd日 HH時mm分');
    return date != null ? formatter.format(date) : '';
  }
}
