import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:kakikomi_keijiban/components/post_card.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/presentation/add_post/add_post_page.dart';
import 'package:kakikomi_keijiban/presentation/bookmarked_posts/bookmarked_posts_model.dart';
import 'package:kakikomi_keijiban/presentation/home/home_model.dart';
import 'package:provider/provider.dart';

class BookmarkedPostsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // return ChangeNotifierProvider<BookmarkedPostsModel>(
    //   create: (context) => BookmarkedPostsModel()..getBookmarkedPosts(),
    //   child: ChangeNotifierProvider<HomeModel>(
    //     create: (context) => HomeModel()
    //       ..listenAuthStateChanges()
    //       ..getPostsWithReplies(),
    return ChangeNotifierProvider<HomeModel>(
      create: (context) => HomeModel()..getBookmarkedPosts(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'ブックマーク',
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Consumer<HomeModel>(builder: (context, model, child) {
          final List<Post> bookmarkedPosts = model.bookmarkedPosts;
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light
                .copyWith(statusBarColor: Theme.of(context).primaryColorDark),
            child: SafeArea(
              child: Container(
                color: kLightPink,
                child: RefreshIndicator(
                  onRefresh: () => model.getBookmarkedPosts(),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: ListView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        final post = bookmarkedPosts[index];
                        return PostCardByCard(post);
                      },
                      itemCount: bookmarkedPosts.length,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
        floatingActionButton:
            Consumer<HomeModel>(builder: (context, model, child) {
          return FloatingActionButton.extended(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            // elevation: 0,
            highlightElevation: 0,
            splashColor: kDarkPink,
            backgroundColor: Color(0xFFFCF0F5),
            label: Row(
              children: [
                Icon(
                  Icons.create,
                  color: kDarkPink,
                ),
                SizedBox(width: 8),
                Text(
                  '投稿',
                  style: TextStyle(
                    color: kDarkPink,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddPostPage()),
              );
              await model.getPostsWithReplies();
            },
          );
        }),
      ),
    );
  }
}
// child: Scaffold(
//       appBar: AppBar(
//         toolbarHeight: 50,
//         elevation: 0,
//         centerTitle: true,
//         title: Text(
//           'ブックマーク',
//           style: TextStyle(
//             fontSize: 17.0,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body:
//           Consumer<BookMarkedPostsModel>(builder: (context, model, child) {
//         final List<Post> bookmarkedPosts = model.bookmarkedPosts;
//         return AnnotatedRegion<SystemUiOverlayStyle>(
//           value: SystemUiOverlayStyle.light
//               .copyWith(statusBarColor: Theme.of(context).primaryColorDark),
//           child: SafeArea(
//             child: Container(
//               color: kLightPink,
//               child: RefreshIndicator(
//                 onRefresh: () => model.getBookmarkedPosts(),
//                 child: Padding(
//                   padding: const EdgeInsets.only(top: 30.0),
//                   child: ListView.builder(
//                     itemBuilder: (BuildContext context, int index) {
//                       final post = bookmarkedPosts[index];
//                       return PostCardByCard(post);
//                     },
//                     itemCount: bookmarkedPosts.length,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       }),
//       floatingActionButton:
//           Consumer<BookMarkedPostsModel>(builder: (context, model, child) {
//         return FloatingActionButton.extended(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           // elevation: 0,
//           highlightElevation: 0,
//           splashColor: kDarkPink,
//           backgroundColor: Color(0xFFFCF0F5),
//           label: Row(
//             children: [
//               Icon(
//                 Icons.create,
//                 color: kDarkPink,
//               ),
//               SizedBox(width: 8),
//               Text(
//                 '投稿する',
//                 style: TextStyle(
//                   color: kDarkPink,
//                   fontSize: 16,
//                 ),
//               ),
//             ],
//           ),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => AddPostPage()),
//             );
//           },
//         );
//       }),
//     ),

// MultiProvider(
// providers: [
// ChangeNotifierProvider<BookMarkedPostsModel>(
// create: (context) => BookMarkedPostsModel()..getBookmarkedPosts(),
// ),
// ChangeNotifierProvider<HomeModel>(
// create: (context) => HomeModel()..getPostsWithReplies(),
// ),
// ],
// )
