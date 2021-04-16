import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/app_model.dart';
import 'package:kakikomi_keijiban/common/components/loading_spinner.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/enum.dart';
import 'package:kakikomi_keijiban/common/mixin/keyboard_actions_config_done_mixin.dart';
import 'package:kakikomi_keijiban/common/mixin/show_confirm_dialog_mixin.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/user_profile.dart';
import 'package:kakikomi_keijiban/presentation/drafts/drafts_model.dart';
import 'package:kakikomi_keijiban/presentation/update_post/update_post_model.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:provider/provider.dart';

class UpdatePostPage extends StatelessWidget
    with ShowConfirmDialogMixin, KeyboardActionsConfigDoneMixin {
  UpdatePostPage({required this.existingPost, required this.passedModel});

  final Post existingPost;
  final passedModel;
  final _formKey = GlobalKey<FormState>();
  final FocusNode _focusNodeContent = FocusNode();

  @override
  Widget build(BuildContext context) {
    final UserProfile? userProfile = context.read<AppModel>().userProfile;
    final bool isUserProfileExisting = userProfile != null;
    return WillPopScope(
      onWillPop: () {
        showConfirmDialog(context);
        return Future.value(true);
      },
      child: ChangeNotifierProvider<UpdatePostModel>(
        create: (context) => UpdatePostModel(),
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 50,
            elevation: 0,
            centerTitle: true,
            title: Text(
              '編集',
              style: kAppBarTextStyle,
            ),
          ),
          body: Consumer<UpdatePostModel>(
            builder: (context, model, child) {
              if (model.selectedCategories.isEmpty) {
                model.selectedCategories.addAll(existingPost.categories);
              }
              return LoadingSpinner(
                inAsyncCall: model.isLoading,
                child: KeyboardActions(
                  config: buildConfig(context, _focusNodeContent),
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
                                initialValue: model.titleValue =
                                    existingPost.title,
                                validator: model.validateTitleCallback,
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
                                focusNode: _focusNodeContent,
                                initialValue: model.bodyValue =
                                    existingPost.body,
                                validator: model.validateContentCallback,
                                // maxLength: 1000,
                                minLines: 3,
                                maxLines: null,
                                // keyboardType: TextInputType.multiline,
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
                                initialValue: model.nicknameValue =
                                    existingPost.nickname,
                                validator: model.validateNicknameCallback,
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
                                validator: model.validateEmotionCallback,
                                value: model.emotionDropdownValue =
                                    existingPost.emotion,
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
                                      children:
                                          kCategoryList.map<Widget>((item) {
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
                                  left: 10.0,
                                  top: 8.0,
                                  right: 10.0,
                                  bottom: 32.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                    '5つ以内で選択してください',
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: kLightGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// position
                            // Todo positionを複数選択できるようにしよう
                            Padding(
                              padding: const EdgeInsets.only(bottom: 32.0),
                              child: DropdownButtonFormField(
                                // validator: model.validatePositionCallback,
                                value: existingPost.position.isNotEmpty
                                    ? model.positionDropdownValue =
                                        existingPost.position
                                    : isUserProfileExisting
                                        ? model.positionDropdownValue =
                                            userProfile.position
                                        : model.positionDropdownValue,
                                icon: Icon(Icons.arrow_downward),
                                iconSize: 24,
                                elevation: 1,
                                style: kDropdownButtonFormFieldTextStyle,
                                decoration:
                                    kPositionDropdownButtonFormFieldDecoration,
                                onChanged: (String? selectedValue) {
                                  model.positionDropdownValue = selectedValue!;
                                },
                                items: kPositionList.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),

                            /// gender
                            Padding(
                              padding: const EdgeInsets.only(bottom: 32.0),
                              child: DropdownButtonFormField(
                                value: existingPost.gender.isNotEmpty
                                    ? model.genderDropdownValue =
                                        existingPost.gender
                                    : isUserProfileExisting
                                        ? model.genderDropdownValue =
                                            userProfile.gender
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
                                value: existingPost.age.isNotEmpty
                                    ? model.ageDropdownValue = existingPost.age
                                    : isUserProfileExisting
                                        ? model.ageDropdownValue =
                                            userProfile.age
                                        : model.ageDropdownValue,
                                icon: Icon(Icons.arrow_downward),
                                iconSize: 24,
                                elevation: 1,
                                style: kDropdownButtonFormFieldTextStyle,
                                decoration:
                                    kAgeDropdownButtonFormFieldDecoration,
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
                                value: existingPost.area.isNotEmpty
                                    ? model.areaDropdownValue =
                                        existingPost.area
                                    : isUserProfileExisting
                                        ? model.areaDropdownValue =
                                            userProfile.area
                                        : model.areaDropdownValue,
                                icon: Icon(Icons.arrow_downward),
                                iconSize: 24,
                                elevation: 1,
                                style: kDropdownButtonFormFieldTextStyle,
                                decoration:
                                    kAreaDropdownButtonFormFieldDecoration,
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

                            /// 投稿更新ボタン
                            passedModel is! DraftsModel
                                ? OutlinedButton(
                                    onPressed: () async {
                                      if (model.validateSelectedCategories() &&
                                          _formKey.currentState!.validate()) {
                                        model.startLoading();
                                        await model.updatePost(existingPost);
                                        model.stopLoading();
                                        Navigator.pop(context);
                                        // Navigator.of(context).popUntil(
                                        //   ModalRoute.withName('/'),
                                        // );
                                      }
                                    },
                                    child: Text(
                                      '更新する',
                                      style: TextStyle(
                                        color: kDarkPink,
                                        fontSize: 16,
                                        // fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 12.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      side: BorderSide(color: kDarkPink),
                                    ),
                                  )
                                :

                                /// 投稿送信ボタン
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      OutlinedButton(
                                        onPressed: () async {
                                          if (model
                                                  .validateSelectedCategories() &&
                                              _formKey.currentState!
                                                  .validate()) {
                                            await model
                                                .addPostFromDraft(existingPost);
                                            Navigator.pop(
                                              context,
                                              ResultForDraftButton
                                                  .addPostFromDraft,
                                            );
                                            // Navigator.of(context).popUntil(
                                            //   ModalRoute.withName('/'),
                                            // );
                                          }
                                        },
                                        child: Text(
                                          '投稿する',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            // fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: kDarkPink,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                          ),
                                          side: BorderSide(color: kDarkPink),
                                        ),
                                      ),
                                      SizedBox(height: 16.0),

                                      /// 下書き保存ボタン
                                      OutlinedButton(
                                        onPressed: () async {
                                          if (model
                                                  .validateSelectedCategories() &&
                                              _formKey.currentState!
                                                  .validate()) {
                                            await model
                                                .updateDraftPost(existingPost);
                                            Navigator.pop(
                                              context,
                                              ResultForDraftButton.updateDraft,
                                            );
                                            // Navigator.of(context).popUntil(
                                            //   ModalRoute.withName('/'),
                                            // );
                                          }
                                        },
                                        child: Text(
                                          '下書きに保存する',
                                          style: TextStyle(
                                            color: kDarkPink,
                                            fontSize: 16,
                                            // fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                          ),
                                          side: BorderSide(color: kDarkPink),
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                    ),
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

class FilterChipWidget extends StatelessWidget {
  FilterChipWidget({required this.chipName, required this.model});

  final String chipName;
  final UpdatePostModel model;

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
