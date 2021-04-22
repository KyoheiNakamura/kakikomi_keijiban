import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ReplyToReply {
  ReplyToReply(DocumentSnapshot doc) {
    this.id = doc.id;
    this.userId = doc['userId'];
    this.postId = doc['postId'];
    this.replyId = doc['replyId'];
    this.replierId = doc['replierId'];
    this.body = doc['body'];
    this.nickname = doc['nickname'];
    this.position = doc['position'] != '' ? doc['position'] : '';
    this.gender = doc['gender'] != '' ? doc['gender'] : '';
    this.age = doc['age'] != '' ? doc['age'] : '';
    this.area = doc['area'] != '' ? doc['area'] : '';
    this.isDraft = false;
    final createdDate = doc['createdAt'].toDate();
    this._createdAt = createdDate;
    if (doc['updatedAt'] != null) {
      final updatedDate = doc['updatedAt'].toDate();
      this._updatedAt = updatedDate;
    }
  }

  String id = '';
  String userId = '';
  String postId = '';
  String replyId = '';
  String replierId = '';
  String body = '';
  String nickname = '';
  String position = '';
  String gender = '';
  String age = '';
  String area = '';
  bool isDraft = false;
  DateTime? _createdAt;
  DateTime? _updatedAt;

  String get createdAt => _formatDate(_createdAt);
  String get updatedAt => _formatDate(_updatedAt);

  String _formatDate(date) {
    final formatter = DateFormat('yyyy/MM/dd HH:mm');
    return date != null ? formatter.format(date) : '';
  }

  bool isMe() {
    final currentUser = FirebaseAuth.instance.currentUser;
    return replierId == currentUser?.uid;
  }
}
