import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/constants.dart';

class UpdateEmailModel extends ChangeNotifier {
  final User currentUser = FirebaseAuth.instance.currentUser!;
  final String currentEmail = FirebaseAuth.instance.currentUser!.email!;
  String enteredEmail = '';
  String enteredPassword = '';
  bool isLoading = false;

  Future<dynamic> updateEmail() async {
    startLoading();

    try {
      AuthCredential emailAuthCredential = EmailAuthProvider.credential(
        email: currentEmail,
        password: enteredPassword,
      );
      await currentUser.reauthenticateWithCredential(emailAuthCredential);
    } on FirebaseAuthException catch (e) {
      print('エラーコード：${e.code}\nエラー：$e');
      throw e.toString();
    }

    try {
      await currentUser.updateEmail(enteredEmail);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        print('このメールアドレスは形式が正しくありません。');
        throw ('このメールアドレスは\n形式が正しくありません。');
      } else if (e.code == 'email-already-in-use') {
        print('このメールアドレスはすでに使用されています。');
        throw ('このメールアドレスは\nすでに使用されています。');
      } else if (e.code == 'requires-recent-login') {
        print('お手数ですが一度ログアウトしたのち、再度ログインしてからもう一度お試しください。');
        throw ('お手数ですが一度ログアウトしたのち、\n再度ログインしてからもう一度お試しください。');
      } else {
        print(e.toString());
        throw e.toString();
      }
    } on Exception catch (e) {
      print(e.toString());
      throw e.toString();
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
