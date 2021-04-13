import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/components/loading_spinner.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/enum.dart';
import 'package:kakikomi_keijiban/common/mixin/show_auth_error_dialog_mixin.dart';
import 'package:kakikomi_keijiban/presentation/sign_in/sign_in_model.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatelessWidget with ShowAuthErrorDialogMixin {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SignInModel>(
      create: (context) => SignInModel(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'ログイン',
            style: kAppBarTextStyle,
          ),
        ),
        body: Consumer<SignInModel>(
          builder: (context, model, child) {
            return LoadingSpinner(
              inAsyncCall: model.isLoading,
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 48.0, horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // content
                        TextFormField(
                          validator: (value) {
                            // Todo emailのvalidationを書く（正規表現）
                            // if (value == null ||
                            //     value.isEmpty ||
                            //     RegExp(r"/^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/)")
                            //         .hasMatch(model.enteredEmail)) {
                            //   return 'メールアドレスを入力してください';
                            // }
                            if (value == null || value.isEmpty) {
                              return 'メールアドレスを入力してください';
                            }
                            return null;
                          },
                          onChanged: (newValue) {
                            model.enteredEmail = newValue;
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            // prefixIcon: Icon(Icons.text_fields),
                            labelText: 'メールアドレス',
                          ),
                        ),
                        SizedBox(height: 32.0),
                        // nickname
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'パスワードを入力してください';
                            } else if (value.length < 8) {
                              return '8文字以上の半角英数記号でご記入ください';
                            }
                            return null;
                          },
                          onChanged: (newValue) {
                            model.enteredPassword = newValue;
                          },
                          obscureText: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            // prefixIcon: Icon(Icons.password),
                            labelText: 'パスワード（8文字以上の半角英数記号）',
                          ),
                        ),
                        SizedBox(height: 48.0),
                        // 投稿送信ボタン
                        OutlinedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              model.startLoading();

                              var signInResult = await model.signIn();
                              if (signInResult ==
                                  AuthException.emailAlreadyInUse) {
                                await showAuthErrorDialog(
                                    context, 'このメールアドレスは\nすでに使用されています。');
                              } else if (signInResult ==
                                  AuthException.userNotFound) {
                                await showAuthErrorDialog(
                                    context, 'このメールアドレスは\n登録されていません。');
                              } else if (signInResult ==
                                  AuthException.invalidEmail) {
                                await showAuthErrorDialog(
                                    context, 'このメールアドレスは形式が正しくありません。');
                              } else if (signInResult ==
                                  AuthException.wrongPassword) {
                                await showAuthErrorDialog(
                                    context, 'パスワードが正しくありません。');
                              } else {
                                Navigator.of(context).popUntil(
                                  ModalRoute.withName('/'),
                                );
                              }
                              model.stopLoading();
                            }
                          },
                          child: Text(
                            'ログインする',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: kDarkPink,
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            // shape: RoundedRectangleBorder(
                            //   borderRadius: BorderRadius.circular(15),
                            // ),
                            side: BorderSide(color: kDarkPink),
                          ),
                        )
                      ],
                    ),
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
