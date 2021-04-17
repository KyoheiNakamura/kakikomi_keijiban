import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/constants.dart';

class UpdateProfileModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final currentUser = FirebaseAuth.instance.currentUser;
  final uid = FirebaseAuth.instance.currentUser!.uid;
  bool isLoading = false;

  String nicknameValue = '';
  String positionDropdownValue = kPleaseSelect;
  String genderDropdownValue = kPleaseSelect;
  String ageDropdownValue = kPleaseSelect;
  String areaDropdownValue = kPleaseSelect;

  Future<void> updateUserProfile() async {
    startLoading();

    final userRef = _firestore.collection('users').doc(uid);
    List<String> _userProfileList = _convertNoSelectedValueToEmpty();

    try {
      await currentUser!.updateProfile(
        displayName: _userProfileList[0],
      );

      await userRef.update({
        'userId': uid,
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
      throw ('エラーが発生しました。\nもう一度お試し下さい。');
    } finally {
      stopLoading();
    }
  }

  List<String> _convertNoSelectedValueToEmpty() {
    List<String> userProfileList = [
      nicknameValue,
      positionDropdownValue,
      genderDropdownValue,
      ageDropdownValue,
      areaDropdownValue,
    ];
    userProfileList = userProfileList.map((profileData) {
      if (profileData == kPleaseSelect || profileData == kDoNotSelect) {
        return '';
      } else {
        return profileData;
      }
    }).toList();
    return userProfileList;
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
