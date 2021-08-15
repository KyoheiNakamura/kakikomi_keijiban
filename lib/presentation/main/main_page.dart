import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kakikomi_keijiban/common/components/common_posts/common_posts_page.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/manager/firestore_manager.dart';
import 'package:kakikomi_keijiban/presentation/add_post/add_post_page.dart';
import 'package:kakikomi_keijiban/presentation/home/home_page.dart';
import 'package:kakikomi_keijiban/presentation/main/main_model.dart';
import 'package:kakikomi_keijiban/presentation/my_page/my_page.dart';
import 'package:kakikomi_keijiban/presentation/notices/notices_page.dart';
import 'package:kakikomi_keijiban/presentation/search/search_page.dart';
import 'package:provider/provider.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const _pageList = [
      // CommonPostsPage(type: CommonPostsType.homePosts),
      HomePage(),
      SearchPage(),
      // AddPostPage(),
      NoticesPage(),
      MyPage(),
    ];
    return WillPopScope(
      onWillPop: () async => false,
      child: ChangeNotifierProvider<HomeModel>(
        create: (context) => HomeModel()..init(context),
        child: GestureDetector(
          onTap: () {
            final currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Consumer<HomeModel>(
            builder: (context, model, child) {
              return Scaffold(
                body: SafeArea(
                  child: _pageList[model.selectedIndex],
                  // Stack(
                  //   children: [
                  //     Column(
                  //       children: [
                  //         const SizedBox(
                  //           height: CustomAppBar.kCustomAppBarHeight,
                  //         ),
                  //         Expanded(
                  //           child: _pageList[model.selectedIndex],
                  //         ),
                  //       ],
                  //     ),
                  //     CustomAppBar(
                  //       page: _pageList[model.selectedIndex],
                  //     ),
                  //   ],
                  // ),
                ),
                bottomNavigationBar: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  selectedLabelStyle:
                      const TextStyle(fontWeight: FontWeight.bold),
                  unselectedLabelStyle:
                      const TextStyle(fontWeight: FontWeight.bold),
                  // selectedItemColor: Colors.black,
                  selectedItemColor: kDarkPink,
                  unselectedItemColor: Colors.black,
                  selectedFontSize: 12,
                  // unselectedFontSize: 10,
                  items: <BottomNavigationBarItem>[
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined),
                      activeIcon: Icon(Icons.home),
                      label: 'ホーム',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.search_outlined),
                      activeIcon: Icon(Icons.search),
                      label: '見つける',
                    ),
                    // const BottomNavigationBarItem(
                    //   icon: Icon(Icons.add_circle_outline_outlined),
                    //   label: '',
                    // ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        model.isNoticeExisting
                            ? Icons.notifications_active_outlined
                            : Icons.notifications_outlined,
                      ),
                      activeIcon: Icon(
                        model.isNoticeExisting
                            ? Icons.notifications_active
                            : Icons.notifications,
                      ),
                      label: 'お知らせ',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.account_circle_outlined),
                      activeIcon: Icon(Icons.account_circle),
                      label: 'マイページ',
                    ),
                  ],
                  currentIndex: model.selectedIndex,
                  onTap: model.onItemTapped,
                ),
                floatingActionButton: FloatingActionButton(
                  shape: const CircleBorder(side: BorderSide(color: kPink)),
                  highlightElevation: 0,
                  splashColor: kDarkPink,
                  backgroundColor: const Color(0xFFFAFAFA),
                  onPressed: () async {
                    await Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddPostPage(),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.create,
                    color: kDarkPink,
                    size: 24,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    required this.page,
    Key? key,
  }) : super(key: key);

  final StatelessWidget page;

  static const double kCustomAppBarHeight = 56;

  @override
  Widget build(BuildContext context) {
    return SearchAppbar();
  }
}

class SearchAppbar extends StatelessWidget {
  const SearchAppbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: CustomAppBar.kCustomAppBarHeight,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextFormField(
        // controller: model.favoriteRecipeTab.textController,
        textInputAction: TextInputAction.done,
        onChanged: (text) async {
          // model.changeFavoriteSearchWords(text);
          // if (text.isNotEmpty) {
          //   model.favoriteRecipeTab.showFilteredRecipe = true;
          //   model.startFavoriteRecipeFiltering();
          //   await model.filterFavoriteRecipe(text);
          // } else {
          //   model.favoriteRecipeTab.showFilteredRecipe = false;
          //   model.endFavoriteRecipeFiltering();
          // }
        },
        maxLines: 1,
        decoration: InputDecoration(
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.zero,
          isDense: true,
          prefixIcon: const Icon(Icons.search),
          // errorText: model.favoriteRecipeTab.errorText == ''
          //     ? null
          //     : model.favoriteRecipeTab.errorText,d
          labelText: 'キーワードで探す',
          suffixIcon:
              // model.favoriteRecipeTab.textController.text.isEmpty
              //     ? SizedBox()
              //     :
              IconButton(
            icon: const Icon(
              Icons.clear,
              size: 18,
            ),
            padding: EdgeInsets.zero,
            splashRadius: 8,
            onPressed: () {
              // model.favoriteRecipeTab
              //     .textController
              //     .clear();
              // model.favoriteRecipeTab
              //     .showFilteredRecipe = false;
              // model.favoriteRecipeTab
              //     .errorText = '';
              // model
              //     .endFavoriteRecipeFiltering();
            },
          ),
          fillColor: kbackGroundGrey,
          filled: true,
        ),
        style: const TextStyle(
          fontSize: 14,
        ),
      ),
    );
  }
}
