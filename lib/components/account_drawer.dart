import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/home/home_model.dart';
import 'package:kakikomi_keijiban/select_registration_method_page.dart';
import 'package:kakikomi_keijiban/sign_in/sign_in_page.dart';
import 'package:provider/provider.dart';

class AccountDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeModel>(builder: (context, model, child) {
      final bool isUserLoggedIn = model.loggedInUser != null &&
          model.loggedInUser!.isAnonymous == false;
      return SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ChangingDrawerHeader(isUserLoggedIn),
              Divider(thickness: 1.0),
              ListTile(
                leading: Icon(Icons.description),
                title: Text('投稿一覧'),
                onTap: () async {
                  isUserLoggedIn
                      ? print('後で実装するよ！')
                      : await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SelectRegistrationMethodPage()),
                        );
                  // model.getCurrentUser();
                  // Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.favorite_border),
                title: Text('共感した投稿'),
                onTap: () async {
                  isUserLoggedIn
                      ? print('後で実装するよ！')
                      : await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SelectRegistrationMethodPage()),
                        );
                  // model.getCurrentUser();
                  // Navigator.pop(context);
                },
              ),
              Divider(thickness: 1.0),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('設定'),
                onTap: () async {
                  isUserLoggedIn
                      ? print('後で実装するよ！')
                      : await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SelectRegistrationMethodPage()),
                        );
                  // model.getCurrentUser();
                  // Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      );
    });
  }
}

class ChangingDrawerHeader extends StatelessWidget {
  ChangingDrawerHeader(this.isUserLoggedIn);
  final bool isUserLoggedIn;

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeModel>(builder: (context, model, child) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: isUserLoggedIn
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    model.loggedInUser!.uid,
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    (model.loggedInUser!.isAnonymous == false
                        ? model.loggedInUser!.email
                        : '')!,
                    style: TextStyle(fontSize: 20.0),
                  ),
                  SizedBox(height: 24.0),
                  TextButton(
                    onPressed: () {
                      model.signOut();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'ログアウト',
                    ),
                  )
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 16.0, bottom: 24.0),
                    child: Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () {},
                          icon: Icon(Icons.help_outline),
                          color: kDarkPink,
                        ),
                        SizedBox(width: 16.0),
                        Flexible(
                          child: Text(
                            '全ての機能をご利用いただくには新規会員登録もしくはログインが必要です。',
                            style: TextStyle(
                              fontSize: 13.0,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  OutlinedButton(
                    child: Text(
                      '会員登録',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(kDarkPink),
                    ),
                    onPressed: () async {
                      // Navigator.pop(context);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            // Todo scaffoldのcontextを持ってきたい。keyについて調べよう。
                            builder: (context) =>
                                SelectRegistrationMethodPage()),
                      );
                      // model.getCurrentUser();
                      // Navigator.pop(context);
                    },
                  ),
                  SizedBox(height: 16.0),
                  OutlinedButton(
                    child: Text(
                      'ログイン',
                      style: TextStyle(color: kDarkPink),
                    ),
                    onPressed: () async {
                      // Navigator.pop(context);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignInPage()),
                      );
                      // model.getCurrentUser();
                      // Navigator.pop(context);
                    },
                  )
                ],
              ),
      );
    });
  }
}
