import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/components/common_loading_spinner.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/mixin/show_exception_dialog_mixin.dart';
import 'package:kakikomi_keijiban/presentation/sign_up/sign_up_model.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatelessWidget with ShowExceptionDialogMixin {
  SignUpPage({Key? key}) : super(key: key);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SignUpModel>(
      create: (context) => SignUpModel(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          title: const Text('会員登録'),
        ),
        body: Consumer<SignUpModel>(
          builder: (context, model, child) {
            return LoadingSpinner(
              isModalLoading: model.isModalLoading,
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 48, horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        /// nickname
                        TextFormField(
                          controller: model.nicknameController,
                          validator: model.validateNicknameCallback,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            // prefixIcon: Icon(Icons.password),
                            labelText: 'ニックネーム（10文字以内）',
                          ),
                        ),
                        const SizedBox(height: 32),

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
                        const SizedBox(height: 32),

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
                        const SizedBox(height: 48),

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
                            '登録する',
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
