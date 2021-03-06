import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';
import 'package:kakikomi_keijiban/common/text_process.dart';
import 'package:kakikomi_keijiban/entity/post.dart';
import 'package:kakikomi_keijiban/repository/post_repository.dart';

class UpdatePostModel extends ChangeNotifier {
  UpdatePostModel({required this.existingPost});
  final Post existingPost;

  final currentUser = auth.currentUser;
  bool isLoading = false;
  bool isCategoriesValid = true;

  TextEditingController? titleController;
  TextEditingController? bodyController;
  TextEditingController? nicknameController;

  void init() {
    titleController = TextEditingController(text: existingPost.title);
    bodyController = TextEditingController(text: existingPost.body);
    nicknameController = TextEditingController(text: existingPost.nickname);
    emotionDropdownValue = existingPost.emotion!;
    positionDropdownValue = existingPost.position!;
    genderDropdownValue = existingPost.gender!;
    ageDropdownValue = existingPost.age!;
    areaDropdownValue = existingPost.area!;

    notifyListeners();
  }

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

  Future<void> updatePost() async {
    startLoading();

    final newPost = Post(
      title: removeUnnecessaryBlankLines(titleController!.text),
      body: removeUnnecessaryBlankLines(bodyController!.text),
      nickname: removeUnnecessaryBlankLines(nicknameController!.text),
      emotion: convertNoSelectedValueToEmpty(emotionDropdownValue),
      position: convertNoSelectedValueToEmpty(positionDropdownValue),
      gender: convertNoSelectedValueToEmpty(genderDropdownValue),
      age: convertNoSelectedValueToEmpty(ageDropdownValue),
      area: convertNoSelectedValueToEmpty(areaDropdownValue),
      categories: selectedCategories,
    );

    try {
      await PostRepository.instance.updatePost(
        userId: existingPost.userId!,
        postId: existingPost.id!,
        newPost: newPost,
      );
    } on Exception catch (e) {
      print('updatePost???????????????????????????');
      print(e.toString());
      throw Exception('?????????????????????????????????\n?????????????????????????????????');
    } finally {
      stopLoading();
    }
  }

  // Future<void> updatePost(Post post) async {
  //   startLoading();

  //   final userRef = firestore.collection('users').doc(post.userId);
  //   final postRef = userRef.collection('posts').doc(post.id);

  //   try {
  //     await postRef.update({
  //       'title': removeUnnecessaryBlankLines(titleValue),
  //       'body': removeUnnecessaryBlankLines(bodyValue),
  //       'nickname': removeUnnecessaryBlankLines(nicknameValue),
  //       'emotion': convertNoSelectedValueToEmpty(emotionDropdownValue),
  //       'position': convertNoSelectedValueToEmpty(positionDropdownValue),
  //       'gender': convertNoSelectedValueToEmpty(genderDropdownValue),
  //       'age': convertNoSelectedValueToEmpty(ageDropdownValue),
  //       'area': convertNoSelectedValueToEmpty(areaDropdownValue),
  //       'categories': selectedCategories,
  //       'updatedAt': serverTimestamp(),
  //     });
  //   } on Exception catch (e) {
  //     print('updatePost???????????????????????????');
  //     print(e.toString());
  //     throw Exception('?????????????????????????????????\n?????????????????????????????????');
  //   } finally {
  //     stopLoading();
  //   }
  // }

  Future<void> addPostFromDraft(Post draftedPost) async {
    startLoading();

    final _batch = firestore.batch();

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

    _batch.update(userRef, <String, dynamic>{
      'postCount': (userDoc['postCount'] as int) + 1,
    });

    final draftedPostRef =
        userRef.collection('draftedPosts').doc(draftedPost.id);

    _batch.delete(draftedPostRef);

    try {
      await _batch.commit();
    } on Exception catch (e) {
      print('addPostFromDraft???????????????????????????????????????');
      print(e.toString());
      throw Exception('?????????????????????????????????\n?????????????????????????????????');
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
      print('updateDraftPost???????????????????????????');
      print(e.toString());
      throw Exception('?????????????????????????????????\n?????????????????????????????????');
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

  void toggleCategory(String chipName) {
    if (selectedCategories.contains(chipName)) {
      selectedCategories.remove(chipName);
    } else {
      selectedCategories.add(chipName);
    }
    notifyListeners();
  }

  String? validateTitleCallback(String? value) {
    if (value == null || value.isEmpty) {
      return '???????????????????????????????????????';
    } else if (value.length > 50) {
      return '50?????????????????????????????????';
    }
    return null;
  }

  String? validateContentCallback(String? value) {
    if (value == null || value.isEmpty) {
      return '??????????????????????????????????????????';
    } else if (value.length > 1500) {
      return '1500?????????????????????????????????';
    }
    return null;
  }

  String? validateNicknameCallback(String? value) {
    if (value == null || value.isEmpty) {
      return '?????????????????????????????????????????????';
    } else if (value.length > 10) {
      return '10?????????????????????????????????';
    }
    return null;
  }

  String? validateEmotionCallback(String? value) {
    if (value == kPleaseSelect) {
      return '????????????????????????????????????????????????';
    }
    return null;
  }

  String? validatePositionCallback(String? value) {
    if (value == kPleaseSelect) {
      return '?????????????????????????????????????????????';
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

  @override
  void dispose() {
    titleController?.dispose();
    bodyController?.dispose();
    nicknameController?.dispose();
    super.dispose();
  }
}
