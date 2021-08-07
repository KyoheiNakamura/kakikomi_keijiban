import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';
import 'package:kakikomi_keijiban/entity/reply.dart';
import 'package:kakikomi_keijiban/util/date_util.dart';

// enum PostField {
//   id,
//   userId,
// }

// String postField(PostField field) {
//   switch (field) {
//     case PostField.id:
//     return field.toString();
//     case PostField.userId:
//       return field.toString();
//   }
// }

class PostField {
  static const id = 'id';
  static const userId = 'userId';
  static const title = 'title';
  static const body = 'body';
  static const nickname = 'nickname';
  static const emotion = 'emotion';
  static const position = 'position';
  static const gender = 'gender';
  static const age = 'age';
  static const area = 'area';
  static const categories = 'categories';
  static const replyCount = 'replyCount';
  static const empathyCount = 'empathyCount';
  static const isReplyExisting = 'isReplyExisting';
  static const createdAt = 'createdAt';
  static const updatedAt = 'updatedAt';
}

class Post {
  // Post.fromDoc(DocumentSnapshot doc) {
  //   id = doc.id;
  //   userId = doc['userId'] as String;
  //   title = doc['title'] as String;
  //   body = doc['body'] as String;
  //   nickname = doc['nickname'] as String;
  //   emotion = doc['emotion'] as String;
  //   position = doc['position'] != '' ? doc['position'] as String : '';
  //   gender = doc['gender'] != '' ? doc['gender'] as String : '';
  //   age = doc['age'] != '' ? doc['age'] as String : '';
  //   area = doc['area'] != '' ? doc['area'] as String : '';
  //   final _categories = doc['categories'] as List<dynamic>;
  //   categories = List<String>.from(_categories);
  //   // categories = doc['categories'] as List<String>;
  //   replyCount = doc['replyCount'] as int;
  //   empathyCount = doc['empathyCount'] as int;
  //   isReplyExisting = doc['isReplyExisting'] as bool;
  //   createdAt = doc['createdAt'] as Timestamp;
  //   updatedAt = doc['updatedAt'] as Timestamp;
  // }

  Post({
    this.id,
    this.userId,
    this.title,
    this.body,
    this.nickname,
    this.emotion,
    this.position,
    this.gender,
    this.age,
    this.area,
    this.categories,
    this.replyCountFieldValue,
    this.empathyCountFieldValue,
    this.isReplyExisting,
    this.createdAtFieldValue,
    this.updatedAtFieldValue,
  });

  Post.fromDoc(DocumentSnapshot snapshot) {
    final map = snapshot.data()! as Map<String, dynamic>;
    id = map[PostField.id] as String;
    userId = map[PostField.userId] as String;
    title = map[PostField.title] as String;
    body = map[PostField.body] as String;
    nickname = map[PostField.nickname] as String;
    emotion = map[PostField.emotion] as String;
    position = map[PostField.position] as String;
    gender = map[PostField.gender] as String;
    age = map[PostField.age] as String;
    area = map[PostField.area] as String;
    final _categories = map[PostField.categories] as List<dynamic>;
    categories = List<String>.from(_categories);
    replyCount = map[PostField.replyCount] as int;
    empathyCount = map[PostField.empathyCount] as int;
    isReplyExisting = map[PostField.isReplyExisting] as bool;
    createdAt = map[PostField.createdAt] as Timestamp;
    updatedAt = map[PostField.updatedAt] as Timestamp;
  }

  Post.fromMap(Map<String, dynamic> map) {
    id = map[PostField.id] as String;
    userId = map[PostField.userId] as String;
    title = map[PostField.title] as String;
    body = map[PostField.body] as String;
    nickname = map[PostField.nickname] as String;
    emotion = map[PostField.emotion] as String;
    position = map[PostField.position] as String;
    gender = map[PostField.gender] as String;
    age = map[PostField.age] as String;
    area = map[PostField.area] as String;
    final _categories = map[PostField.categories] as List<dynamic>;
    categories = List<String>.from(_categories);
    replyCount = map[PostField.replyCount] as int;
    empathyCount = map[PostField.empathyCount] as int;
    isReplyExisting = map[PostField.isReplyExisting] as bool;
    createdAt = map[PostField.createdAt] as Timestamp;
    updatedAt = map[PostField.updatedAt] as Timestamp;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      PostField.id: id,
      PostField.userId: userId,
      PostField.title: title,
      PostField.body: body,
      PostField.nickname: nickname,
      PostField.emotion: emotion,
      PostField.position: position,
      PostField.gender: gender,
      PostField.age: age,
      PostField.area: area,
      PostField.categories: categories,
      PostField.replyCount: replyCountFieldValue,
      PostField.empathyCount: empathyCountFieldValue,
      PostField.isReplyExisting: isReplyExisting,
      PostField.createdAt: createdAtFieldValue,
      PostField.updatedAt: updatedAtFieldValue,
    }..removeWhere((key, dynamic value) => value == null);
  }

  // Map<String, dynamic> toMap() {
  //   return {
  //     'id': postRef.id,
  //     'userId': uid,
  //     'title': removeUnnecessaryBlankLines(titleValue),
  //     'body': removeUnnecessaryBlankLines(bodyValue),
  //     'nickname': removeUnnecessaryBlankLines(nicknameValue),
  //     'emotion': convertNoSelectedValueToEmpty(emotionDropdownValue),
  //     'position': convertNoSelectedValueToEmpty(positionDropdownValue),
  //     'gender': convertNoSelectedValueToEmpty(genderDropdownValue),
  //     'age': convertNoSelectedValueToEmpty(ageDropdownValue),
  //     'area': convertNoSelectedValueToEmpty(areaDropdownValue),
  //     'categories': selectedCategories,
  //     'replyCount': 0,
  //     'empathyCount': 0,
  //     'isReplyExisting': false,
  //     'createdAt': serverTimestamp(),
  //     'updatedAt': serverTimestamp(),
  //   };
  // }

  String? id;
  String? userId;
  String? title;
  String? body;
  String? nickname;
  String? emotion;
  String? position;
  String? gender;
  String? age;
  String? area;
  List<String>? categories;
  FieldValue? replyCountFieldValue;
  int? replyCount;
  FieldValue? empathyCountFieldValue;
  int? empathyCount;
  bool? isReplyExisting;
  FieldValue? createdAtFieldValue;
  Timestamp? createdAt;
  FieldValue? updatedAtFieldValue;
  Timestamp? updatedAt;

  // String id = '';
  // String userId = '';
  // String title = '';
  // String body = '';
  // String nickname = '';
  // String emotion = '';
  // String position = '';
  // String gender = '';
  // String age = '';
  // String area = '';
  // List<String> categories = [];
  // int replyCount = 0;
  // int empathyCount = 0;
  // bool isReplyExisting = false;
  // Timestamp createdAt = Timestamp.now();
  // Timestamp updatedAt = Timestamp.now();

  bool isBookmarked = false;
  bool isEmpathized = false;
  bool isReplyShown = false;
  bool isDraft = false;
  List<Reply> replies = [];

  // String get createdDate => _formatDate(createdAt!);
  String get createdDate => DateUtil.formatTimestampToString(createdAt!);
  // String get updatedDate => _formatDate(updatedAt!);
  String get updatedDate => DateUtil.formatTimestampToString(updatedAt!);

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    // final formatter = DateFormat('yyyy/MM/dd HH:mm');
    final formatter = DateFormat('MM/dd HH:mm');
    return formatter.format(date);
  }

  bool isMe() {
    final currentUser = auth.currentUser;
    return userId == currentUser?.uid;
  }
}
