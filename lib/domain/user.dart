import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class User {
  User(DocumentSnapshot doc) {
    this.id = doc.id;
    this.nickname = doc['nickName'];
    this._createdAt = doc['createdAt'].toDate();
    this._updatedAt = doc['updatedAt'].toDate();
  }

  String id = '';
  String nickname = '';
  String password = '';
  DateTime? _createdAt;
  DateTime? _updatedAt;

  String get createdAt => _formatDate(_createdAt);
  String get updatedAt => _formatDate(_updatedAt);

  String _formatDate(date) {
    final formatter = DateFormat('yyyy年MM月dd日 HH時mm分');
    return date != null ? formatter.format(date) : '';
  }
}
