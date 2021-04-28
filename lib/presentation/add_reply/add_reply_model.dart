import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/text_process.dart';
import 'package:kakikomi_keijiban/domain/post.dart';

class AddReplyModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  bool isLoading = false;

  String bodyValue = '';
  String nicknameValue = '';
  String positionDropdownValue = kPleaseSelect;
  String genderDropdownValue = kPleaseSelect;
  String ageDropdownValue = kPleaseSelect;
  String areaDropdownValue = kPleaseSelect;

  Future<void> addReplyToPost(Post repliedPost) async {
    startLoading();

    WriteBatch _batch = _firestore.batch();

    List<String> _replyDataList = _convertNoSelectedValueToEmpty();
    final userRef = _firestore.collection('users').doc(repliedPost.userId);
    final postRef = userRef.collection('posts').doc(repliedPost.id);
    final replyRef = postRef.collection('replies').doc();

    _batch.set(replyRef, {
      'id': replyRef.id,
      'userId': repliedPost.userId,
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

    _batch.update(postRef, {
      'replyCount': repliedPost.replyCount + 1,
      'isReplyExisting': true,
    });

    try {
      await _batch.commit();
    } on Exception catch (e) {
      print('addReplyのバッチ処理中のエラーです');
      print(e.toString());
      throw ('エラーが発生しました。\nもう一度お試し下さい。');
    } finally {
      stopLoading();
    }
  }

  Future<void> addDraftedReply(Post repliedPost) async {
    startLoading();

    final userRef = _firestore.collection('users').doc(repliedPost.userId);
    final draftedReplyRef = userRef.collection('draftedReplies').doc();
    List<String> _replyDataList = _convertNoSelectedValueToEmpty();

    try {
      await draftedReplyRef.set({
        'id': draftedReplyRef.id,
        'userId': repliedPost.userId,
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
    } on Exception catch (e) {
      print('addDraftedReply処理中のエラーです');
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
