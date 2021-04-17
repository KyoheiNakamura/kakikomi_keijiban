import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/constants.dart';

class SignInModel extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  bool isLoading = false;

  String enteredEmail = '';
  String enteredPassword = '';

  Future signIn() async {
    startLoading();

    try {
      await _auth.signInWithEmailAndPassword(
        email: enteredEmail,
        password: enteredPassword,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        print('このメールアドレスは形式が正しくありません。');
        throw ('このメールアドレスは\n形式が正しくありません。');
      } else if (e.code == 'user-not-found') {
        print('このメールアドレスは登録されていません。');
        throw ('このメールアドレスは\n登録されていません。');
      } else if (e.code == 'wrong-password') {
        print('パスワードが正しくありません。');
        throw ('パスワードが正しくありません。');
      } else {
        print(e.toString());
        throw ('エラーが発生しました。\nもう一度お試し下さい。');
      }
    } on Exception catch (e) {
      print(e.toString());
      throw ('エラーが発生しました。\nもう一度お試し下さい。');
    } finally {
      stopLoading();
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

  String? validateEmailCallback(String? value) {
    if (value == null ||
        value.isEmpty ||
        RegExp(kValidEmailRegularExpression).hasMatch(enteredEmail) == false) {
      return 'メールアドレスを入力してください';
    } else {
      return null;
    }
  }

  String? validatePasswordCallback(String? value) {
    if (value == null || value.isEmpty) {
      return 'パスワードを入力してください';
    } else if (value.length < 8) {
      return '8文字以上の半角英数記号でご記入ください';
    } else {
      return null;
    }
  }
}
