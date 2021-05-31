import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';

class Post {
  Post(DocumentSnapshot doc) {
    id = doc.id;
    userId = doc['userId'] as String;
    title = doc['title'] as String;
    body = doc['body'] as String;
    nickname = doc['nickname'] as String;
    emotion = doc['emotion'] as String;
    position = doc['position'] != '' ? doc['position'] as String : '';
    gender = doc['gender'] != '' ? doc['gender'] as String : '';
    age = doc['age'] != '' ? doc['age'] as String : '';
    area = doc['area'] != '' ? doc['area'] as String : '';
    categories = doc['categories'] as List<String>;
    replyCount = doc['replyCount'] as int;
    empathyCount = doc['empathyCount'] as int;
    isReplyExisting = doc['isReplyExisting'] as bool;
    createdDate = (doc['createdAt'] as Timestamp).toDate();
    updatedDate = (doc['updatedAt'] as Timestamp).toDate();
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
  DateTime createdDate = DateTime.now();
  DateTime updatedDate = DateTime.now();

  bool isBookmarked = false;
  bool isEmpathized = false;
  bool isReplyShown = false;
  bool isDraft = false;
  List<Reply> replies = [];

  String get createdAt => _formatDate(createdDate);
  String get updatedAt => _formatDate(updatedDate);

  String _formatDate(DateTime date) {
    final formatter = DateFormat('yyyy/MM/dd HH:mm');
    return formatter.format(date);
  }

  bool isMe() {
    final currentUser = auth.currentUser;
    return userId == currentUser?.uid;
  }
}
