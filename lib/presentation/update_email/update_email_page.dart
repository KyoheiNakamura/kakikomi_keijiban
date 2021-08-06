import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/components/common_loading_spinner.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/mixin/show_exception_dialog_mixin.dart';
import 'package:kakikomi_keijiban/presentation/update_email/update_email_model.dart';
import 'package:provider/provider.dart';

class UpdateEmailPage extends StatelessWidget with ShowExceptionDialogMixin {
  UpdateEmailPage({Key? key}) : super(key: key);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UpdateEmailModel>(
      create: (context) => UpdateEmailModel(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          title: const Text('メールアドレスの変更'),
        ),
        body: Consumer<UpdateEmailModel>(
          builder: (context, model, child) {
            return LoadingSpinner(
              isModalLoading: model.isLoading,
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
                        const Text('現在のメールアドレス'),
                        const SizedBox(height: 8),
                        SelectableText(
                          model.currentEmail,
                          style: const TextStyle(fontSize: 17),
                        ),
                        const SizedBox(height: 32),

                        /// newEmail
                        TextFormField(
                          validator: model.validateEmailCallback,
                          onChanged: (newValue) {
                            model.enteredEmail = newValue.trim();
                          },
                          autofocus: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            // prefixIcon: Icon(Icons.text_fields),
                            labelText: '新しいメールアドレス',
                          ),
                        ),
                        const SizedBox(height: 32),

                        /// password
                        TextFormField(
                          validator: model.validatePasswordCallback,
                          onChanged: (newValue) {
                            model.enteredPassword = newValue.trim();
                          },
                          obscureText: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            // prefixIcon: Icon(Icons.text_fields),
                            labelText: 'パスワード',
                          ),
                        ),
                        const SizedBox(height: 40),

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
                                  const SnackBar(
                                    content: Text('メールアドレスが変更されました。'),
                                  ),
                                );
                              } on Exception catch (e) {
                                await showExceptionDialog(context, e);
                              }
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: kDarkPink,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            // shape: RoundedRectangleBorder(
                            //   borderRadius: BorderRadius.circular(15),
                            // ),
                            side: const BorderSide(color: kDarkPink),
                          ),
                          child: const Text(
                            'メールアドレスを変更する',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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
