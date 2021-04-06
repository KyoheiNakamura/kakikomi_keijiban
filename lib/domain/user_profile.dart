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
    // this._updatedAt = doc['updatedAt'].toDate();
    // print(doc['updatedAt'].toDate());
  }

  String id = '';
  String nickname = '';
  String position = '';
  String gender = '';
  String age = '';
  String area = '';
  // DateTime? _updatedAt;
  //
  // String get updatedAt => _formatDate(_updatedAt);
  //
  // String _formatDate(date) {
  //   final formatter = DateFormat('yyyy/MM/dd HH:mm');
  //   return date != null ? formatter.format(date) : '';
  // }
}
