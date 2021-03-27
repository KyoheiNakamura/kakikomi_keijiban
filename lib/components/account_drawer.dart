import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/home/home_model.dart';
import 'package:kakikomi_keijiban/select_registration_method_page.dart';
import 'package:provider/provider.dart';

class AccountDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeModel>(builder: (context, model, child) {
      return SizedBox(
        width: MediaQuery.of(context).size.width * 0.84,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              model.loggedInUser != null
                  ? DrawerHeader(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Drawer Header',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              model.signOut();
                              Navigator.pop(context);
                            },
                            child: Text(
                              'ログアウト',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
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
                              backgroundColor:
                                  MaterialStateProperty.all(kDarkPink),
                            ),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        SelectRegistrationMethodPage()),
                              );
                              model.getCurrentUser();
                              Navigator.pop(context);
                            },
                          ),
                          SizedBox(height: 16.0),
                          OutlinedButton(
                            child: Text(
                              'ログイン',
                              style: TextStyle(color: kDarkPink),
                            ),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        SelectRegistrationMethodPage()),
                              );
                              model.getCurrentUser();
                              Navigator.pop(context);
                            },
                          )
                        ],
                      ),
                    ),
              Divider(thickness: 1.0),
              ListTile(
                leading: Icon(Icons.description),
                title: Text('投稿一覧'),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.favorite_border),
                title: Text('共感した投稿'),
                onTap: () {},
              ),
              Divider(thickness: 1.0),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                onTap: () {},
              ),
            ],
          ),
        ),
      );
    });
  }
}
