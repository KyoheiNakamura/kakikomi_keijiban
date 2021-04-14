import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';

class AddReplyToReplyModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  bool isLoading = false;
  bool isDraft = false;

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

  Future<void> addReplyToReply(Reply repliedReply) async {
    startLoading();

    WriteBatch _batch = _firestore.batch();

    List<String> _replyDataList = _convertNoSelectedValueToEmpty();
    final userRef = _firestore.collection('users').doc(repliedReply.uid);
    final postRef = userRef.collection('posts').doc(repliedReply.postId);
    final replyRef = postRef.collection('replies').doc(repliedReply.id);
    final replyToReplyRef = replyRef.collection('repliesToReply').doc();

    _batch.set(replyToReplyRef, {
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
      'isDraft': isDraft,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final postDoc = await postRef.get();

    _batch.update(postRef, {
      'replyCount': postDoc['replyCount'] + 1,
    });

    try {
      await _batch.commit();
    } catch (e) {
      print('addReplyToReplyのバッチ処理中のエラーです');
      print(e.toString());
      throw ('エラーが発生しました');
    }

    stopLoading();
  }
}
