import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/presentation/add_post/add_post_model.dart';
import 'package:provider/provider.dart';

class AddPostPage extends StatelessWidget {
  AddPostPage({this.existingPost});

  final Post? existingPost;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final bool isPostExisting = existingPost != null;
    return ChangeNotifierProvider<AddPostModel>(
      create: (context) => AddPostModel(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          elevation: 0,
          centerTitle: true,
          title: Text(
            '新規投稿',
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Consumer<AddPostModel>(
          builder: (context, model, child) {
            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 48.0, horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // title
                      TextFormField(
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
                        // maxLength: 50,
                        // maxLines: null,
                        // autofocus: true,
                        onChanged: (newValue) {
                          model.titleValue = newValue;
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                          labelText: 'タイトル',
                          hintText: '大人の発達障害とグレーゾーンについて',
                          helperText: '必須',
                          helperStyle: TextStyle(color: kDarkPink),
                          counterText: '50字以内でご記入ください',
                          counterStyle: TextStyle(color: kLightGrey),
                          // counterText: isPostExisting
                          //     ? '${existingPost!.title.length} 字'
                          //     : '${model.titleValue.length} 字',
                        ),
                      ),
                      SizedBox(
                        height: 32.0,
                      ),
                      // content
                      TextFormField(
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
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.text_fields),
                          labelText: '投稿の内容',
                          hintText:
                              '自分が大人の発達障害ではないかと疑っているのですが、特徴の濃淡がはっきりせずグレーゾーンに思われるため、確信が持てないのと、親へどう話せばいいかわからず、診断に踏み切れていません。',
                          helperText: '必須',
                          helperStyle: TextStyle(color: kDarkPink),
                          counterText: '1000字以内でご記入ください',
                          counterStyle: TextStyle(color: kLightGrey),
                          // counterText: isPostExisting
                          //     ? '${existingPost!.textBody.length} 字'
                          //     : '${model.contentValue.length} 字',
                        ),
                      ),
                      SizedBox(
                        height: 32.0,
                      ),
                      // nickname
                      TextFormField(
                        initialValue: isPostExisting
                            ? model.nicknameValue = existingPost!.nickname
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
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.face),
                          labelText: 'ニックネーム',
                          hintText: 'ムセンシティ部',
                          helperText: '必須',
                          helperStyle: TextStyle(color: kDarkPink),
                          counterText: '10字以内でご記入ください',
                          counterStyle: TextStyle(color: kLightGrey),
                          // counterText: isPostExisting
                          //     ? '${existingPost!.nickname.length} 字'
                          //     : '${model.nicknameValue.length} 字',
                        ),
                      ),
                      SizedBox(
                        height: 32.0,
                      ),
                      // emotion
                      DropdownButtonFormField(
                        validator: (value) {
                          if (value == kPleaseSelect) {
                            return 'あなたの気持ちを選択してください';
                          }
                          return null;
                        },
                        // focusNode: _emotionFocusNode,
                        focusColor: Colors.pink[50],
                        value: isPostExisting
                            ? model.emotionDropdownValue = existingPost!.emotion
                            : model.emotionDropdownValue,
                        icon: Icon(
                          Icons.arrow_downward,
                          // color: kDarkPink,
                        ),
                        iconSize: 24,
                        elevation: 1,
                        style: TextStyle(color: Colors.black, fontSize: 15.0),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.mood),
                          labelText: 'あなたの気持ち',
                          helperText: '必須',
                          helperStyle: TextStyle(color: kDarkPink),
                        ),
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
                      SizedBox(
                        height: 32.0,
                      ),
                      // position
                      DropdownButtonFormField(
                        validator: (value) {
                          if (value == kPleaseSelect) {
                            return 'あなたの立場を選択してください';
                          }
                          return null;
                        },
                        // focusNode: _positionFocusNode,
                        focusColor: Colors.pink[50],
                        value: isPostExisting
                            ? model.positionDropdownValue =
                                existingPost!.position
                            : model.positionDropdownValue,
                        icon: Icon(
                          Icons.arrow_downward,
                          // color: kDarkPink,
                        ),
                        iconSize: 24,
                        elevation: 1,
                        style: TextStyle(color: Colors.black, fontSize: 15.0),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'あなたの立場',
                          helperText: '必須',
                          helperStyle: TextStyle(color: kDarkPink),
                          prefixIcon: Icon(Icons.group),
                        ),
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
                      SizedBox(
                        height: 32.0,
                      ),
                      // gender
                      DropdownButtonFormField(
                        // focusNode: _genderFocusNode,
                        focusColor: Colors.pink[50],
                        value: isPostExisting && existingPost!.gender.isNotEmpty
                            ? model.genderDropdownValue = existingPost!.gender
                            : model.genderDropdownValue,
                        icon: Icon(
                          Icons.arrow_downward,
                          // color: kDarkPink,
                        ),
                        iconSize: 24,
                        elevation: 1,
                        style: TextStyle(color: Colors.black, fontSize: 15.0),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'あなたの性別',
                          prefixIcon: Icon(Icons.lens_outlined),
                        ),
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
                      SizedBox(
                        height: 32.0,
                      ),
                      // age
                      DropdownButtonFormField(
                        // focusNode: _ageFocusNode,
                        focusColor: Colors.pink[50],
                        value: isPostExisting && existingPost!.age.isNotEmpty
                            ? model.ageDropdownValue = existingPost!.age
                            : model.ageDropdownValue,
                        icon: Icon(
                          Icons.arrow_downward,
                          // color: kDarkPink,
                        ),
                        iconSize: 24,
                        elevation: 1,
                        style: TextStyle(color: Colors.black, fontSize: 15.0),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'あなたの年齢',
                          prefixIcon: Icon(Icons.date_range),
                        ),
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
                      SizedBox(
                        height: 32.0,
                      ),
                      // area
                      DropdownButtonFormField(
                        // focusNode: _areaFocusNode,
                        focusColor: Colors.pink[50],
                        value: isPostExisting && existingPost!.area.isNotEmpty
                            ? model.areaDropdownValue = existingPost!.area
                            : model.areaDropdownValue,
                        icon: Icon(
                          Icons.arrow_downward,
                          // color: kDarkPink,
                        ),
                        iconSize: 24,
                        elevation: 1,
                        style: TextStyle(color: Colors.black, fontSize: 15.0),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'お住まいの地域',
                          prefixIcon: Icon(Icons.place_outlined),
                        ),
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
                      SizedBox(
                        height: 48.0,
                      ),
                      // 投稿送信ボタン
                      OutlinedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            isPostExisting
                                ? await model.updatePost(existingPost!)
                                : await model.addPost();
                            Navigator.pop(context);
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
                            borderRadius: BorderRadius.circular(15),
                          ),
                          side: BorderSide(color: kDarkPink),
                        ),
                      )
                    ],
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
