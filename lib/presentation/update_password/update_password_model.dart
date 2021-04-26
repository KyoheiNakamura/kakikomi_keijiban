import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/enum.dart';

class UpdatePasswordModel extends ChangeNotifier {
  final User currentUser = FirebaseAuth.instance.currentUser!;
  final String email = FirebaseAuth.instance.currentUser!.email!;

  bool isLoading = false;

  String enteredCurrentPassword = '';
  String enteredNewPassword = '';

  Future<void> updatePassword() async {
    startLoading();

    try {
      AuthCredential emailAuthCredential = EmailAuthProvider.credential(
        email: email,
        password: enteredCurrentPassword,
      );
      await currentUser.reauthenticateWithCredential(emailAuthCredential);
      await currentUser.updatePassword(enteredNewPassword);
      await currentUser.reload();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        print('お手数ですが一度ログアウトしたのち、再度ログインしてからもう一度お試しください。');
        throw ('お手数ですが一度ログアウトしたのち、\n再度ログインしてからもう一度お試しください。');
      } else if (e.code == 'wrong-password') {
        print('パスワードが正しくありません。');
        throw ('パスワードが正しくありません。');
      } else if (e.code == 'invalid-email') {
        print('このメールアドレスは形式が正しくありません。');
        throw ('このメールアドレスは\n形式が正しくありません。');
      } else if (e.code == 'too-many-requests') {
        print('リクエストの数が超過しました。\nしばらく時間を置いてからお試しください。');
        throw ('リクエストの数が超過しました。\nしばらく時間を置いてからお試しください。');
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

  String? validatePasswordCallback(String? value) {
    if (value == null || value.isEmpty) {
      return 'パスワードを入力してください';
    } else if (RegExp(kValidEmailRegularExpression)
            .hasMatch(enteredNewPassword) ==
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
