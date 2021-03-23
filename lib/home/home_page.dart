import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kakikomi_keijiban/home/home_model.dart';
import 'package:kakikomi_keijiban/post.dart';
import 'package:kakikomi_keijiban/reply.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeModel>(
      create: (context) => HomeModel()..getPostsWithReplies(),
      child: Scaffold(
        body: Consumer<HomeModel>(builder: (context, model, child) {
          final List<Post> posts = model.posts;
          return CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                // toolbarHeight: 40,
                elevation: 0,
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(Icons.account_circle),
                  onPressed: () {},
                ),
                title: Text(
                  '発達障害困りごと掲示板',
                  style: TextStyle(
                    fontSize: 17.0,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {},
                  ),
                  // IconButton(
                  //   icon: Icon(Icons.notifications),
                  //   onPressed: () {},
                  // )
                ],
                pinned: true,
                flexibleSpace: Container(
                  // color: Color(0xFFE89AA6),
                  margin:
                      EdgeInsets.only(left: 30, top: 80, right: 30, bottom: 0),
                  child: Text(
                    'ここにこの掲示板の説明を書くやで。ここにこの掲示板の説明を書くやで。ここにこの掲示板の説明を書くやで。ここにこの掲示板の説明を書くやで。ここにこの掲示板の説明を書くやで。ここにこの掲示板の説明を書くやで。ここにこの掲示板の説明を書くやで。ここにこの掲示板の説明を書くやで。ここにこの掲示板の説明を書くやで。ここにこの掲示板の説明を書くやで。ここにこの掲示板の説明を書くやで。ここにこの掲示板の説明を書くやで。ここにこの掲示板の説明を書くやで。',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                expandedHeight: 300,
              ),
              SliverPadding(padding: EdgeInsets.only(bottom: 30.0)),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = posts[index];
                    return PostCard(
                      post: post,
                      index: index,
                    );
                  },
                  childCount: posts.length,
                ),
              ),
              SliverPadding(padding: EdgeInsets.only(bottom: 90.0)),
            ],
          );
        }),
        floatingActionButton: FloatingActionButton.extended(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          highlightElevation: 0,
          splashColor: Color(0xFFDC5A6E),
          backgroundColor: Color(0xFFE89AA6),
          label: Text(
            '投稿する',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          onPressed: () {},
        ),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  PostCard({this.post, this.index});

  final Post post;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.topCenter,
      children: [
        Container(
          padding: EdgeInsets.all(20.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Container(
              color: Color(0xFFFDF3E1),
              padding: EdgeInsets.only(
                  top: 40.0, left: 20.0, right: 20.0, bottom: 30.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      post.title,
                      style: TextStyle(fontSize: 15.0),
                    ),
                  ),
                  Text(
                    '名前/性別/年齢/地域/立場',
                    style: TextStyle(color: Colors.black54),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: Text(post.bodyText),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () {},
                        child: Text(
                          '返信する',
                          style: TextStyle(color: Color(0xFFDC5A6E)),
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          side: BorderSide(color: Color(0xFFE89AA6)),
                        ),
                      ),
                      Text(
                        post.createdAt,
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                  Consumer<HomeModel>(builder: (context, model, child) {
                    final List<Reply> replies = model.replies[index];
                    return Column(
                      children: replies.map((reply) {
                        return ReplyCard(reply);
                      }).toList(),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          width: 40.0,
          height: 40.0,
          child: Image.asset('images/anpanman.png'),
        ),
      ],
    );
  }
}

class ReplyCard extends StatelessWidget {
  ReplyCard(this.reply);

  final Reply reply;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 20.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          color: Colors.white,
          padding:
              EdgeInsets.only(top: 30.0, left: 20.0, right: 20.0, bottom: 20.0),
          child: Column(
            children: [
              Text(
                '名前/性別/年齢/地域/立場',
                style: TextStyle(color: Colors.black54),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Text(reply.text),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  reply.createdAt,
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
