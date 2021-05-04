import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';

class UpdatePasswordModel extends ChangeNotifier {
  final User currentUser = auth.currentUser!;
  final String email = auth.currentUser!.email!;

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
        print('一度ログアウトしたのち、もう一度お試しください。');
        throw ('一度ログアウトしたのち、\nもう一度お試しください。');
      } else if (e.code == 'wrong-password') {
        print('パスワードが正しくありません。');
        throw ('パスワードが正しくありません。');
      } else if (e.code == 'invalid-email') {
        print('このメールアドレスは形式が正しくありません。');
        throw ('このメールアドレスは\n形式が正しくありません。');
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

  String? validatePasswordCallback(String? value) {
    if (value == null || value.isEmpty) {
      return 'パスワードを入力してください';
    } else if (RegExp(kValidPasswordRegularExpression)
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
