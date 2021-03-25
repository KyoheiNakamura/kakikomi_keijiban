import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/post.dart';

class AddPostModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;

  String titleValue = '';
  String contentValue = '';
  String nicknameValue = '';
  String genderDropdownValue = kPleaseSelect;
  String emotionDropdownValue = kPleaseSelect;
  String ageDropdownValue = kPleaseSelect;
  String positionDropdownValue = kPleaseSelect;
  String areaDropdownValue = kPleaseSelect;

  Future<void> addPost() async {
    final posts = _firestore.collection('posts');
    await posts.add({
      'title': titleValue,
      'textBody': contentValue,
      'nickname': nicknameValue,
      'gender': genderDropdownValue,
      'emotion': emotionDropdownValue,
      'age': ageDropdownValue,
      'position': positionDropdownValue,
      'area': areaDropdownValue,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> updatePost(Post post) async {
    final collection = _firestore.collection('posts');
    await collection.doc(post.id).update({
      'title': titleValue,
      'textBody': contentValue,
      'nickname': nicknameValue,
      'gender': genderDropdownValue,
      'emotion': emotionDropdownValue,
      'age': ageDropdownValue,
      'position': positionDropdownValue,
      'area': areaDropdownValue,
      'updatedAt': Timestamp.now(),
    });
  }
}
