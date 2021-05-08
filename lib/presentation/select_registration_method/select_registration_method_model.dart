import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakikomi_keijiban/app_model.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';

class SelectRegistrationMethodModel extends ChangeNotifier {
  bool isModalLoading = false;

  final String oldUser = auth.currentUser!.uid;
  String newUser = '';

  Future signUpAndSignInWithGoogleAndUpgradeAnonymous() async {
    startModalLoading();

    try {
      final GoogleSignInAccount? googleUser = (await GoogleSignIn().signIn());
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await auth.currentUser!.linkWithCredential(credential);
        await auth.currentUser!.reload();
        newUser = auth.currentUser!.uid;
        // anonymousのuserDocRefのデータを、google認証で登録したユーザーのデータでupdateを使って更新している。
        final userDocRef =
            firestore.collection('users').doc(auth.currentUser!.uid);
        // setはuserDocRefのDocument idをもつDocumentにデータを保存する。
        await userDocRef.update({
          'nickname': '匿名',
          'postCount': AppModel.user!.postCount,
          'topics': AppModel.user!.topics,
          'pushNoticesSetting': AppModel.user!.pushNoticesSetting,
          'badges': AppModel.user!.badges,
          'updatedAt': serverTimestamp(),
        });
        await AppModel.reloadUser();
      } else {
        throw ('アカウントを選択してください。');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        print('このGoogleアカウントはすでに使用されています。');
        throw ('このGoogleアカウントは\nすでに使用されています。');
      } else if (e.code == 'email-already-in-use') {
        print('このメールアドレスはすでに使用されています。');
        throw ('このメールアドレスは\nすでに使用されています。');
      } else {
        print(e.toString());
        throw ('エラーが発生しました。\nもう一度お試し下さい。');
      }
    } on Exception catch (e) {
      print(e.toString());
      throw ('エラーが発生しました。\nもう一度お試し下さい。');
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
}
