import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/domain/post.dart';

class AddPostModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;

  String titleValue = '';
  String contentValue = '';
  String nicknameValue = '';
  String emotionDropdownValue = kPleaseSelect;
  String positionDropdownValue = kPleaseSelect;
  String genderDropdownValue = kPleaseSelect;
  String ageDropdownValue = kPleaseSelect;
  String areaDropdownValue = kPleaseSelect;
  String uid = FirebaseAuth.instance.currentUser != null
      ? FirebaseAuth.instance.currentUser!.uid
      : '';

  List<String> _convertNoSelectedValueToEmpty() {
    List<String> postDataList = [
      titleValue,
      contentValue,
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
    final posts = _firestore.collection('posts');
    List<String> _postDataList = _convertNoSelectedValueToEmpty();

    await posts.add({
      'title': _postDataList[0],
      'textBody': _postDataList[1],
      'nickname': _postDataList[2],
      'emotion': _postDataList[3],
      'position': _postDataList[4],
      'gender': _postDataList[5],
      'age': _postDataList[6],
      'area': _postDataList[7],
      'uid': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updatePost(Post post) async {
    final collection = _firestore.collection('posts');
    List<String> _postDataList = _convertNoSelectedValueToEmpty();

    await collection.doc(post.id).update({
      'title': _postDataList[0],
      'textBody': _postDataList[1],
      'nickname': _postDataList[2],
      'emotion': _postDataList[3],
      'position': _postDataList[4],
      'gender': _postDataList[5],
      'age': _postDataList[6],
      'area': _postDataList[7],
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
