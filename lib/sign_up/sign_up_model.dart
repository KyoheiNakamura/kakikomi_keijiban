import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpModel extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String enteredEmail = '';
  String enteredPassword = '';

  Future register() async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: enteredEmail,
        password: enteredPassword,
      );
      final User user = userCredential.user!;
      final String email = user.email!;
      _firestore.collection('users').add({
        'id': user.uid,
        'email': email,
        'createdAt': Timestamp.now(),
      });
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

enum AuthException { emailAlreadyInUse, invalidEmail }
