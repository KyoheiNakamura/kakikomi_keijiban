import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';
import 'package:kakikomi_keijiban/common/text_process.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';

class UpdateReplyModel extends ChangeNotifier {
  bool isLoading = false;

  String bodyValue = '';
  String nicknameValue = '';
  String positionDropdownValue = kPleaseSelect;
  String genderDropdownValue = kPleaseSelect;
  String ageDropdownValue = kPleaseSelect;
  String areaDropdownValue = kPleaseSelect;

  Future<void> updateReply(Reply existingReply) async {
    startLoading();

    final userRef = firestore.collection('users').doc(existingReply.userId);
    final postRef = userRef.collection('posts').doc(existingReply.postId);
    final replyRef = postRef.collection('replies').doc(existingReply.id);

    try {
      await replyRef.update({
        'body': removeUnnecessaryBlankLines(bodyValue),
        'nickname': removeUnnecessaryBlankLines(nicknameValue),
        'position': convertNoSelectedValueToEmpty(positionDropdownValue),
        'gender': convertNoSelectedValueToEmpty(genderDropdownValue),
        'age': convertNoSelectedValueToEmpty(ageDropdownValue),
        'area': convertNoSelectedValueToEmpty(areaDropdownValue),
        'updatedAt': serverTimestamp(),
      });
    } on Exception catch (e) {
      print('updateReply処理中のエラーです');
      print(e.toString());
      throw ('エラーが発生しました。\nもう一度お試し下さい。');
    } finally {
      stopLoading();
    }
  }

  Future<void> addReplyToPostFromDraft(Reply draftedReply) async {
    startLoading();

    WriteBatch _batch = firestore.batch();

    final userRef = firestore.collection('users').doc(draftedReply.userId);
    final postRef = userRef.collection('posts').doc(draftedReply.postId);
    final replyRef = postRef.collection('replies').doc();

    _batch.set(replyRef, {
      'id': replyRef.id,
      'userId': draftedReply.userId,
      'postId': draftedReply.postId,
      'replierId': draftedReply.replierId,
      'body': removeUnnecessaryBlankLines(bodyValue),
      'nickname': removeUnnecessaryBlankLines(nicknameValue),
      'position': convertNoSelectedValueToEmpty(positionDropdownValue),
      'gender': convertNoSelectedValueToEmpty(genderDropdownValue),
      'age': convertNoSelectedValueToEmpty(ageDropdownValue),
      'area': convertNoSelectedValueToEmpty(areaDropdownValue),
      'empathyCount': 0,
      'createdAt': serverTimestamp(),
      'updatedAt': serverTimestamp(),
    });

    final postDoc = await postRef.get();

    _batch.update(postRef, {
      'replyCount': postDoc['replyCount'] + 1,
      'isReplyExisting': true,
    });

    final draftedReplyRef =
        userRef.collection('draftedReplies').doc(draftedReply.id);

    _batch.delete(draftedReplyRef);

    try {
      await _batch.commit();
    } on Exception catch (e) {
      print('addReplyToPostFromDraftのバッチ処理中のエラーです');
      print(e.toString());
      throw ('エラーが発生しました。\nもう一度お試し下さい。');
    } finally {
      stopLoading();
    }
  }

  Future<void> updateDraftedReply(Reply draftedReply) async {
    startLoading();

    final userRef = firestore.collection('users').doc(draftedReply.userId);
    final draftedReplyRef =
        userRef.collection('draftedReplies').doc(draftedReply.id);

    try {
      await draftedReplyRef.update({
        'body': removeUnnecessaryBlankLines(bodyValue),
        'nickname': removeUnnecessaryBlankLines(nicknameValue),
        'position': convertNoSelectedValueToEmpty(positionDropdownValue),
        'gender': convertNoSelectedValueToEmpty(genderDropdownValue),
        'age': convertNoSelectedValueToEmpty(ageDropdownValue),
        'area': convertNoSelectedValueToEmpty(areaDropdownValue),
        'updatedAt': serverTimestamp(),
      });
    } on Exception catch (e) {
      print('updateDraftReply処理中のエラーです');
      print(e.toString());
      throw ('エラーが発生しました。\nもう一度お試し下さい。');
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
}
