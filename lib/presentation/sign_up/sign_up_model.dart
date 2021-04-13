import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/enum.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignUpModel extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
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
  String enteredNickname = '';

  Future signUpAndSignInWithEmailAndUpgradeAnonymous() async {
    try {
      final AuthCredential credential = EmailAuthProvider.credential(
        email: enteredEmail,
        password: enteredPassword,
      );
      await _auth.currentUser!.linkWithCredential(credential);
      // Auth.UserのcurrentUserにdisplayNameをセットした。
      await _auth.currentUser!.updateProfile(
        displayName: enteredNickname,
      );
      // anonymousのuserDocRefのデータを、email認証で登録したユーザーのデータでsetを使って置き換えている。
      final userDocRef =
          _firestore.collection('users').doc(_auth.currentUser!.uid);
      // setはuserDocRefのDocument idをもつDocumentにデータを保存する。
      await userDocRef.set({
        'userId': _auth.currentUser!.uid,
        'nickname': enteredNickname,
        'position': '',
        'gender': '',
        'age': '',
        'area': '',
        'postCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
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
        return AuthException.emailAlreadyInUse;
      } else if (e.code == 'invalid-email') {
        print('このメールアドレスは形式が正しくないです。');
        return AuthException.invalidEmail;
        // Todo createUserWithEmailAndPassword()の他の例外処理も書こう
      } else {
        print(e);
        return e;
      }
    } catch (e) {
      print(e);
      return e;
    }
  }

  Future signUpAndSignInWithGoogleAndUpgradeAnonymous() async {
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
        return AuthException.emailAlreadyInUse;
      } else if (e.code == 'invalid-email') {
        print('このメールアドレスは形式が正しくないです。');
        return AuthException.invalidEmail;
        // Todo createUserWithEmailAndPassword()の他の例外処理も書こう
      } else {
        print(e);
        return e;
      }
    } catch (e) {
      print(e);
      return e;
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
