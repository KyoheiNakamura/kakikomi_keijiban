import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/app_model.dart';
import 'package:kakikomi_keijiban/common/components/common_loading_spinner.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';
import 'package:kakikomi_keijiban/common/text_process.dart';
import 'package:kakikomi_keijiban/entity/post.dart';
import 'package:kakikomi_keijiban/repository/post_repository.dart';

class AddPostModel extends ChangeNotifier {
  bool isLoading = false;
  bool isCategoriesValid = true;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FocusNode focusNodeContent = FocusNode();

  TextEditingController titleController = TextEditingController();
  TextEditingController bodyController = TextEditingController();
  TextEditingController nicknameController = TextEditingController(
    text: AppModel.user != null ? AppModel.user!.nickname : '匿名',
  );

  String emotionDropdownValue = kPleaseSelect;
  String selectedCategory = '';
  List<String> selectedCategories = [];
  String positionDropdownValue = kPleaseSelect;
  String genderDropdownValue = kPleaseSelect;
  String ageDropdownValue = kPleaseSelect;
  String areaDropdownValue = kPleaseSelect;

  Future<void> addPost(BuildContext context) async {
    // ignore: unawaited_futures
    CommonLoadingDialog.instance.showDialog(context);

    final uid = auth.currentUser!.uid;
    final _batch = firestore.batch();

    final userRef = firestore.collection('users').doc(uid);
    // final postRef = userRef.collection('posts').doc();

    final newPost = Post(
      title: removeUnnecessaryBlankLines(titleController.text),
      body: removeUnnecessaryBlankLines(bodyController.text),
      nickname: removeUnnecessaryBlankLines(nicknameController.text),
      emotion: convertNoSelectedValueToEmpty(emotionDropdownValue),
      position: convertNoSelectedValueToEmpty(positionDropdownValue),
      gender: convertNoSelectedValueToEmpty(genderDropdownValue),
      age: convertNoSelectedValueToEmpty(ageDropdownValue),
      area: convertNoSelectedValueToEmpty(areaDropdownValue),
      categories: selectedCategories,
      replyCountFieldValue: FieldValue.increment(0),
      empathyCountFieldValue: FieldValue.increment(0),
      isReplyExisting: false,
    );

    PostRepository.instance.createPostWithBatch(
      userId: uid,
      post: newPost,
      batch: _batch,
    );

    // _batch.set(postRef, {
    //   'id': postRef.id,
    //   'userId': uid,
    //   'title': removeUnnecessaryBlankLines(titleValue),
    //   'body': removeUnnecessaryBlankLines(bodyValue),
    //   'nickname': removeUnnecessaryBlankLines(nicknameValue),
    //   'emotion': convertNoSelectedValueToEmpty(emotionDropdownValue),
    //   'position': convertNoSelectedValueToEmpty(positionDropdownValue),
    //   'gender': convertNoSelectedValueToEmpty(genderDropdownValue),
    //   'age': convertNoSelectedValueToEmpty(ageDropdownValue),
    //   'area': convertNoSelectedValueToEmpty(areaDropdownValue),
    //   'categories': selectedCategories,
    //   'replyCount': 0,
    //   'empathyCount': 0,
    //   'isReplyExisting': false,
    //   'createdAt': serverTimestamp(),
    //   'updatedAt': serverTimestamp(),
    // });

    final userDoc = await userRef.get();

    _batch.update(userRef, <String, dynamic>{
      'postCount': (userDoc['postCount'] as int) + 1,
    });

    try {
      await _batch.commit();
    } on Exception catch (e) {
      print('addPostのバッチ処理中のエラーです');
      print(e.toString());
      throw Exception('エラーが発生しました。\nもう一度お試し下さい。');
    } finally {
      CommonLoadingDialog.instance.closeDialog();
      // stopLoading();
    }
  }

  Future<void> addDraftedPost() async {
    startLoading();

    final uid = auth.currentUser!.uid;
    final userRef = firestore.collection('users').doc(uid);
    final draftedPostRef = userRef.collection('draftedPosts').doc();

    try {
      await draftedPostRef.set(<String, dynamic>{
        'id': draftedPostRef.id,
        'userId': uid,
        'title': removeUnnecessaryBlankLines(titleController.text),
        'body': removeUnnecessaryBlankLines(bodyController.text),
        'nickname': removeUnnecessaryBlankLines(nicknameController.text),
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
    } on Exception catch (e) {
      print('addDraftedPost処理中のエラーです');
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
      isCategoriesValid = true;
      notifyListeners();
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

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    nicknameController.dispose();
    super.dispose();
  }
}
