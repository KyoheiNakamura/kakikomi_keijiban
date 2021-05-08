import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/components/loading_spinner.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
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
          title: Text('会員登録'),
        ),
        body: Consumer<SignUpModel>(
          builder: (context, model, child) {
            return LoadingSpinner(
              inAsyncCall: model.isModalLoading,
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
                          validator: model.validateNicknameCallback,
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

                        /// email
                        TextFormField(
                          validator: model.validateEmailCallback,
                          onChanged: (newValue) {
                            model.enteredEmail = newValue.trim();
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
                          validator: model.validatePasswordCallback,
                          onChanged: (newValue) {
                            model.enteredPassword = newValue.trim();
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
                              try {
                                await model
                                    .signUpAndSignInWithEmailAndUpgradeAnonymous();
                                Navigator.of(context).popUntil(
                                  ModalRoute.withName('/'),
                                );
                              } catch (e) {
                                await showExceptionDialog(
                                  context,
                                  e.toString(),
                                );
                              }
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
