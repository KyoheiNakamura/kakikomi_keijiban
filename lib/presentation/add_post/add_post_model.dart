import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/domain/post.dart';

class AddPostModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final currentUser = FirebaseAuth.instance.currentUser;
  final uid = FirebaseAuth.instance.currentUser!.uid;
  bool isLoading = false;

  void startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void stopLoading() {
    isLoading = false;
    notifyListeners();
  }

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
  bool isCategoriesValid = true;

  bool validateSelectedCategories() {
    if (selectedCategories.isEmpty) {
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
      // 'uid': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updatePost(Post post) async {
    final userRef = _firestore.collection('users').doc(uid);
    final postRef = userRef.collection('posts').doc(post.id);
    List<String> _postDataList = _convertNoSelectedValueToEmpty();

    await postRef.update({
      'title': _postDataList[0],
      'body': _postDataList[1],
      'nickname': _postDataList[2],
      'emotion': _postDataList[3],
      'position': _postDataList[4],
      'gender': _postDataList[5],
      'age': _postDataList[6],
      'area': _postDataList[7],
      'categories': selectedCategories,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
