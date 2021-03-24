import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/post.dart';

class AddPostModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;

  String _titleValue = '';
  String get titleValue => _titleValue;

  String _contentValue = '';
  String get contentValue => _contentValue;

  String _nicknameValue = '';
  String get nicknameValue => _nicknameValue;

  String _genderDropdownValue = '選択してください';
  String get genderDropdownValue => _genderDropdownValue;

  String _emotionDropdownValue = '選択してください';
  String get emotionDropdownValue => _emotionDropdownValue;

  String _ageDropdownValue = '選択してください';
  String get ageDropdownValue => _ageDropdownValue;

  String _positionDropdownValue = '選択してください';
  String get positionDropdownValue => _positionDropdownValue;

  String _areaDropdownValue = '選択してください';
  String get areaDropdownValue => _areaDropdownValue;

  void getTitleValue(String? inputtedValue) {
    _titleValue = inputtedValue!;
    notifyListeners();
  }

  void getContentValue(String? inputtedValue) {
    _contentValue = inputtedValue!;
    notifyListeners();
  }

  void getNicknameValue(String? inputtedValue) {
    _nicknameValue = inputtedValue!;
    notifyListeners();
  }

  void selectGenderDropdownValue(String? selectedValue) {
    _genderDropdownValue = selectedValue!;
    notifyListeners();
  }

  void selectEmotionDropdownValue(String? selectedValue) {
    _emotionDropdownValue = selectedValue!;
    notifyListeners();
  }

  void selectAgeDropdownValue(String? selectedValue) {
    _ageDropdownValue = selectedValue!;
    notifyListeners();
  }

  void selectPositionDropdownValue(String? selectedValue) {
    _positionDropdownValue = selectedValue!;
    notifyListeners();
  }

  void selectAreaDropdownValue(String? selectedValue) {
    _areaDropdownValue = selectedValue!;
    notifyListeners();
  }

  Future<void> addPost() async {
    final posts = _firestore.collection('posts');
    await posts.add({
      'title': titleValue,
      'textBody': contentValue,
      'nickname': nicknameValue,
      'gender': _genderDropdownValue,
      'emotion': _emotionDropdownValue,
      'age': _ageDropdownValue,
      'position': _positionDropdownValue,
      'area': _areaDropdownValue,
      'createdAt': Timestamp.now(),
    });
  }

//   Future<void> updatePost(Post post) async {
//     final collection = _firestore.collection('posts');
//     await collection.doc(post.id).update({'title': post.title});
//     notifyListeners();
//   }
//
//   Future<void> deletePost(Post post) async {
//     final collection = _firestore.collection('posts');
//     await collection.doc(post.id).delete();
//     notifyListeners();
//   }
}
