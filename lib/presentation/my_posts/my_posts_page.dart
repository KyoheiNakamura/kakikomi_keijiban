// import 'package:flutter/material.dart';
// import 'package:kakikomi_keijiban/common/components/common_app_bar.dart';
// import 'package:kakikomi_keijiban/common/components/common_loading_spinner.dart';
// import 'package:kakikomi_keijiban/common/components/post_card/post_card.dart';
// import 'package:kakikomi_keijiban/common/components/common_scroll_bottom_notification_listener.dart';
// import 'package:kakikomi_keijiban/common/constants.dart';
// import 'package:kakikomi_keijiban/presentation/my_posts/my_posts_model.dart';
// import 'package:provider/provider.dart';

// class MyPostsPage extends StatelessWidget {
//   const MyPostsPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () {
//         Navigator.of(context).popUntil(
//           ModalRoute.withName('/'),
//         );
//         return Future.value(true);
//       },
//       child: ChangeNotifierProvider<MyPostsModel>(
//         create: (context) => MyPostsModel()..init(),
//         child: Scaffold(
//           backgroundColor: kLightPink,
//           appBar: commonAppBar(title: '自分の投稿'),
//           body: Consumer<MyPostsModel>(
//             builder: (context, model, child) {
//               final myPosts = model.posts;
//               return LoadingSpinner(
//                 isModalLoading: model.isModalLoading,
//                 child: RefreshIndicator(
//                   onRefresh: () => model.getPostsWithReplies,
//                   child: CommonScrollBottomNotificationListener(
//                     model: model,
//                     child: ListView.builder(
//                       padding: const EdgeInsets.only(top: 30, bottom: 60),
//                       itemBuilder: (BuildContext context, int index) {
//                         final post = myPosts[index];
//                         return Column(
//                           children: [
//                             PostCard(
//                               post: post,
//                               indexOfPost: index,
//                               passedModel: model,
//                             ),
//                             post == myPosts.last && model.isLoading
//                                 ? const CircularProgressIndicator()
//                                 : const SizedBox(),
//                           ],
//                         );
//                       },
//                       itemCount: myPosts.length,
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
