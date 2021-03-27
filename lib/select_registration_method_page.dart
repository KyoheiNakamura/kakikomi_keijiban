import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/sign_up//sign_up_page.dart';

class SelectRegistrationMethodPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '会員登録またはログイン',
          style: TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.bold,
          ),
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
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
                Navigator.pop(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.email_outlined, color: Colors.white),
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
                  Icon(Icons.login_outlined, color: kDarkPink),
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
              onPressed: () {},
            ),
          ),
          Divider(thickness: 1.0),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'SNSアカウントからログイン',
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }
}
