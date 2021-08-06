import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/components/common_loading_spinner.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/mixin/show_exception_dialog_mixin.dart';
import 'package:kakikomi_keijiban/presentation/select_registration_method/select_registration_method_model.dart';
import 'package:kakikomi_keijiban/presentation/sign_in/sign_in_page.dart';
import 'package:kakikomi_keijiban/presentation/sign_up/sign_up_page.dart';
import 'package:provider/provider.dart';

class SelectRegistrationMethodPage extends StatelessWidget
    with ShowExceptionDialogMixin {
  const SelectRegistrationMethodPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SelectRegistrationMethodModel>(
      create: (context) => SelectRegistrationMethodModel(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          title: const Text('会員登録またはログイン'),
        ),
        // Todo めちゃくちゃ簡潔に書けそうなので、後で書き直そう
        body: Consumer<SelectRegistrationMethodModel>(
            builder: (context, model, child) {
          return LoadingSpinner(
            isModalLoading: model.isModalLoading,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16, top: 24, right: 16, bottom: 12),
                  child: OutlinedButton(
                    onPressed: () async {
                      await Navigator.push<void>(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      );
                      // Navigator.pop(context);
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(kDarkPink),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const <Widget>[
                        // Icon(Icons.email_outlined, color: Colors.white),
                        Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            'メールアドレスで登録',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16, top: 12, right: 16, bottom: 16),
                  child: OutlinedButton(
                    onPressed: () async {
                      await Navigator.push<void>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignInPage(),
                        ),
                      );
                      // Navigator.pop(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const <Widget>[
                        // Icon(Icons.login_outlined, color: kDarkPink),
                        Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            'アカウントをすでにお持ちの方',
                            style: TextStyle(
                              color: kDarkPink,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(thickness: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () async {
                          try {
                            await model
                                .signUpAndSignInWithGoogleAndUpgradeAnonymous();
                            if (model.oldUser != model.newUser) {
                              Navigator.pop(context, 'signedIn');
                            } else {
                              Navigator.pop(context);
                            }
                          } on Exception catch (e) {
                            await showExceptionDialog(context, e);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'lib/assets/images/google_logo.png',
                                scale: 15,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Googleで登録',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
