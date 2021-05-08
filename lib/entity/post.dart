import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';
import 'package:kakikomi_keijiban/entity/reply.dart';

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
    // List<dynamic>をList<String>に変換してる
    final List<dynamic> _categories = doc['categories'];
    this.categories = List<String>.from(_categories);
    this.replyCount = doc['replyCount'];
    this.empathyCount = doc['empathyCount'];
    this.isReplyExisting = doc['isReplyExisting'];
    final Timestamp createdTime = doc['createdAt'];
    this.createdDate = createdTime.toDate();
    final Timestamp updatedTime = doc['updatedAt'];
    this.updatedDate = updatedTime.toDate();
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
  bool isReplyExisting = false;
  bool isBookmarked = false;
  bool isEmpathized = false;
  bool isReplyShown = false;
  bool isDraft = false;
  List<Reply> replies = [];
  DateTime createdDate = DateTime.now();
  DateTime updatedDate = DateTime.now();

  String get createdAt => _formatDate(createdDate);
  String get updatedAt => _formatDate(updatedDate);

  String _formatDate(date) {
    final formatter = DateFormat('yyyy/MM/dd HH:mm');
    return date != null ? formatter.format(date) : '';
  }

  bool isMe() {
    final currentUser = auth.currentUser;
    return userId == currentUser?.uid;
  }
}
