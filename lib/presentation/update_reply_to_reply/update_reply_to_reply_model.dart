import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/text_process.dart';
import 'package:kakikomi_keijiban/domain/reply_to_reply.dart';

class UpdateReplyToReplyModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  bool isLoading = false;

  String bodyValue = '';
  String nicknameValue = '';
  String positionDropdownValue = kPleaseSelect;
  String genderDropdownValue = kPleaseSelect;
  String ageDropdownValue = kPleaseSelect;
  String areaDropdownValue = kPleaseSelect;

  Future<void> updateReplyToReply(ReplyToReply replyToReply) async {
    startLoading();

    final userRef = _firestore.collection('users').doc(replyToReply.userId);
    final postRef = userRef.collection('posts').doc(replyToReply.postId);
    final replyRef = postRef.collection('replies').doc(replyToReply.replyId);
    final replyToReplyRef =
        replyRef.collection('repliesToReply').doc(replyToReply.id);

    try {
      await replyToReplyRef.update({
        'body': removeUnnecessaryBlankLines(bodyValue),
        'nickname': removeUnnecessaryBlankLines(nicknameValue),
        'position': convertNoSelectedValueToEmpty(positionDropdownValue),
        'gender': convertNoSelectedValueToEmpty(genderDropdownValue),
        'age': convertNoSelectedValueToEmpty(ageDropdownValue),
        'area': convertNoSelectedValueToEmpty(areaDropdownValue),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on Exception catch (e) {
      print('updateReplyToReply処理中のエラーです');
      print(e.toString());
      throw ('エラーが発生しました。\nもう一度お試し下さい。');
    } finally {
      stopLoading();
    }
  }

  Future<void> addReplyToReplyFromDraft(
      ReplyToReply draftedReplyToReply) async {
    startLoading();

    WriteBatch _batch = _firestore.batch();

    final userRef =
        _firestore.collection('users').doc(draftedReplyToReply.userId);
    final postRef = userRef.collection('posts').doc(draftedReplyToReply.postId);
    final replyRef =
        postRef.collection('replies').doc(draftedReplyToReply.replyId);
    final replyToReplyRef = replyRef.collection('repliesToReply').doc();

    _batch.set(replyToReplyRef, {
      'id': replyToReplyRef.id,
      'userId': draftedReplyToReply.userId,
      'postId': draftedReplyToReply.postId,
      'replyId': draftedReplyToReply.id,
      'replierId': draftedReplyToReply.replierId,
      'body': removeUnnecessaryBlankLines(bodyValue),
      'nickname': removeUnnecessaryBlankLines(nicknameValue),
      'position': convertNoSelectedValueToEmpty(positionDropdownValue),
      'gender': convertNoSelectedValueToEmpty(genderDropdownValue),
      'age': convertNoSelectedValueToEmpty(ageDropdownValue),
      'area': convertNoSelectedValueToEmpty(areaDropdownValue),
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
      print('addReplyToReplyFromDraftのバッチ処理中のエラーです');
      print(e.toString());
      throw ('エラーが発生しました。\nもう一度お試し下さい。');
    } finally {
      stopLoading();
    }
  }

  Future<void> updateDraftReplyToReply(ReplyToReply draftedReplyToReply) async {
    startLoading();

    final userRef =
        _firestore.collection('users').doc(draftedReplyToReply.userId);
    final draftedReplyToReplyRef =
        userRef.collection('draftedRepliesToReply').doc(draftedReplyToReply.id);

    try {
      await draftedReplyToReplyRef.update({
        'body': removeUnnecessaryBlankLines(bodyValue),
        'nickname': removeUnnecessaryBlankLines(nicknameValue),
        'position': convertNoSelectedValueToEmpty(positionDropdownValue),
        'gender': convertNoSelectedValueToEmpty(genderDropdownValue),
        'age': convertNoSelectedValueToEmpty(ageDropdownValue),
        'area': convertNoSelectedValueToEmpty(areaDropdownValue),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on Exception catch (e) {
      print('updateDraftReplyToReply処理中のエラーです');
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
