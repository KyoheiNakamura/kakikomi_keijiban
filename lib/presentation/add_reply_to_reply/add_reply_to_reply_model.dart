import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/text_process.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';

class AddReplyToReplyModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  bool isLoading = false;

  String bodyValue = '';
  String nicknameValue = '';
  String positionDropdownValue = kPleaseSelect;
  String genderDropdownValue = kPleaseSelect;
  String ageDropdownValue = kPleaseSelect;
  String areaDropdownValue = kPleaseSelect;

  Future<void> addReplyToReply(Reply repliedReply) async {
    startLoading();

    WriteBatch _batch = _firestore.batch();

    final userRef = _firestore.collection('users').doc(repliedReply.userId);
    final postRef = userRef.collection('posts').doc(repliedReply.postId);
    final replyRef = postRef.collection('replies').doc(repliedReply.id);
    final replyToReplyRef = replyRef.collection('repliesToReply').doc();
    List<String> _replyDataList = _convertNoSelectedValueToEmpty();

    _batch.set(replyToReplyRef, {
      'id': replyToReplyRef.id,
      'userId': repliedReply.userId,
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

    _batch.update(postRef, {
      'replyCount': postDoc['replyCount'] + 1,
    });

    try {
      await _batch.commit();
    } on Exception catch (e) {
      print('addReplyToReplyのバッチ処理中のエラーです');
      print(e.toString());
      throw ('エラーが発生しました。\nもう一度お試し下さい。');
    } finally {
      stopLoading();
    }
  }

  Future<void> addDraftedReplyToReply(Reply repliedReply) async {
    startLoading();

    final userRef = _firestore.collection('users').doc(repliedReply.userId);
    final draftedReplyToReplyRef =
        userRef.collection('draftedRepliesToReply').doc();
    List<String> _replyDataList = _convertNoSelectedValueToEmpty();

    try {
      await draftedReplyToReplyRef.set({
        'id': draftedReplyToReplyRef.id,
        'userId': repliedReply.userId,
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
    } on Exception catch (e) {
      print('addDraftedReplyToReply処理中のエラーです');
      print(e.toString());
      throw ('エラーが発生しました。\nもう一度お試し下さい。');
    } finally {
      stopLoading();
    }
  }

  List<String> _convertNoSelectedValueToEmpty() {
    List<String> replyDataList = [
      bodyValue = removeUnnecessaryBlankLines(bodyValue),
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
}
