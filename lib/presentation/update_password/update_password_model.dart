import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/enum.dart';

class UpdatePasswordModel extends ChangeNotifier {
  final User currentUser = FirebaseAuth.instance.currentUser!;
  final String email = FirebaseAuth.instance.currentUser!.email!;
  String enteredCurrentPassword = '';
  String enteredNewPassword = '';
  bool isLoading = false;

  void startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void stopLoading() {
    isLoading = false;
    notifyListeners();
  }

  Future updatePassword() async {
    try {
      AuthCredential emailAuthCredential = EmailAuthProvider.credential(
        email: email,
        password: enteredCurrentPassword,
      );
      await currentUser.reauthenticateWithCredential(emailAuthCredential);
    } on FirebaseAuthException catch (e) {
      print('エラーコード：${e.code}\nエラー：$e');
      return e.toString();
    }

    try {
      await currentUser.updatePassword(enteredNewPassword);
      await currentUser.reload();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        print('お手数ですが一度ログアウトしたのち、再度ログインしてからもう一度お試しください。');
        return AuthException.requiresRecentLogin;
      } else {
        print(e);
        return e.toString();
      }
    } catch (e) {
      print(e);
      return e.toString();
    }
  }
}
