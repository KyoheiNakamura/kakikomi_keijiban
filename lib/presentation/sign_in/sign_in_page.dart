import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/components/common_loading_spinner.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/mixin/show_exception_dialog_mixin.dart';
import 'package:kakikomi_keijiban/presentation/home/home_page.dart';
import 'package:kakikomi_keijiban/presentation/sign_in/sign_in_model.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatelessWidget with ShowExceptionDialogMixin {
  const SignInPage({Key? key}) : super(key: key);
  GlobalKey<FormState> get _formKey => GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SignInModel>(
      create: (context) => SignInModel(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          title: const Text('ログイン'),
        ),
        body: Consumer<SignInModel>(
          builder: (context, model, child) {
            return LoadingSpinner(
              isModalLoading: model.isModalLoading,
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            /// email
                            TextFormField(
                              controller: model.emailController,
                              validator: model.validateEmailCallback,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                // prefixIcon: Icon(Icons.text_fields),
                                labelText: 'メールアドレス',
                              ),
                            ),
                            const SizedBox(height: 24),

                            /// password
                            TextFormField(
                              controller: model.passwordController,
                              validator: model.validatePasswordCallback,
                              obscureText: true,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                // prefixIcon: Icon(Icons.password),
                                labelText: 'パスワード（8文字以上の半角英数記号）',
                              ),
                            ),
                            const SizedBox(height: 24),

                            /// 投稿送信ボタン
                            OutlinedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  try {
                                    await model.signInWithEmailAndPassword();
                                    await Navigator.pushAndRemoveUntil<void>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const HomePage(),
                                      ),
                                      (_) => false,
                                    );
                                    // Navigator.pop(context, 'signedIn');
                                  } on Exception catch (e) {
                                    await showExceptionDialog(context, e);
                                  }
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: kDarkPink,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                // shape: RoundedRectangleBorder(
                                //   borderRadius: BorderRadius.circular(15),
                                // ),
                                side: const BorderSide(color: kDarkPink),
                              ),
                              child: const Text(
                                'ログインする',
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
                      const Divider(thickness: 1),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Text(
                            //   'SNSアカウントからログイン',
                            //   style: TextStyle(fontSize: 16),
                            // ),
                            const SizedBox(height: 16),
                            OutlinedButton(
                              onPressed: () async {
                                try {
                                  await model.signInWithGoogle();
                                  await Navigator.pushAndRemoveUntil<void>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const HomePage(),
                                    ),
                                    (_) => false,
                                  );
                                  // if (model.oldUser != model.newUser) {
                                  //   Navigator.pop(context, 'signedIn');
                                  // } else {
                                  //   Navigator.pop(context);
                                  // }
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
                                      'Googleでログイン',
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
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
