import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/post.dart';

class AddPostModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;

  String titleValue = '';
  String contentValue = '';
  String nicknameValue = '';
  String genderDropdownValue = pleaseSelect;
  String emotionDropdownValue = pleaseSelect;
  String ageDropdownValue = pleaseSelect;
  String positionDropdownValue = pleaseSelect;
  String areaDropdownValue = pleaseSelect;

  void getTitleValue(String? inputtedValue) {
    titleValue = inputtedValue!;
  }

  void getContentValue(String? inputtedValue) {
    contentValue = inputtedValue!;
  }

  void getNicknameValue(String? inputtedValue) {
    nicknameValue = inputtedValue!;
  }

  void selectGenderDropdownValue(String? selectedValue) {
    genderDropdownValue = selectedValue!;
  }

  void selectEmotionDropdownValue(String? selectedValue) {
    emotionDropdownValue = selectedValue!;
  }

  void selectAgeDropdownValue(String? selectedValue) {
    ageDropdownValue = selectedValue!;
  }

  void selectPositionDropdownValue(String? selectedValue) {
    positionDropdownValue = selectedValue!;
  }

  void selectAreaDropdownValue(String? selectedValue) {
    areaDropdownValue = selectedValue!;
  }

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
//
//   Future<void> deletePost(Post post) async {
//     final collection = _firestore.collection('posts');
//     await collection.doc(post.id).delete();
//     notifyListeners();
//   }
}
