import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';

class SignInModel extends ChangeNotifier {
  bool isModalLoading = false;

  final String oldUser = auth.currentUser!.uid;
  String newUser = '';

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future signInWithEmailAndPassword() async {
    startModalLoading();

    try {
      await auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      newUser = auth.currentUser!.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        print('このメールアドレスは形式が正しくありません。');
        throw 'このメールアドレスは\n形式が正しくありません。';
      } else if (e.code == 'user-not-found') {
        print('このメールアドレスは登録されていません。');
        throw 'このメールアドレスは\n登録されていません。';
      } else if (e.code == 'wrong-password') {
        print('パスワードが正しくありません。');
        throw 'パスワードが正しくありません。';
      } else {
        print(e.toString());
        throw 'エラーが発生しました。\nもう一度お試し下さい。';
      }
    } on Exception catch (e) {
      print(e.toString());
      throw 'エラーが発生しました。\nもう一度お試し下さい。';
    } finally {
      stopModalLoading();
    }
  }

  Future signInWithGoogle() async {
    startModalLoading();

    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await auth.signInWithCredential(credential);
        newUser = auth.currentUser!.uid;
      } else {
        throw 'アカウントを選択してください。';
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        print('このメールアドレスはすでに使用されています');
        throw 'このメールアドレスは\nすでに使用されています。';
      } else {
        print(e.toString());
        throw 'エラーが発生しました。\nもう一度お試し下さい。';
      }
    } on Exception catch (e) {
      print(e.toString());
      throw 'エラーが発生しました。\nもう一度お試し下さい。';
    } finally {
      stopModalLoading();
    }
  }

  void startModalLoading() {
    isModalLoading = true;
    notifyListeners();
  }

  void stopModalLoading() {
    isModalLoading = false;
    notifyListeners();
  }

  String? validateEmailCallback(String? value) {
    if (value == null ||
        value.isEmpty ||
        RegExp(kValidEmailRegularExpression).hasMatch(emailController.text.trim()) == false) {
      return 'メールアドレスを入力してください';
    } else {
      return null;
    }
  }

  String? validatePasswordCallback(String? value) {
    if (value == null || value.isEmpty) {
      return 'パスワードを入力してください';
    } else if (RegExp(kValidPasswordRegularExpression)
            .hasMatch(passwordController.text.trim()) ==
        false) {
      return '8文字以上の半角英数記号でご記入ください';
    } else {
      return null;
    }
  }
}
