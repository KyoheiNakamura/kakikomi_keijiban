import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';

class Post {
  Post(DocumentSnapshot doc) {
    this.id = doc.id;
    this.title = doc['title'];
    this.body = doc['body'];
    this.nickname = doc['nickname'];
    this.emotion = doc['emotion'];
    this.position = doc['position'] != '' ? doc['position'] : '';
    this.gender = doc['gender'] != '' ? doc['gender'] : '';
    this.age = doc['age'] != '' ? doc['age'] : '';
    this.area = doc['area'] != '' ? doc['area'] : '';
    final List<dynamic> _categories = doc['categories'];
    // List<dynamic>をList<String>に変換してる
    this.categories = List<String>.from(_categories);
    this.uid = doc.reference.parent.parent!.id;
    this.replyCount = doc['replyCount'];
    this.isBookmarked = false;
    this.isReplyShown = false;
    this.replies = [];
    this._createdAt = doc['createdAt'].toDate();
    if (doc['updatedAt'] != null) {
      final updatedDate = doc['updatedAt'].toDate();
      this._updatedAt = updatedDate;
    }
  }

  String id = '';
  String title = '';
  String body = '';
  String nickname = '';
  String emotion = '';
  String position = '';
  String gender = '';
  String age = '';
  String area = '';
  List<String> categories = [];
  String uid = '';
  int replyCount = 0;
  bool isBookmarked = false;
  bool isReplyShown = false;
  List<Reply> replies = [];
  DateTime? _createdAt;
  DateTime? _updatedAt;

  String get createdAt => _formatDate(_createdAt);
  String get updatedAt => _formatDate(_updatedAt);

  String _formatDate(date) {
    final formatter = DateFormat('yyyy/MM/dd HH:mm');
    return date != null ? formatter.format(date) : '';
  }
}
