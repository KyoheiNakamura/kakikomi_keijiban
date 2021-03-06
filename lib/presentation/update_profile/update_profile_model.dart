import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';

class UpdateProfileModel extends ChangeNotifier {
  final currentUser = auth.currentUser!;

  bool isLoading = false;

  String nicknameValue = '';
  String positionDropdownValue = kPleaseSelect;
  String genderDropdownValue = kPleaseSelect;
  String ageDropdownValue = kPleaseSelect;
  String areaDropdownValue = kPleaseSelect;

  Future<void> updateUserProfile() async {
    startLoading();

    final userRef = firestore.collection('users').doc(currentUser.uid);
    final _userProfileList = _convertNoSelectedValueToEmpty();

    try {
      await currentUser.updateProfile(
        displayName: _userProfileList[0],
      );

      await currentUser.reload();

      await userRef.update({
        'userId': currentUser.uid,
        'nickname': _userProfileList[0],
        'position': _userProfileList[1],
        'gender': _userProfileList[2],
        'age': _userProfileList[3],
        'area': _userProfileList[4],
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on Exception catch (e) {
      print('updateUserProfile処理中のエラーです');
      print(e.toString());
      throw Exception('エラーが発生しました。\nもう一度お試し下さい。');
    } finally {
      stopLoading();
    }
  }

  List<String> _convertNoSelectedValueToEmpty() {
    final userProfileList = [
      nicknameValue,
      positionDropdownValue,
      genderDropdownValue,
      ageDropdownValue,
      areaDropdownValue,
    ].map((profileData) {
      if (profileData == kPleaseSelect || profileData == kDoNotSelect) {
        return '';
      } else {
        return profileData;
      }
    }).toList();
    return userProfileList;
  }

  String? validateNicknameCallback(String? value) {
    if (value == null || value.isEmpty) {
      return 'ニックネームを入力してください';
    } else if (value.length > 10) {
      return '10字以内でご記入ください';
    }
    return null;
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
