import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserProfile {
  UserProfile(DocumentSnapshot doc) {
    this.id = doc.id;
    this.nickname = doc['nickname'];
    this.position = doc['position'];
    this.gender = doc['gender'];
    this.age = doc['age'];
    this.area = doc['area'];
    this.postCount = doc['postCount'];
    final createdDate = doc['createdAt'].toDate();
    this._createdAt = createdDate;
    if (doc['updatedAt'] != null) {
      final updatedDate = doc['updatedAt'].toDate();
      this._updatedAt = updatedDate;
    }
  }

  String id = '';
  String nickname = '';
  String position = '';
  String gender = '';
  String age = '';
  String area = '';
  int postCount = 0;
  DateTime? _createdAt;
  DateTime? _updatedAt;

  String get createdAt => _formatDate(_createdAt);
  String get updatedAt => _formatDate(_updatedAt);

  String _formatDate(date) {
    final formatter = DateFormat('yyyy/MM/dd HH:mm');
    return date != null ? formatter.format(date) : '';
  }
}
