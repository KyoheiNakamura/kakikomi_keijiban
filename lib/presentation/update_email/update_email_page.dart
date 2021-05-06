import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/components/loading_spinner.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/mixin/show_exception_dialog_mixin.dart';
import 'package:kakikomi_keijiban/presentation/update_email/update_email_model.dart';
import 'package:provider/provider.dart';

class UpdateEmailPage extends StatelessWidget with ShowExceptionDialogMixin {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UpdateEmailModel>(
      create: (context) => UpdateEmailModel(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          title: Text('メールアドレスの変更'),
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
                        SelectableText(
                          model.currentEmail,
                          style: TextStyle(fontSize: 17.0),
                        ),
                        SizedBox(height: 32.0),

                        /// newEmail
                        TextFormField(
                          validator: model.validateEmailCallback,
                          onChanged: (newValue) {
                            model.enteredEmail = newValue.trim();
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
                          validator: model.validatePasswordCallback,
                          onChanged: (newValue) {
                            model.enteredPassword = newValue.trim();
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
                            if (_formKey.currentState!.validate()) {
                              try {
                                await model.updateEmail();
                                Navigator.of(context).popUntil(
                                  ModalRoute.withName('/'),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('メールアドレスが変更されました。'),
                                  ),
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
