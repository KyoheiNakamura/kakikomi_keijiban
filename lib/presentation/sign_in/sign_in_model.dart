import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/enum.dart';

class SignInModel extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  bool isLoading = false;

  void startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void stopLoading() {
    isLoading = false;
    notifyListeners();
  }

  String enteredEmail = '';
  String enteredPassword = '';

  Future signIn() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: enteredEmail,
        password: enteredPassword,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        print('このメールアドレスは形式が正しくありません。');
        return AuthException.invalidEmail;
      } else if (e.code == 'user-not-found') {
        print('このメールアドレスは登録されていません。');
        return AuthException.userNotFound;
      } else if (e.code == 'wrong-password') {
        print('パスワードが正しくありません。');
        return AuthException.wrongPassword;
      } else {
        print(e);
        return e;
      }
    } catch (e) {
      print(e);
      return e;
    }
  }
}
