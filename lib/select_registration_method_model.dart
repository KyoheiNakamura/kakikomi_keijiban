import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakikomi_keijiban/enum.dart';

class SelectRegistrationMethodModel extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;

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
}
