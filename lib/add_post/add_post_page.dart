import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/add_post/add_post_model.dart';
import 'package:provider/provider.dart';

class AddPostPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AddPostModel>(
      create: (context) => AddPostModel(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.account_circle,
              size: 30,
            ),
            onPressed: () {},
          ),
          title: Text(
            '発達障害困りごと掲示板',
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.search,
                size: 30,
              ),
              onPressed: () {},
            ),
          ],
        ),
        body: Consumer<AddPostModel>(
          builder: (context, model, child) {
            return Text('addPostPageだよ');
          },
        ),
      ),
    );
  }
}
