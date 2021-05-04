import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';
import 'package:kakikomi_keijiban/common/text_process.dart';
import 'package:kakikomi_keijiban/domain/post.dart';

class UpdatePostModel extends ChangeNotifier {
  final currentUser = auth.currentUser;
  bool isLoading = false;
  bool isCategoriesValid = true;

  String titleValue = '';
  String bodyValue = '';
  String nicknameValue = '';
  String emotionDropdownValue = kPleaseSelect;
  String selectedCategory = '';
  List<String> selectedCategories = [];
  String positionDropdownValue = kPleaseSelect;
  String genderDropdownValue = kPleaseSelect;
  String ageDropdownValue = kPleaseSelect;
  String areaDropdownValue = kPleaseSelect;

  Future<void> updatePost(Post post) async {
    startLoading();

    final userRef = firestore.collection('users').doc(post.userId);
    final postRef = userRef.collection('posts').doc(post.id);

    try {
      await postRef.update({
        'title': removeUnnecessaryBlankLines(titleValue),
        'body': removeUnnecessaryBlankLines(bodyValue),
        'nickname': removeUnnecessaryBlankLines(nicknameValue),
        'emotion': convertNoSelectedValueToEmpty(emotionDropdownValue),
        'position': convertNoSelectedValueToEmpty(positionDropdownValue),
        'gender': convertNoSelectedValueToEmpty(genderDropdownValue),
        'age': convertNoSelectedValueToEmpty(ageDropdownValue),
        'area': convertNoSelectedValueToEmpty(areaDropdownValue),
        'categories': selectedCategories,
        'updatedAt': serverTimestamp(),
      });
    } on Exception catch (e) {
      print('updatePost処理中のエラーです');
      print(e.toString());
      throw ('エラーが発生しました。\nもう一度お試し下さい。');
    } finally {
      stopLoading();
    }
  }

  Future<void> addPostFromDraft(Post draftedPost) async {
    startLoading();

    WriteBatch _batch = firestore.batch();

    final userRef = firestore.collection('users').doc(draftedPost.userId);
    final postRef = userRef.collection('posts').doc();

    _batch.set(postRef, {
      'id': postRef.id,
      'userId': draftedPost.userId,
      'title': removeUnnecessaryBlankLines(titleValue),
      'body': removeUnnecessaryBlankLines(bodyValue),
      'nickname': removeUnnecessaryBlankLines(nicknameValue),
      'emotion': convertNoSelectedValueToEmpty(emotionDropdownValue),
      'position': convertNoSelectedValueToEmpty(positionDropdownValue),
      'gender': convertNoSelectedValueToEmpty(genderDropdownValue),
      'age': convertNoSelectedValueToEmpty(ageDropdownValue),
      'area': convertNoSelectedValueToEmpty(areaDropdownValue),
      'categories': selectedCategories,
      'replyCount': 0,
      'empathyCount': 0,
      'isReplyExisting': false,
      'createdAt': serverTimestamp(),
      'updatedAt': serverTimestamp(),
    });

    final userDoc = await userRef.get();

    _batch.update(userRef, {
      'postCount': userDoc['postCount'] + 1,
    });

    final draftedPostRef =
        userRef.collection('draftedPosts').doc(draftedPost.id);

    _batch.delete(draftedPostRef);

    try {
      await _batch.commit();
    } on Exception catch (e) {
      print('addPostFromDraftのバッチ処理中のエラーです');
      print(e.toString());
      throw ('エラーが発生しました。\nもう一度お試し下さい。');
    } finally {
      stopLoading();
    }
  }

  Future<void> updateDraftPost(Post draftedPost) async {
    startLoading();

    final userRef = firestore.collection('users').doc(draftedPost.userId);
    final draftedPostRef =
        userRef.collection('draftedPosts').doc(draftedPost.id);

    try {
      await draftedPostRef.update({
        'title': removeUnnecessaryBlankLines(titleValue),
        'body': removeUnnecessaryBlankLines(bodyValue),
        'nickname': removeUnnecessaryBlankLines(nicknameValue),
        'emotion': convertNoSelectedValueToEmpty(emotionDropdownValue),
        'position': convertNoSelectedValueToEmpty(positionDropdownValue),
        'gender': convertNoSelectedValueToEmpty(genderDropdownValue),
        'age': convertNoSelectedValueToEmpty(ageDropdownValue),
        'area': convertNoSelectedValueToEmpty(areaDropdownValue),
        'categories': selectedCategories,
        'replyCount': 0,
        'updatedAt': serverTimestamp(),
      });
    } on Exception catch (e) {
      print('updateDraftPost処理中のエラーです');
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

  String? validateTitleCallback(String? value) {
    if (value == null || value.isEmpty) {
      return 'タイトルを入力してください';
    } else if (value.length > 50) {
      return '50字以内でご記入ください';
    }
    return null;
  }

  String? validateContentCallback(String? value) {
    if (value == null || value.isEmpty) {
      return '投稿の内容を入力してください';
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

  String? validateEmotionCallback(String? value) {
    if (value == kPleaseSelect) {
      return 'あなたの気持ちを選択してください';
    }
    return null;
  }

  String? validatePositionCallback(String? value) {
    if (value == kPleaseSelect) {
      return 'あなたの立場を選択してください';
    }
    return null;
  }

  bool validateSelectedCategories() {
    if (selectedCategories.isEmpty || selectedCategories.length > 5) {
      isCategoriesValid = false;
      notifyListeners();
      return false;
    } else {
      return true;
    }
  }

  void reload() {
    notifyListeners();
  }

  void startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void stopLoading() {
    isLoading = false;
    notifyListeners();
  }
}
