import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Reply {
  Reply(DocumentSnapshot doc) {
    this.text = doc['text'];
    this.id = doc.id;
    // this.postId = doc.reference.parent.parent.id;
    final date = doc['createdAt'].toDate();
    this._createdAt = date;
  }

  String text;
  String id;
  // String postId;
  DateTime _createdAt;

  String get createdAt => _formatDate();

  String _formatDate() {
    final formatter = DateFormat('yyyy年MM月dd日 HH時mm分');
    return formatter.format(_createdAt);
  }
}
