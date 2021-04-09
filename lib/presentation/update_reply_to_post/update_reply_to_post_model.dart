import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';

class UpdateReplyToPostModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  bool isLoading = false;

  void startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void stopLoading() {
    isLoading = false;
    notifyListeners();
  }

  String? validateContentCallback(String? value) {
    if (value == null || value.isEmpty) {
      return '返信の内容を入力してください';
    } else if (value.length > 1000) {
      return '1000字以内でご記入ください';
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

  String bodyValue = '';
  String nicknameValue = '';
  String positionDropdownValue = kPleaseSelect;
  String genderDropdownValue = kPleaseSelect;
  String ageDropdownValue = kPleaseSelect;
  String areaDropdownValue = kPleaseSelect;

  List<String> _convertNoSelectedValueToEmpty() {
    List<String> postDataList = [
      bodyValue,
      nicknameValue,
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

  Future<void> updateReply(Reply existingReply) async {
    List<String> _postDataList = _convertNoSelectedValueToEmpty();
    final userRef = _firestore.collection('users').doc(existingReply.userId);
    final post = userRef.collection('posts').doc(existingReply.postId);
    final reply = post.collection('replies').doc(existingReply.id);
    await reply.update({
      'body': _postDataList[0],
      'nickname': _postDataList[1],
      'position': _postDataList[2],
      'gender': _postDataList[3],
      'age': _postDataList[4],
      'area': _postDataList[5],
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
