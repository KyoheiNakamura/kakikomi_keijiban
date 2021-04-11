import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Reply {
  Reply(DocumentSnapshot doc) {
    this.id = doc.id;
    this.postId = doc['postId'];
    this.replyId = doc['replyId'];
    this.uid = doc.reference.parent.parent!.parent.parent!.parent.parent!.id;
    this.replierId = doc['replierId'];
    this.body = doc['body'];
    this.nickname = doc['nickname'];
    this.position = doc['position'] != '' ? doc['position'] : '';
    this.gender = doc['gender'] != '' ? doc['gender'] : '';
    this.age = doc['age'] != '' ? doc['age'] : '';
    this.area = doc['area'] != '' ? doc['area'] : '';

    final createdDate = doc['createdAt'].toDate();
    this._createdAt = createdDate;
    if (doc['updatedAt'] != null) {
      final updatedDate = doc['updatedAt'].toDate();
      this._updatedAt = updatedDate;
    }
  }

  String id = '';
  String postId = '';
  String replyId = '';
  String uid = '';
  String replierId = '';
  String body = '';
  String nickname = '';
  String position = '';
  String gender = '';
  String age = '';
  String area = '';
  DateTime? _createdAt;
  DateTime? _updatedAt;

  String get createdAt => _formatDate(_createdAt);
  String get updatedAt => _formatDate(_updatedAt);

  String _formatDate(date) {
    final formatter = DateFormat('yyyy/MM/dd HH:mm');
    return date != null ? formatter.format(date) : '';
  }
}
