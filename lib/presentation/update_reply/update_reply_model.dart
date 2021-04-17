import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';

class UpdateReplyModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  bool isLoading = false;

  String bodyValue = '';
  String nicknameValue = '';
  String positionDropdownValue = kPleaseSelect;
  String genderDropdownValue = kPleaseSelect;
  String ageDropdownValue = kPleaseSelect;
  String areaDropdownValue = kPleaseSelect;

  Future<void> updateReply(Reply existingReply) async {
    startLoading();

    List<String> _postDataList = _convertNoSelectedValueToEmpty();
    final userRef = _firestore.collection('users').doc(existingReply.userId);
    final postRef = userRef.collection('posts').doc(existingReply.postId);
    final replyRef = postRef.collection('replies').doc(existingReply.id);

    try {
      await replyRef.update({
        'body': _postDataList[0],
        'nickname': _postDataList[1],
        'position': _postDataList[2],
        'gender': _postDataList[3],
        'age': _postDataList[4],
        'area': _postDataList[5],
        'updatedAt': FieldValue.serverTimestamp(),
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

    WriteBatch _batch = _firestore.batch();

    List<String> _replyDataList = _convertNoSelectedValueToEmpty();
    final userRef = _firestore.collection('users').doc(draftedReply.userId);
    final postRef = userRef.collection('posts').doc(draftedReply.postId);
    final replyRef = postRef.collection('replies').doc();

    _batch.set(replyRef, {
      'id': replyRef.id,
      'userId': draftedReply.userId,
      'postId': draftedReply.postId,
      'replierId': draftedReply.replierId,
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

  Future<void> updateDraftReply(Reply draftedReply) async {
    startLoading();

    final userRef = _firestore.collection('users').doc(draftedReply.userId);
    final draftedReplyRef =
        userRef.collection('draftedReplies').doc(draftedReply.id);
    List<String> _replyDataList = _convertNoSelectedValueToEmpty();

    try {
      await draftedReplyRef.update({
        'body': _replyDataList[0],
        'nickname': _replyDataList[1],
        'position': _replyDataList[2],
        'gender': _replyDataList[3],
        'age': _replyDataList[4],
        'area': _replyDataList[5],
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on Exception catch (e) {
      print('updateDraftReply処理中のエラーです');
      print(e.toString());
      throw ('エラーが発生しました。\nもう一度お試し下さい。');
    } finally {
      stopLoading();
    }
  }

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
