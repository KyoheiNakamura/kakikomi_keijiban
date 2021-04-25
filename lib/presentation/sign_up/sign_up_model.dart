import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/app_model.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignUpModel extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  bool isLoading = false;

  String enteredEmail = '';
  String enteredPassword = '';
  String enteredNickname = '';

  Future signUpAndSignInWithEmailAndUpgradeAnonymous() async {
    startLoading();

    try {
      final AuthCredential credential = EmailAuthProvider.credential(
        email: enteredEmail,
        password: enteredPassword,
      );
      await _auth.currentUser!.linkWithCredential(credential);

      await _auth.currentUser!.reload();

      // Auth.UserのcurrentUserにdisplayNameをセットした。
      await _auth.currentUser!.updateProfile(
        displayName: enteredNickname,
      );

      await AppModel.reloadUser();

      // anonymousのuserDocRefのデータを、email認証で登録したユーザーのデータでsetを使って置き換えている。
      final userDocRef =
          _firestore.collection('users').doc(_auth.currentUser!.uid);
      // setはuserDocRefのDocument idをもつDocumentにデータを保存する。
      await userDocRef.update({
        'nickname': enteredNickname,
        'postCount': AppModel.user!.postCount,
        'topics': AppModel.user!.topics,
        'notifications': AppModel.user!.notifications,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await AppModel.reloadUser();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print('このメールアドレスはすでに使用されています。');
        throw ('このメールアドレスはすでに使用されています。');
      } else if (e.code == 'invalid-email') {
        print('このメールアドレスは形式が正しくありません。');
        throw ('このメールアドレスは形式が正しくありません。');
        // Todo createUserWithEmailAndPassword()の他の例外処理も書こう
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

  Future signUpAndSignInWithGoogleAndUpgradeAnonymous() async {
    startLoading();

    try {
      final GoogleSignInAccount googleUser = (await GoogleSignIn().signIn())!;
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.currentUser!.linkWithCredential(credential);
      // final Auth.User user = userCredential.user!;
      // final String email = user.email!;
      // _firestore.collection('users').add({
      //   'id': user.uid,
      //   'email': email,
      //   'nickname': enteredNickname,
      //   'createdAt': Timestamp.now(),
      // });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print('このメールアドレスはすでに使用されています。');
        throw ('このメールアドレスはすでに使用されています。');
      } else if (e.code == 'invalid-email') {
        print('このメールアドレスは形式が正しくありません。');
        throw ('このメールアドレスは形式が正しくありません。');
        // Todo createUserWithEmailAndPassword()の他の例外処理も書こう
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
    } else if (value.length < 8) {
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
//         await _auth.createUserWithEmailAndPassword(
//       email: enteredEmail,
//       password: enteredPassword,
//     );
//     final Auth.User user = userCredential.user!;
//     final String email = user.email!;
//     _firestore.collection('users').add({
//       'id': user.uid,
//       'email': email,
//       'nickname': enteredNickname,
//       'createdAt': FieldValue.serverTimestamp(),
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
//   } catch (e) {
//     print(e);
//     return e;
//   }
// }

// Future<void> linkAnonymousWithEmail() async {
  //   final AuthCredential emailAuthCredential = EmailAuthProvider.credential(
  //     email: enteredEmail,
  //     password: enteredPassword,
  //   );
  //   await _auth.currentUser!.linkWithCredential(emailAuthCredential);
  // }
}
