import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/components/common_app_bar.dart';
import 'package:kakikomi_keijiban/common/components/common_posts/common_posts_page.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/manager/firestore_manager.dart';
import 'package:kakikomi_keijiban/presentation/search_result_posts/search_result_posts_page.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBar(title: '検索'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              /// emotion
              SearchGenreCard(
                genreTitle: '気持ち',
                genreIcon: Icons.mood,
                genreList: kEmotionList,
              ),
              SizedBox(height: 24),

              /// category
              SearchGenreCard(
                genreTitle: 'カテゴリー',
                genreIcon: Icons.category_outlined,
                genreList: kCategoryList,
              ),
              SizedBox(height: 24),

              /// position
              SearchGenreCard(
                genreTitle: '立場',
                genreIcon: Icons.group,
                genreList: kPositionList,
              ),
              SizedBox(height: 24),

              /// gender
              SearchGenreCard(
                genreTitle: '性別',
                genreIcon: Icons.lens_outlined,
                genreList: kGenderList,
              ),
              SizedBox(height: 24),

              /// age
              SearchGenreCard(
                genreTitle: '年齢',
                genreIcon: Icons.date_range,
                genreList: kAgeList,
              ),
              SizedBox(height: 24),

              /// area
              SearchGenreCard(
                genreTitle: '地域',
                genreIcon: Icons.place_outlined,
                genreList: kAreaList,
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchGenreCard extends StatelessWidget {
  const SearchGenreCard({
    required this.genreTitle,
    required this.genreIcon,
    required this.genreList,
  });

  final String genreTitle;
  final IconData genreIcon;
  final List<String> genreList;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Icon(genreIcon, color: kGrey),
              ),
              Text(
                genreTitle,
                style: TextStyle(color: Colors.grey[700], fontSize: 16),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Wrap(
              spacing: 8,
              runSpacing: 2,
              // alignment: WrapAlignment.center,
              children: genreList.map<Widget>((value) {
                return value != kPleaseSelect && value != kDoNotSelect
                    ? ActionChip(
                        label: Text(
                          value,
                          style: TextStyle(color: Colors.grey[800]),
                          // style: TextStyle(color: kDarkPink),
                        ),
                        backgroundColor: Colors.grey[200],
                        pressElevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.grey[500]!),
                          // side: BorderSide(color: kPink),
                        ),
                        onPressed: () async {
                          await Navigator.push<void>(
                            context,
                            MaterialPageRoute(
                              // builder: (context) =>
                              //     SearchResultPostsPage(value),
                              builder: (context) => CommonPostsPage(
                                title: '検索結果',
                                type: CommonPostsType.searchResultPosts,
                                searchWord: value,
                              ),
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
//             padding: const EdgeInsets.all(14),
//             child: Icon(
//               Icons.category_outlined,
//               color: kLightGrey,
//             ),
//           ),
//           Text(
//             'カテゴリー',
//             style: TextStyle(
//               color: Colors.grey[700],
//               fontSize: 16,
//             ),
//           ),
//         ],
//       ),
//       Padding(
//         padding: const EdgeInsets.only(
//             left: 16, right: 16, bottom: 14),
//         child: Wrap(
//           spacing: 16,
//           runSpacing: 2,
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
//       EdgeInsets.only(left: 12, top: 8, right: 12),
//   child: Text(
//     '必須',
//     style: TextStyle(
//       fontSize: 12,
//       color: kDarkPink,
//     ),
//   ),
// ),
// SizedBox(
//   height: 32,
// ),
