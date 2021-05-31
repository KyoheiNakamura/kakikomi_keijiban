import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/app_model.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';

class SignUpModel extends ChangeNotifier {
  bool isModalLoading = false;

  String enteredEmail = '';
  String enteredPassword = '';
  String enteredNickname = '';

  Future signUpAndSignInWithEmailAndUpgradeAnonymous() async {
    startModalLoading();

    try {
      final credential = EmailAuthProvider.credential(
        email: enteredEmail,
        password: enteredPassword,
      );
      await auth.currentUser!.linkWithCredential(credential);
      await auth.currentUser!.reload();
      // Auth.UserのcurrentUserにdisplayNameをセットした。
      await auth.currentUser!.updateProfile(
        displayName: enteredNickname,
      );
      await AppModel.reloadUser();
      // anonymousのuserDocRefのデータを、email認証で登録したユーザーのデータでupdateを使って更新している。
      final userDocRef =
          firestore.collection('users').doc(auth.currentUser!.uid);
      // setはuserDocRefのDocument idをもつDocumentにデータを保存する。
      await userDocRef.update({
        'nickname': enteredNickname,
        'postCount': AppModel.user!.postCount,
        'topics': AppModel.user!.topics,
        'pushNoticesSetting': AppModel.user!.pushNoticesSetting,
        'badges': AppModel.user!.badges,
        'updatedAt': serverTimestamp(),
      });
      await AppModel.reloadUser();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print('このメールアドレスはすでに使用されています。');
        throw 'このメールアドレスはすでに使用されています。';
      } else if (e.code == 'invalid-email') {
        print('このメールアドレスは形式が正しくありません。');
        throw 'このメールアドレスは形式が正しくありません。';
        // Todo createUserWithEmailAndPassword()の他の例外処理も書こう
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

  String? validateNicknameCallback(String? value) {
    if (value == null || value.isEmpty) {
      return 'ニックネームを入力してください';
    } else if (value.length > 10) {
      return '10字以内でご記入ください';
    } else {
      return null;
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

// createUserWithEmailAndPassword()の説明（アカウント作成後、自動でログインしてくれる）
// The method is a two-step operation; it will first create the new account (if it does not already exist and the password is valid) and then automatically sign in the user in to that account.
// Future signUpAndLogIn() async {
//   try {
//     final UserCredential userCredential =
//         await auth.createUserWithEmailAndPassword(
//       email: enteredEmail,
//       password: enteredPassword,
//     );
//     final Auth.User user = userCredential.user!;
//     final String email = user.email!;
//     firestore.collection('users').add({
//       'id': user.uid,
//       'email': email,
//       'nickname': enteredNickname,
//       'createdAt': serverTimestamp(),
//     });
//   } on FirebaseAuthException catch (e) {
//     if (e.code == 'email-already-in-use') {
//       print('このメールアドレスはすでに使用されています。');
//       return AuthException.emailAlreadyInUse;
//     } else if (e.code == 'invalid-email') {
//       print('このメールアドレスは形式が正しくないです。');
//       return AuthException.invalidEmail;
//     } else {
//       print(e);
//       return e;
//     }
//   } on String catch (e) {
//     print(e);
//     return e;
//   }
// }

// Future<void> linkAnonymousWithEmail() async {
  //   final AuthCredential emailAuthCredential = EmailAuthProvider.credential(
  //     email: enteredEmail,
  //     password: enteredPassword,
  //   );
  //   await auth.currentUser!.linkWithCredential(emailAuthCredential);
  // }
}
