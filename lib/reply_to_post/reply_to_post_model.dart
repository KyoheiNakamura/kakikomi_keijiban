import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';

class ReplyToPostModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;

  String contentValue = '';
  String nicknameValue = '';
  String positionDropdownValue = kPleaseSelect;
  String genderDropdownValue = kPleaseSelect;
  String ageDropdownValue = kPleaseSelect;
  String areaDropdownValue = kPleaseSelect;

  List<String> _convertNoSelectedValueToEmpty() {
    List<String> postDataList = [
      contentValue,
      nicknameValue,
      positionDropdownValue,
      genderDropdownValue,
      ageDropdownValue,
      areaDropdownValue,
    ];
    postDataList = postDataList.map((postData) {
      if (postData == kPleaseSelect || postData == kDoNotSelect) {
        return '';
      } else {
        return postData;
      }
    }).toList();
    return postDataList;
  }

  Future<void> addReply(Post repliedPost) async {
    List<String> _postDataList = _convertNoSelectedValueToEmpty();
    final post = _firestore.collection('posts').doc(repliedPost.id);
    final replies = post.collection('replies');

    await replies.add({
      'textBody': _postDataList[0],
      'nickname': _postDataList[1],
      'position': _postDataList[2],
      'gender': _postDataList[3],
      'age': _postDataList[4],
      'area': _postDataList[5],
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> updateReply(Reply existingReply) async {
    List<String> _postDataList = _convertNoSelectedValueToEmpty();
    final post = _firestore.collection('posts').doc(existingReply.postId);
    final reply = post.collection('replies').doc(existingReply.id);
    await reply.update({
      'textBody': _postDataList[0],
      'nickname': _postDataList[1],
      'position': _postDataList[2],
      'gender': _postDataList[3],
      'age': _postDataList[4],
      'area': _postDataList[5],
      'updatedAt': Timestamp.now(),
    });
  }
}
