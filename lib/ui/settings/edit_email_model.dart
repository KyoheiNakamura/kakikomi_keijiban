import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/config/constants.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';

class EditEmailModel extends ChangeNotifier {
  final User currentUser = auth.currentUser!;
  final String currentEmail = auth.currentUser!.email!;

  bool isLoading = false;

  String enteredEmail = '';
  String enteredPassword = '';

  Future<dynamic> updateEmail() async {
    startLoading();

    try {
      AuthCredential emailAuthCredential = EmailAuthProvider.credential(
        email: currentEmail,
        password: enteredPassword,
      );
      await currentUser.reauthenticateWithCredential(emailAuthCredential);
      await currentUser.updateEmail(enteredEmail);
      await currentUser.reload();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        print('パスワードが正しくありません。');
        throw ('パスワードが正しくありません。');
      } else if (e.code == 'invalid-email') {
        print('このメールアドレスは形式が正しくありません。');
        throw ('このメールアドレスは\n形式が正しくありません。');
      } else if (e.code == 'email-already-in-use') {
        print('このメールアドレスはすでに使用されています。');
        throw ('このメールアドレスは\nすでに使用されています。');
      } else if (e.code == 'requires-recent-login') {
        print('一度ログアウトしたのち、もう一度お試しください。');
        throw ('一度ログアウトしたのち、\nもう一度お試しください。');
      } else if (e.code == 'too-many-requests') {
        print('リクエストの数が超過しました。\n時間を置いてから再度お試しください。');
        throw ('リクエストの数が超過しました。\n時間を置いてから再度お試しください。');
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
    } else if (RegExp(kValidPasswordRegularExpression)
            .hasMatch(enteredPassword) ==
        false) {
      return '8文字以上の半角英数記号でご記入ください';
    } else {
      return null;
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
}
