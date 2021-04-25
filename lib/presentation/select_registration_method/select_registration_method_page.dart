import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/presentation/select_registration_method/select_registration_method_model.dart';
import 'package:kakikomi_keijiban/presentation/sign_in/sign_in_page.dart';
import 'package:kakikomi_keijiban/presentation/sign_up/sign_up_page.dart';
import 'package:provider/provider.dart';

class SelectRegistrationMethodPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SelectRegistrationMethodModel>(
      create: (context) => SelectRegistrationMethodModel(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          title: Text(
            '会員登録またはログイン',
            style: kAppBarTextStyle,
          ),
        ),
        // Todo めちゃくちゃ簡潔に書けそうなので、後で書き直そう
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, top: 24.0, right: 16.0, bottom: 12.0),
              child: OutlinedButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon(Icons.email_outlined, color: Colors.white),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'メールアドレスで登録',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpPage()),
                  );
                  // Navigator.pop(context);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(kDarkPink),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, top: 12.0, right: 16.0, bottom: 16.0),
              child: OutlinedButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon(Icons.login_outlined, color: kDarkPink),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'アカウントをすでにお持ちの方',
                        style: TextStyle(
                          color: kDarkPink,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignInPage()),
                  );
                  // Navigator.pop(context);
                },
              ),
            ),
            Divider(thickness: 1.0),
            Consumer<SelectRegistrationMethodModel>(
                builder: (context, model, child) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SNSアカウントからログイン',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 16.0),
                    OutlinedButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon(Icons.login_outlined, color: kDarkPink),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              'Googleでログイン',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onPressed: () async {
                        await model
                            .signUpAndSignInWithGoogleAndUpgradeAnonymous();
                        Navigator.of(context).popUntil(
                          ModalRoute.withName('/'),
                        );
                      },
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
