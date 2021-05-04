import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakikomi_keijiban/app_model.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';

class SelectRegistrationMethodModel extends ChangeNotifier {
  bool isLoading = false;

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
      await auth.currentUser!.linkWithCredential(credential);
      await auth.currentUser!.reload();
      // anonymousのuserDocRefのデータを、google認証で登録したユーザーのデータでupdateを使って更新している。
      final userDocRef =
          firestore.collection('users').doc(auth.currentUser!.uid);
      // setはuserDocRefのDocument idをもつDocumentにデータを保存する。
      await userDocRef.update({
        'postCount': AppModel.user!.postCount,
        'topics': AppModel.user!.topics,
        'notifications': AppModel.user!.notifications,
        'updatedAt': serverTimestamp(),
      });
      await AppModel.reloadUser();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        print('このGoogleアカウントはすでに使用されています。');
        throw ('このGoogleアカウントは\nすでに使用されています。');
      } else if (e.code == 'email-already-in-use') {
        print('このメールアドレスはすでに使用されています。');
        throw ('このメールアドレスは\nすでに使用されています');
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
}
