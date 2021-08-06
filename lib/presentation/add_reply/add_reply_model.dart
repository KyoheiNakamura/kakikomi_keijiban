import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/app_model.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';
import 'package:kakikomi_keijiban/common/text_process.dart';
import 'package:kakikomi_keijiban/entity/post.dart';

class AddReplyModel extends ChangeNotifier {
  bool isLoading = false;

  TextEditingController bodyController = TextEditingController();
  TextEditingController nicknameController = TextEditingController(
    text: AppModel.user != null ? AppModel.user!.nickname : '匿名',
  );

  String positionDropdownValue = kPleaseSelect;
  String genderDropdownValue = kPleaseSelect;
  String ageDropdownValue = kPleaseSelect;
  String areaDropdownValue = kPleaseSelect;

  Future<void> addReplyToPost(Post repliedPost) async {
    startLoading();

    final _batch = firestore.batch();

    final userRef = firestore.collection('users').doc(repliedPost.userId);
    final postRef = userRef.collection('posts').doc(repliedPost.id);
    final replyRef = postRef.collection('replies').doc();

    _batch
      ..set(replyRef, {
        'id': replyRef.id,
        'userId': repliedPost.userId,
        'postId': repliedPost.id,
        'replierId': auth.currentUser!.uid,
        'body': removeUnnecessaryBlankLines(bodyController.text),
        'nickname': removeUnnecessaryBlankLines(nicknameController.text),
        'position': convertNoSelectedValueToEmpty(positionDropdownValue),
        'gender': convertNoSelectedValueToEmpty(genderDropdownValue),
        'age': convertNoSelectedValueToEmpty(ageDropdownValue),
        'area': convertNoSelectedValueToEmpty(areaDropdownValue),
        'empathyCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      })
      ..update(postRef, <String, dynamic>{
        'replyCount': repliedPost.replyCount! + 1,
        'isReplyExisting': true,
      });

    try {
      await _batch.commit();
    } on Exception catch (e) {
      print('addReplyのバッチ処理中のエラーです');
      print(e.toString());
      throw Exception('エラーが発生しました。\nもう一度お試し下さい。');
    } finally {
      stopLoading();
    }
  }

  Future<void> addDraftedReply(Post repliedPost) async {
    startLoading();

    final uid = auth.currentUser!.uid;
    final userRef = firestore.collection('users').doc(uid);
    final draftedReplyRef = userRef.collection('draftedReplies').doc();

    try {
      await draftedReplyRef.set(<String, dynamic>{
        'id': draftedReplyRef.id,
        'userId': repliedPost.userId,
        'postId': repliedPost.id,
        'replierId': uid,
        'body': removeUnnecessaryBlankLines(bodyController.text),
        'nickname': removeUnnecessaryBlankLines(nicknameController.text),
        'position': convertNoSelectedValueToEmpty(positionDropdownValue),
        'gender': convertNoSelectedValueToEmpty(genderDropdownValue),
        'age': convertNoSelectedValueToEmpty(ageDropdownValue),
        'area': convertNoSelectedValueToEmpty(areaDropdownValue),
        'empathyCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on Exception catch (e) {
      print('addDraftedReply処理中のエラーです');
      print(e.toString());
      throw Exception('エラーが発生しました。\nもう一度お試し下さい。');
    } finally {
      stopLoading();
    }
  }

  String convertNoSelectedValueToEmpty(String selectedValue) {
    if (selectedValue == kPleaseSelect || selectedValue == kDoNotSelect) {
      return '';
    } else {
      return selectedValue;
    }
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

  @override
  void dispose() {
    bodyController.dispose();
    nicknameController.dispose();
    super.dispose();
  }
}
