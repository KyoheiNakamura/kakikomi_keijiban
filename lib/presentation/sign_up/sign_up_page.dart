import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/components/loading_spinner.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/enum.dart';
import 'package:kakikomi_keijiban/common/mixin/show_exception_dialog_mixin.dart';
import 'package:kakikomi_keijiban/presentation/sign_up/sign_up_model.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatelessWidget with ShowExceptionDialogMixin {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SignUpModel>(
      create: (context) => SignUpModel(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          elevation: 0,
          centerTitle: true,
          title: Text(
            '会員登録',
            style: kAppBarTextStyle,
          ),
        ),
        body: Consumer<SignUpModel>(
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
                        /// nickname
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'ニックネームを入力してください';
                            } else if (value.length > 10) {
                              return '10文字以下でご記入ください';
                            }
                            return null;
                          },
                          onChanged: (newValue) {
                            model.enteredNickname = newValue;
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            // prefixIcon: Icon(Icons.password),
                            labelText: 'ニックネーム（10文字以内）',
                          ),
                        ),
                        SizedBox(height: 32.0),

                        /// content
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

                        /// password
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

                        /// 投稿送信ボタン
                        OutlinedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              model.startLoading();
                              var signInResult = await model
                                  .signUpAndSignInWithEmailAndUpgradeAnonymous();
                              if (signInResult ==
                                  AuthException.emailAlreadyInUse) {
                                await showExceptionDialog(
                                    context, 'このメールアドレスは\nすでに使用されています。');
                              } else if (signInResult ==
                                  AuthException.invalidEmail) {
                                await showExceptionDialog(
                                    context, 'このメールアドレスは\n形式が正しくありません。');
                              } else {
                                Navigator.of(context).popUntil(
                                  ModalRoute.withName('/'),
                                );
                              }
                              model.stopLoading();
                            }
                          },
                          child: Text(
                            '登録する',
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
