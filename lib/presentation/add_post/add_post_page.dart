import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/user_profile.dart';
import 'package:kakikomi_keijiban/presentation/add_post/add_post_model.dart';
import 'package:provider/provider.dart';

class AddPostPage extends StatelessWidget {
  AddPostPage({this.userProfile, this.existingPost});

  final UserProfile? userProfile;
  final Post? existingPost;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final bool isUserProfileNotAnonymous = userProfile != null;
    final bool isPostExisting = existingPost != null;
    return ChangeNotifierProvider<AddPostModel>(
      create: (context) => AddPostModel(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          elevation: 0,
          centerTitle: true,
          title: Text(
            isPostExisting ? '編集' : '新規投稿',
            style: kAppBarTextStyle,
          ),
        ),
        body: Consumer<AddPostModel>(
          builder: (context, model, child) {
            if (isPostExisting && model.selectedCategories.isEmpty) {
              model.selectedCategories.addAll(existingPost!.categories);
            }
            return GestureDetector(
              onTap: () {
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
              },
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 48.0,
                      horizontal: 24.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        /// title
                        Padding(
                          padding: const EdgeInsets.only(bottom: 32.0),
                          child: TextFormField(
                            initialValue: isPostExisting
                                ? model.titleValue = existingPost!.title
                                : null,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'タイトルを入力してください';
                              } else if (value.length > 50) {
                                return '50字以内でご記入ください';
                              }
                              return null;
                            },
                            onChanged: (newValue) {
                              model.titleValue = newValue;
                            },
                            decoration: kTitleTextFormFieldDecoration,
                          ),
                        ),

                        /// content
                        Padding(
                          padding: const EdgeInsets.only(bottom: 32.0),
                          child: TextFormField(
                            initialValue: isPostExisting
                                ? model.bodyValue = existingPost!.body
                                : null,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '投稿の内容を入力してください';
                              } else if (value.length > 1000) {
                                return '1000字以内でご記入ください';
                              }
                              return null;
                            },
                            // maxLength: 1000,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            onChanged: (newValue) {
                              model.bodyValue = newValue;
                            },
                            decoration: kContentTextFormFieldDecoration,
                          ),
                        ),

                        /// nickname
                        Padding(
                          padding: const EdgeInsets.only(bottom: 32.0),
                          child: TextFormField(
                            initialValue: isPostExisting
                                ? model.nicknameValue = existingPost!.nickname
                                : isUserProfileNotAnonymous
                                    ? model.nicknameValue =
                                        userProfile!.nickname
                                    : null,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'ニックネームを入力してください';
                              } else if (value.length > 10) {
                                return '10字以内でご記入ください';
                              }
                              return null;
                            },
                            onChanged: (newValue) {
                              model.nicknameValue = newValue;
                            },
                            decoration: kNicknameTextFormFieldDecoration,
                          ),
                        ),

                        /// emotion
                        Padding(
                          padding: const EdgeInsets.only(bottom: 32.0),
                          child: DropdownButtonFormField(
                            validator: (value) {
                              if (value == kPleaseSelect) {
                                return 'あなたの気持ちを選択してください';
                              }
                              return null;
                            },
                            value: isPostExisting
                                ? model.emotionDropdownValue =
                                    existingPost!.emotion
                                : model.emotionDropdownValue,
                            icon: Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 1,
                            style: kDropdownButtonFormFieldTextStyle,
                            decoration:
                                kEmotionDropdownButtonFormFieldDecoration,
                            onChanged: (String? selectedValue) {
                              model.emotionDropdownValue = selectedValue!;
                            },
                            items: kEmotionList.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),

                        /// position
                        // Todo positionを複数選択できるようにしよう
                        Padding(
                          padding: const EdgeInsets.only(bottom: 32.0),
                          child: DropdownButtonFormField(
                            validator: (value) {
                              if (value == kPleaseSelect) {
                                return 'あなたの立場を選択してください';
                              }
                              return null;
                            },
                            value: isPostExisting &&
                                    existingPost!.position.isNotEmpty
                                ? model.positionDropdownValue =
                                    existingPost!.position
                                : isUserProfileNotAnonymous
                                    ? model.positionDropdownValue =
                                        userProfile!.position
                                    : model.positionDropdownValue,
                            icon: Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 1,
                            style: kDropdownButtonFormFieldTextStyle,
                            decoration:
                                kPositionDropdownButtonFormFieldDecoration,
                            onChanged: (String? selectedValue) {
                              model.positionDropdownValue = selectedValue!;
                              print(model.positionDropdownValue);
                            },
                            items: kPositionList.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),

                        /// category チップ複数選択
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: model.isCategoriesValid
                                  ? Colors.grey[500]!
                                  : kDarkPink,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(14.0),
                                    child: Icon(
                                      Icons.category_outlined,
                                      color: model.isCategoriesValid
                                          ? kLightGrey
                                          : kDarkPink,
                                    ),
                                  ),
                                  Text(
                                    'カテゴリー',
                                    style: TextStyle(
                                      color: model.isCategoriesValid
                                          ? Colors.grey[700]
                                          : kDarkPink,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 16.0, right: 16.0, bottom: 14.0),
                                child: Wrap(
                                  spacing: 8.0,
                                  runSpacing: 2.0,
                                  // alignment: WrapAlignment.center,
                                  children: kCategoryList.map<Widget>((item) {
                                    return FilterChipWidget(
                                      chipName: item,
                                      model: model,
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 10.0, top: 8.0, right: 10.0, bottom: 32.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                model.isCategoriesValid
                                    ? '必須'
                                    : 'カテゴリーを選択してください',
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: kDarkPink,
                                ),
                              ),
                              Text(
                                '1つ以上選択してください',
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: kLightGrey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// gender
                        Padding(
                          padding: const EdgeInsets.only(bottom: 32.0),
                          child: DropdownButtonFormField(
                            value: isPostExisting &&
                                    existingPost!.gender.isNotEmpty
                                ? model.genderDropdownValue =
                                    existingPost!.gender
                                : isUserProfileNotAnonymous
                                    ? model.genderDropdownValue =
                                        userProfile!.gender
                                    : model.genderDropdownValue,
                            icon: Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 1,
                            style: kDropdownButtonFormFieldTextStyle,
                            decoration:
                                kGenderDropdownButtonFormFieldDecoration,
                            onChanged: (String? selectedValue) {
                              model.genderDropdownValue = selectedValue!;
                            },
                            items: kGenderList.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),

                        /// age
                        Padding(
                          padding: const EdgeInsets.only(bottom: 32.0),
                          child: DropdownButtonFormField(
                            value: isPostExisting &&
                                    existingPost!.age.isNotEmpty
                                ? model.ageDropdownValue = existingPost!.age
                                : isUserProfileNotAnonymous
                                    ? model.ageDropdownValue = userProfile!.age
                                    : model.ageDropdownValue,
                            icon: Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 1,
                            style: kDropdownButtonFormFieldTextStyle,
                            decoration: kAgeDropdownButtonFormFieldDecoration,
                            onChanged: (String? selectedValue) {
                              model.ageDropdownValue = selectedValue!;
                            },
                            items: kAgeList.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),

                        /// area
                        Padding(
                          padding: const EdgeInsets.only(bottom: 48.0),
                          child: DropdownButtonFormField(
                            value: isPostExisting &&
                                    existingPost!.area.isNotEmpty
                                ? model.areaDropdownValue = existingPost!.area
                                : isUserProfileNotAnonymous
                                    ? model.areaDropdownValue =
                                        userProfile!.area
                                    : model.areaDropdownValue,
                            icon: Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 1,
                            style: kDropdownButtonFormFieldTextStyle,
                            decoration: kAreaDropdownButtonFormFieldDecoration,
                            onChanged: (String? selectedValue) {
                              model.areaDropdownValue = selectedValue!;
                            },
                            items: kAreaList.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),

                        /// 投稿送信ボタン
                        OutlinedButton(
                          onPressed: () async {
                            if (model.validateSelectedCategories() &&
                                _formKey.currentState!.validate()) {
                              isPostExisting
                                  ? await model.updatePost(existingPost!)
                                  : await model.addPost();
                              Navigator.pop(context);
                              // Navigator.of(context).popUntil(
                              //   ModalRoute.withName('/'),
                              // );
                            }
                          },
                          child: Text(
                            isPostExisting ? '更新する' : '投稿する',
                            style: TextStyle(
                              color: kDarkPink,
                              fontSize: 16,
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            side: BorderSide(color: kDarkPink),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
//
// initialValue: isPostExisting
// ? model.nicknameValue = existingPost!.nickname
//     : null,

class FilterChipWidget extends StatelessWidget {
  FilterChipWidget({required this.chipName, required this.model});

  final String chipName;
  final AddPostModel model;

  @override
  Widget build(BuildContext context) {
    bool isSelected = model.selectedCategories.contains(chipName);
    return FilterChip(
      label: Text(
        chipName,
        style: TextStyle(
          color: isSelected ? kDarkPink : Colors.grey[800],
        ),
      ),
      selected: isSelected == true,
      onSelected: (_) {
        isSelected
            ? model.selectedCategories.remove(chipName)
            : model.selectedCategories.add(chipName);
        model.reload();
        print(model.selectedCategories);
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? kPink : Colors.grey[500]!),
      ),
      backgroundColor: Colors.grey[200],
      selectedColor: kLightPink,
      selectedShadowColor: kDarkPink,
      showCheckmark: false,
      pressElevation: 0,
    );
  }
}

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
