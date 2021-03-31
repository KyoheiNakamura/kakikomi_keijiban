import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/enum.dart';
import 'package:kakikomi_keijiban/presentation/sign_in/sign_in_model.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void clearText() {
    _emailController.clear();
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> _showAuthErrorDialog(String errorMessage) async {
      return await showDialog<void>(
        context: context,
        // barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            // title: Text('認証エラー'),
            content: Text(errorMessage),
            contentPadding:
                EdgeInsets.only(left: 24.0, top: 24.0, right: 24.0, bottom: 0),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'OK',
                  style: TextStyle(color: kDarkPink),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return ChangeNotifierProvider<SignInModel>(
      create: (context) => SignInModel(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'ログイン',
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Consumer<SignInModel>(
          builder: (context, model, child) {
            return SingleChildScrollView(
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
                        controller: _emailController,
                        onChanged: (newValue) {
                          model.enteredEmail = newValue;
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          // prefixIcon: Icon(Icons.text_fields),
                          labelText: 'メールアドレス',
                        ),
                      ),
                      SizedBox(
                        height: 32.0,
                      ),
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
                        controller: _passwordController,
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
                      SizedBox(
                        height: 48.0,
                      ),
                      // 投稿送信ボタン
                      OutlinedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            clearText();
                            var signInResult = await model.signIn();
                            if (signInResult ==
                                AuthException.emailAlreadyInUse) {
                              await _showAuthErrorDialog(
                                  'このメールアドレスは\nすでに使用されています。');
                            } else if (signInResult ==
                                AuthException.userNotFound) {
                              await _showAuthErrorDialog(
                                  'このメールアドレスは\n登録されていません。');
                            } else if (signInResult ==
                                AuthException.wrongPassword) {
                              await _showAuthErrorDialog('パスワードが正しくありません。');
                            } else {
                              Navigator.of(context).popUntil(
                                ModalRoute.withName('/'),
                              );
                            }
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
            );
          },
        ),
      ),
    );
  }
}
