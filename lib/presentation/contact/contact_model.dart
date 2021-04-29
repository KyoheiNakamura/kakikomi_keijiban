import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/constants.dart';

class ContactModel extends ChangeNotifier {
  String? email = FirebaseAuth.instance.currentUser!.email;
  String contactDropdownValue = kPleaseSelect;
  String contentValue = '';

  bool isLoading = false;

  // onCall()でメールを送る
  Future<void> submitContactForm() async {
    startLoading();

    HttpsCallable sendMail =
        FirebaseFunctions.instanceFor(region: 'asia-northeast1')
            .httpsCallable('sendMailWhenContactIsSubmitted');
    try {
      await sendMail.call({
        'email': this.email,
        'category': this.contactDropdownValue,
        'content': this.contentValue,
      });
    } on Exception catch (e) {
      print('submitFormの送信時のエラーです');
      print(e.toString());
      throw ('エラーが発生しました。\nもう一度お試しください。');
    } finally {
      stopLoading();
    }
  }

  // onCreate()でメールを送る
  // Future<void> submitContactForm() async {
  //   startLoading();
  //
  //   final contactRef = FirebaseFirestore.instance.collection('contacts').doc();
  //
  //   try {
  //     await contactRef.set({
  //       'id': contactRef.id,
  //       'userId': FirebaseAuth.instance.currentUser!.uid,
  //       'email': this.email,
  //       'category': this.contactDropdownValue,
  //       'content': this.contentValue,
  //       'createdAt': FieldValue.serverTimestamp(),
  //     });
  //   } on Exception catch (e) {
  //     print('submitFormの送信時のエラーです');
  //     print(e.toString());
  //     throw ('エラーが発生しました。\nもう一度お試しください。');
  //   } finally {
  //     stopLoading();
  //   }
  // }

  String? validateEmailCallback(String? value) {
    if (value == null ||
        value.isEmpty ||
        RegExp(kValidEmailRegularExpression).hasMatch(email!) == false) {
      return 'メールアドレスを入力してください';
    } else {
      return null;
    }
  }

  String? validateContactCallback(String? value) {
    if (value == kPleaseSelect) {
      return 'お問い合わせのカテゴリーを選択してください';
    }
    return null;
  }

  String? validateContentCallback(String? value) {
    if (value == null || value.isEmpty) {
      return 'お問い合わせの内容を入力してください';
    } else if (value.length > 500) {
      return '500字以内でご記入ください';
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
