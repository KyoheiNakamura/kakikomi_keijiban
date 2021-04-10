import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';

class AddReplyModel extends ChangeNotifier {
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
    List<String> replyDataList = [
      bodyValue,
      nicknameValue,
      positionDropdownValue,
      genderDropdownValue,
      ageDropdownValue,
      areaDropdownValue,
    ];
    replyDataList = replyDataList.map((replyData) {
      if (replyData == kPleaseSelect || replyData == kDoNotSelect) {
        return '';
      } else {
        return replyData;
      }
    }).toList();
    return replyDataList;
  }

  Future<void> addReplyToPost(Post repliedPost) async {
    List<String> _replyDataList = _convertNoSelectedValueToEmpty();
    final userRef = _firestore.collection('users').doc(repliedPost.uid);
    final postRef = userRef.collection('posts').doc(repliedPost.id);
    final replyRef = postRef.collection('replies').doc();

    await replyRef.set({
      'id': replyRef.id,
      'postId': repliedPost.id,
      'replierId': _auth.currentUser!.uid,
      'body': _replyDataList[0],
      'nickname': _replyDataList[1],
      'position': _replyDataList[2],
      'gender': _replyDataList[3],
      'age': _replyDataList[4],
      'area': _replyDataList[5],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await postRef.update({
      'replyCount': repliedPost.replyCount + 1,
    });
  }

  Future<void> addReplyToReply(Reply repliedReply) async {
    List<String> _replyDataList = _convertNoSelectedValueToEmpty();
    final userRef = _firestore.collection('users').doc(repliedReply.uid);
    final postRef = userRef.collection('posts').doc(repliedReply.postId);
    final replyRef = postRef.collection('replies').doc(repliedReply.id);
    final replyToReplyRef = replyRef.collection('repliesToReply').doc();

    await replyToReplyRef.set({
      'id': replyToReplyRef.id,
      'postId': repliedReply.postId,
      'replyId': repliedReply.id,
      'replierId': _auth.currentUser!.uid,
      'body': _replyDataList[0],
      'nickname': _replyDataList[1],
      'position': _replyDataList[2],
      'gender': _replyDataList[3],
      'age': _replyDataList[4],
      'area': _replyDataList[5],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final postDoc = await postRef.get();

    await postRef.update({
      'replyCount': postDoc['replyCount'] + 1,
    });
  }
}
