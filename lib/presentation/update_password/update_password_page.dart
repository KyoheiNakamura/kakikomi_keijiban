import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/components/loading_spinner.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/mixin/show_exception_dialog_mixin.dart';
import 'package:kakikomi_keijiban/presentation/update_password/update_password_model.dart';
import 'package:provider/provider.dart';

class UpdatePasswordPage extends StatelessWidget with ShowExceptionDialogMixin {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UpdatePasswordModel>(
      create: (context) => UpdatePasswordModel(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          title: const Text('パスワードの変更'),
        ),
        body: Consumer<UpdatePasswordModel>(
          builder: (context, model, child) {
            return LoadingSpinner(
              inAsyncCall: model.isLoading,
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 32, horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        /// currentEmail
                        const Text('メールアドレス'),
                        const SizedBox(height: 8),
                        Text(
                          model.email,
                          style: const TextStyle(fontSize: 17),
                        ),
                        const SizedBox(height: 32),

                        /// currentPassword
                        TextFormField(
                          // validator: model.validatePasswordCallback,
                          onChanged: (newValue) {
                            model.enteredCurrentPassword = newValue;
                          },
                          obscureText: true,
                          autofocus: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            // prefixIcon: Icon(Icons.text_fields),
                            labelText: '現在のパスワード',
                          ),
                        ),
                        const SizedBox(height: 32),

                        /// newPassword
                        TextFormField(
                          validator: model.validatePasswordCallback,
                          onChanged: (newValue) {
                            model.enteredNewPassword = newValue;
                          },
                          obscureText: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            // prefixIcon: Icon(Icons.password),
                            labelText: '新しいパスワード（8文字以上の半角英数記号）',
                          ),
                        ),
                        const SizedBox(height: 40),

                        /// 投稿送信ボタン
                        OutlinedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                await model.updatePassword();
                                Navigator.of(context).popUntil(
                                  ModalRoute.withName('/'),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('パスワードが変更されました。'),
                                  ),
                                );
                              } on String catch (e) {
                                await showExceptionDialog(
                                  context,
                                  e.toString(),
                                );
                              }
                            }
                          },
                          child: const Text(
                            'パスワードを変更する',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: kDarkPink,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            // shape: RoundedRectangleBorder(
                            //   borderRadius: BorderRadius.circular(15),
                            // ),
                            side: const BorderSide(color: kDarkPink),
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
