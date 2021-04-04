import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/presentation/search_result_posts/search_result_posts_page.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // return ChangeNotifierProvider<SearchModel>(
    //   create: (context) => SearchModel(),
    //   child:
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '検索',
          style: kAppBarTextStyle,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// emotion
              SearchGenreCard(
                genreTitle: '気持ち',
                genreIcon: Icons.mood,
                genreList: kEmotionList,
              ),
              SizedBox(height: 24.0),

              /// category
              SearchGenreCard(
                genreTitle: 'カテゴリー',
                genreIcon: Icons.category_outlined,
                genreList: kCategoryList,
              ),
              SizedBox(height: 24.0),

              /// position
              SearchGenreCard(
                genreTitle: '立場',
                genreIcon: Icons.group,
                genreList: kPositionList,
              ),
              SizedBox(height: 24.0),

              /// gender
              SearchGenreCard(
                genreTitle: '性別',
                genreIcon: Icons.lens_outlined,
                genreList: kGenderList,
              ),
              SizedBox(height: 24.0),

              /// age
              SearchGenreCard(
                genreTitle: '年齢',
                genreIcon: Icons.date_range,
                genreList: kAgeList,
              ),
              SizedBox(height: 24.0),

              /// area
              SearchGenreCard(
                genreTitle: '地域',
                genreIcon: Icons.place_outlined,
                genreList: kAreaList,
              ),
              SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchGenreCard extends StatelessWidget {
  SearchGenreCard({
    required this.genreTitle,
    required this.genreIcon,
    required this.genreList,
  });

  final String genreTitle;
  final IconData genreIcon;
  final List<String> genreList;

  @override
  Widget build(BuildContext context) {
    // if (genreList.contains(kPleaseSelect)) {
    //   genreList.remove(kPleaseSelect);
    // }
    // if (genreList.contains(kDoNotSelect)) {
    //   genreList.remove(kDoNotSelect);
    // }
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Icon(genreIcon, color: kLightGrey),
              ),
              Text(
                genreTitle,
                style: TextStyle(color: Colors.grey[700], fontSize: 16.0),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 14.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 2.0,
              // alignment: WrapAlignment.center,
              children: genreList.map<Widget>((value) {
                return value != kPleaseSelect && value != kDoNotSelect
                    ? ActionChip(
                        label: Text(
                          value,
                          style: TextStyle(color: kDarkPink),
                        ),
                        backgroundColor: kLightPink,
                        pressElevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: kPink),
                        ),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SearchResultPostsPage(value),
                            ),
                          );
                        },
                      )
                    : Container();
              }).toList(),
            ),
          ),
        ],
      ),
    );

    // return Container(
    //   decoration: BoxDecoration(
    //     border: Border.all(color: Colors.grey[500]!),
    //     borderRadius: BorderRadius.circular(5),
    //   ),
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Row(
    //         children: [
    //           Padding(
    //             padding: const EdgeInsets.all(14.0),
    //             child: Icon(genreIcon, color: kLightGrey),
    //           ),
    //           Text(
    //             genreTitle,
    //             style: TextStyle(color: Colors.grey[700], fontSize: 16.0),
    //           ),
    //         ],
    //       ),
    //       Padding(
    //         padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 14.0),
    //         child: Wrap(
    //           spacing: 8.0,
    //           runSpacing: 2.0,
    //           // alignment: WrapAlignment.center,
    //           children: genreList.map<Widget>((value) {
    //             return ActionChip(
    //               label: Text(
    //                 value,
    //                 style: TextStyle(color: Colors.grey[800]),
    //               ),
    //               backgroundColor: Colors.grey[200],
    //               pressElevation: 0,
    //               shape: RoundedRectangleBorder(
    //                 borderRadius: BorderRadius.circular(20),
    //                 side: BorderSide(color: Colors.grey[500]!),
    //               ),
    //               onPressed: () async {
    //                 await Navigator.push(
    //                   context,
    //                   MaterialPageRoute(
    //                     builder: (context) => SearchResultPostsPage(value),
    //                   ),
    //                 );
    //                 // await homeModel.getPostsWithReplies();
    //               },
    //             );
    //           }).toList(),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}

// class ChoiceChipWidget extends StatelessWidget {
//   ChoiceChipWidget({required this.searchableList, required this.model});
//
//   final List<String> searchableList;
//   final SearchModel model;
//
//   @override
//   Widget build(BuildContext context) {
//     searchableList.map<Widget>((value) {
//       return ChoiceChip(
//         label: Text(value),
//         selected: model.selectedCategory == value,
//         onSelected: (selected) {
//           model.selectedCategory = value;
//           model.reload();
//         },
//       );
//     }).toList();
//   }
// }

// Category チップ一つ選択
// Container(
//   decoration: BoxDecoration(
//     border: Border.all(color: Colors.grey[500]!),
//     borderRadius: BorderRadius.circular(5),
//   ),
//   child: Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Row(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(14.0),
//             child: Icon(
//               Icons.category_outlined,
//               color: kLightGrey,
//             ),
//           ),
//           Text(
//             'カテゴリー',
//             style: TextStyle(
//               color: Colors.grey[700],
//               fontSize: 16.0,
//             ),
//           ),
//         ],
//       ),
//       Padding(
//         padding: EdgeInsets.only(
//             left: 16.0, right: 16.0, bottom: 14.0),
//         child: Wrap(
//           spacing: 16.0,
//           runSpacing: 2.0,
//           // alignment: WrapAlignment.center,
//           children: kCategoryList.map<Widget>((item) {
//             return ChoiceChip(
//               label: Text(item),
//               selected: model.selectedCategory == item,
//               onSelected: (selected) {
//                 model.selectedCategory = item;
//                 model.reload();
//               },
//             );
//           }).toList(),
//         ),
//       ),
//     ],
//   ),
// ),
// Padding(
//   padding:
//       EdgeInsets.only(left: 12.0, top: 8.0, right: 12.0),
//   child: Text(
//     '必須',
//     style: TextStyle(
//       fontSize: 12.0,
//       color: kDarkPink,
//     ),
//   ),
// ),
// SizedBox(
//   height: 32.0,
// ),
