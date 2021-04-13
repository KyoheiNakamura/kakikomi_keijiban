import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/components/loading_spinner.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/enum.dart';
import 'package:kakikomi_keijiban/common/mixin/show_auth_error_dialog_mixin.dart';
import 'package:kakikomi_keijiban/presentation/update_email/update_email_model.dart';
import 'package:provider/provider.dart';

class UpdateEmailPage extends StatelessWidget with ShowAuthErrorDialogMixin {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UpdateEmailModel>(
      create: (context) => UpdateEmailModel(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'メールアドレスの変更',
            style: kAppBarTextStyle,
          ),
        ),
        body: Consumer<UpdateEmailModel>(
          builder: (context, model, child) {
            return LoadingSpinner(
              inAsyncCall: model.isLoading,
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 32.0, horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        /// currentEmail
                        Text('現在のメールアドレス'),
                        SizedBox(height: 8.0),
                        Text(
                          model.currentEmail,
                          style: TextStyle(fontSize: 17.0),
                        ),
                        SizedBox(height: 32.0),

                        /// newEmail
                        TextFormField(
                          validator: (value) {
                            // Todo emailのvalidationを書く（正規表現）
                            // if (value == null ||
                            //     value.isEmpty ||
                            //     RegExp(kValidEmailRegularExpression)
                            //         .hasMatch(value)) {
                            //   return 'メールアドレスを入力してください';
                            // }
                            if (value == null || value.isEmpty) {
                              return 'メールアドレスを入力してください';
                            }
                            return null;
                          },
                          onChanged: (newValue) {
                            model.enteredNewEmail = newValue;
                          },
                          autofocus: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            // prefixIcon: Icon(Icons.text_fields),
                            labelText: '新しいメールアドレス',
                          ),
                        ),
                        SizedBox(height: 32.0),

                        /// password
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'パスワードを入力してください';
                            } else if (value.length < 8) {
                              // Todo 半角英数記号の正規表現を書く
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
                            // prefixIcon: Icon(Icons.text_fields),
                            labelText: 'パスワード',
                          ),
                        ),
                        SizedBox(height: 40.0),

                        /// 投稿送信ボタン
                        OutlinedButton(
                          onPressed: () async {
                            print(model.currentEmail);
                            if (_formKey.currentState!.validate()) {
                              model.startLoading();
                              var updateEmailResult = await model.updateEmail();
                              if (updateEmailResult ==
                                  AuthException.emailAlreadyInUse) {
                                await showAuthErrorDialog(
                                    context, 'このメールアドレスは\nすでに使用されています。');
                              } else if (updateEmailResult ==
                                  AuthException.invalidEmail) {
                                await showAuthErrorDialog(
                                    context, 'このメールアドレスは\n形式が正しくありません。');
                              } else if (updateEmailResult ==
                                  AuthException.requiresRecentLogin) {
                                await showAuthErrorDialog(context,
                                    '最後にログインしてから時間が経っています。\nお手数ですが一度ログアウトしたのち、再度ログインしてからもう一度お試しください。');
                              } else if (updateEmailResult is String) {
                                await showAuthErrorDialog(
                                    context, updateEmailResult);
                              } else {
                                Navigator.of(context).popUntil(
                                  ModalRoute.withName('/'),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('メールアドレスが変更されました。'),
                                  ),
                                );
                              }
                              model.stopLoading();
                            }
                          },
                          child: Text(
                            'メールアドレスを変更する',
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
