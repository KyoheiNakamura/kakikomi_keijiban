import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/app_model.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';
import 'package:kakikomi_keijiban/common/text_process.dart';
import 'package:kakikomi_keijiban/entity/reply.dart';

class AddReplyToReplyModel extends ChangeNotifier {
  bool isLoading = false;

  TextEditingController bodyController = TextEditingController();
  TextEditingController nicknameController = TextEditingController(
    text: AppModel.user != null ? AppModel.user!.nickname : '匿名',
  );

  String positionDropdownValue = kPleaseSelect;
  String genderDropdownValue = kPleaseSelect;
  String ageDropdownValue = kPleaseSelect;
  String areaDropdownValue = kPleaseSelect;

  Future<void> addReplyToReply(Reply repliedReply) async {
    startLoading();

    final _batch = firestore.batch();

    final userRef = firestore.collection('users').doc(repliedReply.userId);
    final postRef = userRef.collection('posts').doc(repliedReply.postId);
    final replyRef = postRef.collection('replies').doc(repliedReply.id);
    final replyToReplyRef = replyRef.collection('repliesToReply').doc();

    _batch.set(replyToReplyRef, <String, dynamic>{
      'id': replyToReplyRef.id,
      'userId': repliedReply.userId,
      'postId': repliedReply.postId,
      'replyId': repliedReply.id,
      'replierId': auth.currentUser!.uid,
      'body': removeUnnecessaryBlankLines(bodyController.text),
      'nickname': removeUnnecessaryBlankLines(nicknameController.text),
      'position': convertNoSelectedValueToEmpty(positionDropdownValue),
      'gender': convertNoSelectedValueToEmpty(genderDropdownValue),
      'age': convertNoSelectedValueToEmpty(ageDropdownValue),
      'area': convertNoSelectedValueToEmpty(areaDropdownValue),
      'empathyCount': 0,
      'createdAt': serverTimestamp(),
      'updatedAt': serverTimestamp(),
    });

    final postDoc = await postRef.get();

    _batch.update(postRef, <String, dynamic>{
      'replyCount': (postDoc['replyCount'] as int) + 1,
    });

    try {
      await _batch.commit();
    } on Exception catch (e) {
      print('addReplyToReplyのバッチ処理中のエラーです');
      print(e.toString());
      throw 'エラーが発生しました。\nもう一度お試し下さい。';
    } finally {
      stopLoading();
    }
  }

  Future<void> addDraftedReplyToReply(Reply repliedReply) async {
    startLoading();

    final uid = auth.currentUser!.uid;
    final userRef = firestore.collection('users').doc(uid);
    final draftedReplyToReplyRef =
        userRef.collection('draftedRepliesToReply').doc();

    try {
      await draftedReplyToReplyRef.set(<String, dynamic>{
        'id': draftedReplyToReplyRef.id,
        'userId': repliedReply.userId,
        'postId': repliedReply.postId,
        'replyId': repliedReply.id,
        'replierId': uid,
        'body': removeUnnecessaryBlankLines(bodyController.text),
        'nickname': removeUnnecessaryBlankLines(nicknameController.text),
        'position': convertNoSelectedValueToEmpty(positionDropdownValue),
        'gender': convertNoSelectedValueToEmpty(genderDropdownValue),
        'age': convertNoSelectedValueToEmpty(ageDropdownValue),
        'area': convertNoSelectedValueToEmpty(areaDropdownValue),
        'empathyCount': 0,
        'createdAt': serverTimestamp(),
        'updatedAt': serverTimestamp(),
      });
    } on Exception catch (e) {
      print('addDraftedReplyToReply処理中のエラーです');
      print(e.toString());
      throw 'エラーが発生しました。\nもう一度お試し下さい。';
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
