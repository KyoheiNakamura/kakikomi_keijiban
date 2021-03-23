import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Post {
  Post(DocumentSnapshot doc) {
    this.title = doc['title'];
    this.bodyText = doc['bodyText'];
    this.id = doc.id;
    final date = doc['createdAt'].toDate();
    this._createdAt = date;
  }

  String title;
  String bodyText;
  String id;
  DateTime _createdAt;

  String get createdAt => _formatDate();

  String _formatDate() {
    final formatter = DateFormat('yyyy年MM月dd日 HH時mm分');
    return formatter.format(_createdAt);
  }
}
