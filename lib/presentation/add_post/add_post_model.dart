import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/constants.dart';

class AddPostModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final currentUser = FirebaseAuth.instance.currentUser;
  final uid = FirebaseAuth.instance.currentUser!.uid;
  bool isLoading = false;
  bool isCategoriesValid = true;
  // postドメインに持たせる
  bool isDraft = false;

  String titleValue = '';
  String bodyValue = '';
  String nicknameValue = '';
  String emotionDropdownValue = kPleaseSelect;
  String selectedCategory = '';
  List<String> selectedCategories = [];
  String positionDropdownValue = kPleaseSelect;
  String genderDropdownValue = kPleaseSelect;
  String ageDropdownValue = kPleaseSelect;
  String areaDropdownValue = kPleaseSelect;

  Future<void> addPost() async {
    final userRef = _firestore.collection('users').doc(uid);
    final postRef = userRef.collection('posts').doc();
    List<String> _postDataList = _convertNoSelectedValueToEmpty();

    await postRef.set({
      'id': postRef.id,
      'title': _postDataList[0],
      'body': _postDataList[1],
      'nickname': _postDataList[2],
      'emotion': _postDataList[3],
      'position': _postDataList[4],
      'gender': _postDataList[5],
      'age': _postDataList[6],
      'area': _postDataList[7],
      'categories': selectedCategories,
      'userId': uid,
      'replyCount': 0,
      // Todo 下書き機能を実装しよう
      'isDraft': isDraft,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  List<String> _convertNoSelectedValueToEmpty() {
    List<String> postDataList = [
      titleValue,
      bodyValue,
      nicknameValue,
      emotionDropdownValue,
      positionDropdownValue,
      genderDropdownValue,
      ageDropdownValue,
      areaDropdownValue,
    ];
    postDataList = postDataList.map((postData) {
      if (postData == kPleaseSelect || postData == kDoNotSelect) {
        return '';
      } else {
        return postData;
      }
    }).toList();
    return postDataList;
  }

  String? validateTitleCallback(String? value) {
    if (value == null || value.isEmpty) {
      return 'タイトルを入力してください';
    } else if (value.length > 50) {
      return '50字以内でご記入ください';
    }
    return null;
  }

  String? validateContentCallback(String? value) {
    if (value == null || value.isEmpty) {
      return '投稿の内容を入力してください';
    } else if (value.length > 1500) {
      return '1500字以内でご記入ください';
    }
    return null;
  }

  String? validateNicknameCallback(String? value) {
    if (value == null || value.isEmpty) {
      return 'ニックネームを入力してください';
    } else if (value.length > 10) {
      return '10字以内でご記入ください';
    }
    return null;
  }

  String? validateEmotionCallback(String? value) {
    if (value == kPleaseSelect) {
      return 'あなたの気持ちを選択してください';
    }
    return null;
  }

  String? validatePositionCallback(String? value) {
    if (value == kPleaseSelect) {
      return 'あなたの立場を選択してください';
    }
    return null;
  }

  bool validateSelectedCategories() {
    if (selectedCategories.isEmpty || selectedCategories.length > 5) {
      isCategoriesValid = false;
      notifyListeners();
      return false;
    } else {
      return true;
    }
  }

  void reload() {
    notifyListeners();
  }

  void startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void stopLoading() {
    isLoading = false;
    notifyListeners();
  }
}
