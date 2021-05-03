import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:kakikomi_keijiban/domain/reply_to_reply.dart';

class Reply {
  Reply(DocumentSnapshot doc) {
    this.id = doc.id;
    this.userId = doc['userId'];
    this.postId = doc['postId'];
    this.replierId = doc['replierId'];
    this.body = doc['body'];
    this.nickname = doc['nickname'];
    this.position = doc['position'] != '' ? doc['position'] : '';
    this.gender = doc['gender'] != '' ? doc['gender'] : '';
    this.age = doc['age'] != '' ? doc['age'] : '';
    this.area = doc['area'] != '' ? doc['area'] : '';
    this.empathyCount = doc['empathyCount'];
    this.isDraft = false;
    this.isEmpathized = false;
    this.repliesToReply = [];
    final createdDate = doc['createdAt'].toDate();
    this.createdDate = createdDate;
    final updatedDate = doc['updatedAt'].toDate();
    this.updatedDate = updatedDate;
  }

  String id = '';
  String userId = '';
  String postId = '';
  String replierId = '';
  String body = '';
  String nickname = '';
  String position = '';
  String gender = '';
  String age = '';
  String area = '';
  int empathyCount = 0;
  bool isDraft = false;
  bool isEmpathized = false;
  List<ReplyToReply> repliesToReply = [];
  DateTime createdDate = DateTime.now();
  DateTime updatedDate = DateTime.now();

  String get createdAt => _formatDate(createdDate);
  String get updatedAt => _formatDate(updatedDate);

  String _formatDate(date) {
    final formatter = DateFormat('yyyy/MM/dd HH:mm');
    return date != null ? formatter.format(date) : '';
  }

  bool isMe() {
    final currentUser = FirebaseAuth.instance.currentUser;
    return replierId == currentUser?.uid;
  }
}
