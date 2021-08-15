// import 'package:flutter/material.dart';
// import 'package:kakikomi_keijiban/common/components/common_loading_spinner.dart';
// import 'package:kakikomi_keijiban/common/components/post_card/post_card.dart';
// import 'package:kakikomi_keijiban/common/components/common_scroll_bottom_notification_listener.dart';
// import 'package:kakikomi_keijiban/common/constants.dart';
// import 'package:kakikomi_keijiban/presentation/my_replies/my_replies_model.dart';
// import 'package:provider/provider.dart';

// class MyRepliesPage extends StatelessWidget {
//   const MyRepliesPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () {
//         Navigator.of(context).popUntil(
//           ModalRoute.withName('/'),
//         );
//         return Future.value(true);
//       },
//       child: ChangeNotifierProvider<MyRepliesModel>(
//         create: (context) => MyRepliesModel()..init(),
//         child: Scaffold(
//           backgroundColor: kLightPink,
//           appBar: AppBar(
//             toolbarHeight: 50,
//             title: const Text('自分の返信'),
//           ),
//           body: Consumer<MyRepliesModel>(builder: (context, model, child) {
//             final postsWithMyReplies = model.posts;
//             return LoadingSpinner(
//               isModalLoading: model.isModalLoading,
//               child: RefreshIndicator(
//                 onRefresh: () => model.getPostsWithReplies,
//                 child: CommonScrollBottomNotificationListener(
//                   model: model,
//                   child: ListView.builder(
//                     padding: const EdgeInsets.only(top: 30, bottom: 60),
//                     itemBuilder: (BuildContext context, int index) {
//                       final post = postsWithMyReplies[index];
//                       return Column(
//                         children: [
//                           PostCard(
//                             post: post,
//                             indexOfPost: index,
//                             passedModel: model,
//                           ),
//                           post == postsWithMyReplies.last && model.isLoading
//                               ? const CircularProgressIndicator()
//                               : const SizedBox(),
//                         ],
//                       );
//                     },
//                     itemCount: postsWithMyReplies.length,
//                   ),
//                 ),
//               ),
//             );
//           }),
//         ),
//       ),
//     );
//   }
// }
