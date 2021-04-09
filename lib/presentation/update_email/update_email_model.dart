import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/enum.dart';

class UpdateEmailModel extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final User currentUser = FirebaseAuth.instance.currentUser!;
  final String currentEmail = FirebaseAuth.instance.currentUser!.email!;
  String enteredNewEmail = '';
  String enteredPassword = '';
  bool isLoading = false;

  void startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void stopLoading() {
    isLoading = false;
    notifyListeners();
  }

  Future<dynamic> updateEmail() async {
    try {
      AuthCredential emailAuthCredential = EmailAuthProvider.credential(
        email: currentEmail,
        password: enteredPassword,
      );
      await currentUser.reauthenticateWithCredential(emailAuthCredential);
    } on FirebaseAuthException catch (e) {
      print('エラーコード：${e.code}\nエラー：$e');
      return e.toString();
    }

    try {
      await currentUser.updateEmail(enteredNewEmail);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        print('このメールアドレスは形式が正しくありません。');
        return AuthException.invalidEmail;
      } else if (e.code == 'email-already-in-use') {
        print('このメールアドレスはすでに使用されています。');
        return AuthException.emailAlreadyInUse;
      } else if (e.code == 'requires-recent-login') {
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