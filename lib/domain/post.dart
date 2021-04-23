import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';

class Post {
  Post(DocumentSnapshot doc) {
    this.id = doc.id;
    this.userId = doc['userId'];
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
    this.replyCount = doc['replyCount'];
    this.empathyCount = doc['empathyCount'];
    this.isBookmarked = false;
    this.isEmpathized = false;
    this.isReplyShown = false;
    this.isDraft = false;
    this.replies = [];
    final Timestamp createdTime = doc['createdAt'];
    this._createdAt = createdTime.toDate();
    if (doc['updatedAt'] != null) {
      final Timestamp updatedTime = doc['updatedAt'];
      this._updatedAt = updatedTime.toDate();
    }
  }

  String id = '';
  String userId = '';
  String title = '';
  String body = '';
  String nickname = '';
  String emotion = '';
  String position = '';
  String gender = '';
  String age = '';
  String area = '';
  List<String> categories = [];
  int replyCount = 0;
  int empathyCount = 0;
  bool isBookmarked = false;
  bool isEmpathized = false;
  bool isReplyShown = false;
  bool isDraft = false;
  List<Reply> replies = [];
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
    return userId == currentUser?.uid;
  }
}
