import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';
import 'package:kakikomi_keijiban/presentation/add_reply_to_post/add_reply_to_post_model.dart';
import 'package:provider/provider.dart';

// repliedPostかexistingReplyのどちらかを必ずコンストラクタ引数に取る
class AddReplyToPostPage extends StatelessWidget {
  AddReplyToPostPage({this.repliedPost, this.existingReply});

  final Post? repliedPost;
  final Reply? existingReply;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final bool isReplyExisting = existingReply != null;
    return ChangeNotifierProvider<AddReplyToPostModel>(
      create: (context) => AddReplyToPostModel(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          elevation: 0,
          centerTitle: true,
          title: Text(
            '返信',
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Consumer<AddReplyToPostModel>(
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
                      // content
                      TextFormField(
                        initialValue: isReplyExisting
                            ? model.bodyValue = existingReply!.body
                            : null,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '返信の内容を入力してください';
                          } else if (value.length > 1000) {
                            return '1000字以内でご記入ください';
                          }
                          return null;
                        },
                        // maxLength: 1000,
                        // maxLines: null,
                        keyboardType: TextInputType.multiline,
                        onChanged: (newValue) {
                          model.bodyValue = newValue;
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.text_fields),
                          labelText: '返信の内容',
                          hintText:
                              'ハッキリと調べてほしいと言うのなら、病院か保健所へ行って相談することがいいと思います。『グレーゾーンだから』だってもやもやするのはつらいですよね…でも、仕事する(あるいは仕事やめてまた探す)となると…かえってつらくなることもあるのです。仕事できないからって『何もしない』と自分が迷惑することになりかねないし、かえってイヤな思いを背負うこともあるのです。',
                          helperText: '必須',
                          helperStyle: TextStyle(color: kDarkPink),
                          counterText: '1000字以内でご記入ください',
                          counterStyle: TextStyle(color: kLightGrey),
                          // counterText: isReplyExisting
                          //     ? '${existingReply!.textBody.length} 字'
                          //     : '${model.contentValue.length} 字',
                        ),
                      ),
                      SizedBox(
                        height: 32.0,
                      ),
                      // nickname
                      TextFormField(
                        initialValue: isReplyExisting
                            ? model.nicknameValue = existingReply!.nickname
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
                          // counterText: isReplyExisting
                          //     ? '${existingReply!.nickname.length} 字'
                          //     : '${model.nicknameValue.length} 字',
                        ),
                      ),
                      SizedBox(
                        height: 32.0,
                      ),
                      // position
                      DropdownButtonFormField(
                        // validator: (value) {
                        //   if (value == kPleaseSelect) {
                        //     return 'あなたの立場を選択してください';
                        //   }
                        //   return null;
                        // },
                        // focusNode: _positionFocusNode,
                        focusColor: Colors.pink[50],
                        value: isReplyExisting &&
                                existingReply!.position.isNotEmpty
                            ? model.positionDropdownValue =
                                existingReply!.position
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
                          // helperText: '必須',
                          // helperStyle: TextStyle(color: kDarkPink),
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
                        value: isReplyExisting &&
                                existingReply!.gender.isNotEmpty
                            ? model.genderDropdownValue = existingReply!.gender
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
                        value: isReplyExisting && existingReply!.age.isNotEmpty
                            ? model.ageDropdownValue = existingReply!.age
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
                        value: isReplyExisting && existingReply!.area.isNotEmpty
                            ? model.areaDropdownValue = existingReply!.area
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
                            isReplyExisting
                                ? await model.updateReply(existingReply!)
                                : await model.addReply(repliedPost!);
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          isReplyExisting ? '更新する' : '返信する',
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
