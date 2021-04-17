import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:kakikomi_keijiban/common/constants.dart';

class User {
  User(DocumentSnapshot doc) {
    this.id = doc.id;
    this.nickname = doc['nickname'];
    this.position =
        doc['position'].isNotEmpty ? doc['position'] : kPleaseSelect;
    this.gender = doc['gender'].isNotEmpty ? doc['gender'] : kPleaseSelect;
    this.age = doc['age'].isNotEmpty ? doc['age'] : kPleaseSelect;
    this.area = doc['area'].isNotEmpty ? doc['area'] : kPleaseSelect;
    this.postCount = doc['postCount'];
    // final createdDate = doc['createdAt'].toDate();
    // this._createdAt = createdDate;
    // if (doc['updatedAt'] != null) {
    //   final updatedDate = doc['updatedAt'].toDate();
    //   this._updatedAt = updatedDate;
    // }
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

  bool? isCurrentUserAnonymous() {
    final currentUser = FirebaseAuth.instance.currentUser;
    return currentUser?.isAnonymous;
  }
}
