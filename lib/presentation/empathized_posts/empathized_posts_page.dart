import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kakikomi_keijiban/common/components/common_app_bar.dart';
import 'package:kakikomi_keijiban/common/components/common_loading_spinner.dart';
import 'package:kakikomi_keijiban/common/components/common_scroll_bottom_notification_listener.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/presentation/empathized_posts/empathized_posts_model.dart';
import 'package:kakikomi_keijiban/presentation/notices/notices_model.dart';
import 'package:kakikomi_keijiban/presentation/post_detail/post_detail_page.dart';
import 'package:provider/provider.dart';

/// ワカル画面
class EmpathizedPostsPage extends StatelessWidget {
  const EmpathizedPostsPage();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EmpathizedPostsModel>(
      create: (context) => EmpathizedPostsModel()..init(),
      child: Scaffold(
        appBar: commonAppBar(title: 'ワカル'),
        body: Consumer<EmpathizedPostsModel>(
          builder: (context, model, child) {
            final empathizedPosts = model.empathizedPosts;
            return empathizedPosts.isNotEmpty
                ? LoadingSpinner(
                    isModalLoading: model.isModalLoading,
                    child: RefreshIndicator(
                      onRefresh: () => model.getEmpathizedPosts(),
                      child: CommonScrollBottomNotificationListener(
                        model: model,
                        child: ListView.separated(
                          // physics: const BouncingScrollPhysics(),
                          itemCount: empathizedPosts.length + 1,
                          itemBuilder: (BuildContext context, int index) {
                            return index != empathizedPosts.length
                                ? GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () async {
                                      await Navigator.push<void>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PostDetailPage(
                                              empathizedPosts[index]),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 8, 16, 8),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          /// emotion
                                          empathizedPosts[index]
                                                  .emotion
                                                  .isNotEmpty
                                              ? Image.asset(
                                                  kEmotionIcons[
                                                      empathizedPosts[index]
                                                          .emotion]!,
                                                  width: 50,
                                                  height: 50,
                                                )
                                              : const Padding(
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  child: const FlutterLogo(
                                                      size: 42),
                                                ),
                                          const SizedBox(width: 16),
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: 8),

                                                /// nickname
                                                Column(
                                                  children: [
                                                    Text(
                                                      empathizedPosts[index]
                                                              .nickname
                                                              .isNotEmpty
                                                          ? empathizedPosts[
                                                                  index]
                                                              .nickname
                                                          : '',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                      maxLines: 2,
                                                    ),
                                                    const SizedBox(height: 8),
                                                  ],
                                                ),

                                                // /// title
                                                // Column(
                                                //   children: [
                                                //     Text(
                                                //       empathizedPosts[index]
                                                //               .title
                                                //               .isNotEmpty
                                                //           ? empathizedPosts[
                                                //                   index]
                                                //               .title
                                                //           : '',
                                                //       style: const TextStyle(
                                                //         fontWeight:
                                                //             FontWeight.bold,
                                                //         fontSize: 14,
                                                //       ),
                                                //       maxLines: 2,
                                                //     ),
                                                //     const SizedBox(height: 8),
                                                //   ],
                                                // ),

                                                /// body
                                                Text(
                                                  empathizedPosts[index].body,
                                                  style: const TextStyle(
                                                    color: kDarkGrey,
                                                  ),
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  // softWrap: true,
                                                ),
                                                const SizedBox(height: 4),

                                                /// createdAt
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: Text(
                                                    empathizedPosts[index]
                                                        .createdAt,
                                                    textAlign: TextAlign.end,
                                                    style: const TextStyle(
                                                      color: kLightGrey,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : const SizedBox();
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(
                            thickness: .5,
                          ),
                        ),
                      ),
                    ),
                  )
                : const Center(
                    child: Text('まだワカルがありません'),
                  );
          },
        ),
      ),
    );
  }
}
