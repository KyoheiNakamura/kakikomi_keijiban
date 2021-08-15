import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kakikomi_keijiban/common/components/common_loading_spinner.dart';
import 'package:kakikomi_keijiban/common/components/common_posts/common_posts_page.dart';
import 'package:kakikomi_keijiban/common/components/common_scroll_bottom_notification_listener.dart';
import 'package:kakikomi_keijiban/common/components/post_card/post_card.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/manager/firestore_manager.dart';
import 'package:kakikomi_keijiban/presentation/empathized_posts/empathized_posts_page.dart';
import 'package:kakikomi_keijiban/presentation/home/home_model.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      vsync: this,
      length: _types.length,
    );
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _tabs = List.generate(
      _types.length,
      (index) {
        return Tab(
          // child: AnimatedBuilder(
          //   animation: _tabController,
          //   builder: (_, __) {
          //     final value = _tabController.animation?.value;
          //     return Text(
          //       homePageName(_types[index]),
          //       style: TextStyle(
          //         color: kDarkGrey,
          //         fontSize: value == 1 ? 20 : 16,
          //         fontWeight: value == 1 ? FontWeight.bold : null,
          //       ),
          //     );
          //   },
          child: Text(
            homePageName(_types[index]),
            style: TextStyle(
              color: kDarkGrey,
              fontSize: _tabController.index == index ? 24 : 16,
              fontWeight:
                  _tabController.index == index ? FontWeight.bold : null,
            ),
          ),
          // ),
        );
      },
    );
    return WillPopScope(
      onWillPop: () async => false,
      child: ChangeNotifierProvider<HomePageModel>(
        create: (context) => HomePageModel()..init(context),
        child: Scaffold(
          body: Consumer<HomePageModel>(
            builder: (context, model, child) {
              return SafeArea(
                child: Stack(
                  children: [
                    /// 新着投稿・ワカルした投稿（ワカル人気順とかでもいいかも）・ブックマークのページビュー
                    Column(
                      children: [
                        const SizedBox(
                          // height: HomePageAppBar.kHomePageAppBarHeight,
                          height: 40,
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            physics: const BouncingScrollPhysics(),
                            children: List.generate(
                              _types.length,
                              (index) {
                                return HomePageContent(
                                  type: homePageTypeValue(index),
                                  key: PageStorageKey<int>(index),
                                );

                                // return homePage(
                                //   type: homePageTypeValue(index),
                                //   key: PageStorageKey<int>(index),
                                // );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    /// TabBar
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: SizedBox(
                        height: 40,
                        child: TabBar(
                          controller: _tabController,
                          tabs: _tabs,
                          isScrollable: true,
                          indicatorColor: Colors.transparent,
                          labelPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          onTap: (index) async {
                            final type = _types[index];
                            final commonPostsType =
                                convertHomePageTypeToCommonPostsType(type);
                            try {
                              await model.reloadTab(
                                context,
                                type: commonPostsType,
                              );
                            } on Exception catch (_) {
                              // エラーが出ても何もしない
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

//   /// [AnimatedBuilder]でラップすることにより、タブインジケータの位置に応じて[child]のopacityを変化させます。
//   /// [index]は生成する[Tab]のインデックスです
//   Widget _buildAnimatedWidget(Widget child, int index) {
//     return AnimatedBuilder(
//       animation: _tabController,
//       builder: (_, __) {
//         return Opacity(
//           opacity:
//               _calculateOpacity(index, _tabController.animation?.value ?? 0),
//           child: child,
//         );
//       },
//     );
//   }

//   /// 計算対象の[Tab]の[index]と、タブインジケータのスクロール位置を示す[value]から、[Tab]内のWidgetのOpacityを算出します。
//   double _calculateOpacity(int index, double value) {
//     if (index - 1 <= value && value <= index + 1) {
//       // 選択状態および隣の[Tab]にフォーカスが当たっている状態
//       final abs = (index - value).abs();
//       // quiver/iterablesと衝突するため、`math`を付与
//       return math.max(math.min(1.0 - abs, 1), .5);
//     } else {
//       // 非選択状態
//       return 0.5;
//     }
//   }
}

const _types = HomePageType.values;

enum HomePageType {
  newPostsPage,
  empathizedPostsPage,
  bookmarkedPostsPage,
}

class HomePageContent extends StatelessWidget {
  const HomePageContent({
    required this.type,
    Key? key,
  }) : super(key: key);

  final HomePageType type;

  @override
  Widget build(BuildContext context) {
    final commonPostsType = convertHomePageTypeToCommonPostsType(type);
    return Consumer<HomePageModel>(
      builder: (context, model, child) {
        final posts = model.posts(commonPostsType);
        return posts.isNotEmpty
            ? RefreshIndicator(
                onRefresh: () => model.getPosts(type: commonPostsType),
                child: CommonScrollBottomNotificationListener(
                  model: model,
                  type: commonPostsType,
                  child: ListView.builder(                  
                    key: key,
                    controller: model.getScrollController(commonPostsType),
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 32),
                    itemBuilder: (BuildContext context, int index) {
                      final post = posts[index];
                      return Column(
                        children: [
                          if (post == posts.first) const SizedBox(height: 16),
                          PostCard(
                            post: post,
                            indexOfPost: index,
                            passedModel: model,
                          ),
                          if (post == posts.last &&
                              model.isLoading(commonPostsType))
                            const CircularProgressIndicator(),
                        ],
                      );
                    },
                    itemCount: posts.length,
                  ),
                ),
              )
            : const Center(
                child: CircularProgressIndicator(),
              );
        // const Center(
        //     child: Text('投稿はありません'),
        //   );
      },
    );
  }
}

// StatelessWidget homePage({
//   required HomePageType type,
//   required PageStorageKey key,
// }) {
//   final commonPostsType = convertHomePageTypeToCommonPostsType(type);
//   return Consumer<HomePageModel>(
//     builder: (context, model, child) {
//       final posts = model.posts(commonPostsType);
//       return posts.isNotEmpty
//           ? RefreshIndicator(
//               onRefresh: () {
//                 switch (type) {
//                   case HomePageType.newPostsPage:
//                     return model.getPosts(type: CommonPostsType.newPosts);
//                   case HomePageType.bookmarkedPostsPage:
//                     return model.getPosts(
//                         type: CommonPostsType.empathizedPosts);
//                   case HomePageType.empathizedPostsPage:
//                     return model.getPosts(
//                         type: CommonPostsType.bookmarkedPosts);
//                 }
//               },
//               child: CommonScrollBottomNotificationListener(
//                 model: model,
//                 type: commonPostsType,
//                 child: ListView.builder(
//                   key: key,
//                   padding: const EdgeInsets.only(bottom: 32),
//                   itemBuilder: (BuildContext context, int index) {
//                     final post = posts[index];
//                     return Column(
//                       children: [
//                         PostCard(
//                           post: post,
//                           indexOfPost: index,
//                           passedModel: model,
//                         ),
//                         post == posts.last && model.isLoading(commonPostsType)
//                             ? const CircularProgressIndicator()
//                             : const SizedBox(),
//                       ],
//                     );
//                   },
//                   itemCount: posts.length,
//                 ),
//               ),
//             )
//           : const Center(
//               child: CircularProgressIndicator(),
//             );
//       // const Center(
//       //     child: Text('投稿はありません'),
//       //   );
//     },
//   );
// }

CommonPostsType convertHomePageTypeToCommonPostsType(HomePageType type) {
  switch (type) {
    case HomePageType.newPostsPage:
      return CommonPostsType.newPosts;
    case HomePageType.empathizedPostsPage:
      return CommonPostsType.empathizedPosts;
    case HomePageType.bookmarkedPostsPage:
      return CommonPostsType.bookmarkedPosts;
  }
}

String homePageName(HomePageType type) {
  switch (type) {
    case HomePageType.newPostsPage:
      return '新着';
    case HomePageType.empathizedPostsPage:
      return 'ワカル';
    case HomePageType.bookmarkedPostsPage:
      return 'ブックマーク';
  }
}

HomePageType homePageTypeValue(int index) {
  switch (index) {
    case 0:
      return HomePageType.values[0];
    case 1:
      return HomePageType.values[1];
    case 2:
      return HomePageType.values[2];
    default:
      return HomePageType.values[0];
  }
}

// class HomePageAppBar extends StatelessWidget {
//   const HomePageAppBar({
//     required this.currentPage,
//     Key? key,
//   }) : super(key: key);

//   final int currentPage;

//   static const double kHomePageAppBarHeight = 48;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: kbackGroundGrey,
//       height: kHomePageAppBarHeight,
//       padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
//       child: Row(
//         children: List.generate(_types.length, (index) {
//           return Padding(
//             padding: EdgeInsets.only(
//               left: index == 0 ? 8 : 0,
//               right: 24,
//             ),
//             child: Text(
//               homePageName(_types[index]),
//               style: TextStyle(
//                 color: kDarkGrey,
//                 fontSize: currentPage == index ? 20 : 16,
//                 fontWeight: currentPage == index ? FontWeight.bold : null,
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }
