import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';

class UpdatePushNotificationModel extends ChangeNotifier {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final _messaging = FirebaseMessaging.instance;
  bool isLoading = false;

  bool isNewPostTopicAllowed = true;
  bool isReplyToMyPostAllowed = true;
  // bool isReplyToMyReplyAllowed = true;

  Future<void> init() async {
    final userSnapshot =
        await firestore.collection('users').doc(currentUser.uid).get();
    initNewPostTopic(userSnapshot);
    initReplyToMyPost(userSnapshot);
    // initReplyToMyReply(userSnapshot);
    notifyListeners();
  }

  void initNewPostTopic(DocumentSnapshot userSnapshot) {
    final topics = userSnapshot['topics'] as List<String>;
    if (topics.contains('newPost')) {
      isNewPostTopicAllowed = true;
    } else {
      isNewPostTopicAllowed = false;
    }
  }

  void initReplyToMyPost(DocumentSnapshot userSnapshot) {
    final pushNoticesSetting =
        userSnapshot['pushNoticesSetting'] as List<String>;
    if (pushNoticesSetting.contains('replyToMyPost')) {
      isReplyToMyPostAllowed = true;
    } else {
      isReplyToMyPostAllowed = false;
    }
  }

  // void initReplyToMyReply(DocumentSnapshot userSnapshot) {
  //   final pushNoticesSetting =
  //       userSnapshot['pushNoticesSetting'] as List<String>;
  //   if (pushNoticesSetting.contains('replyToMyReply')) {
  //     this.isReplyToMyReplyAllowed = true;
  //   } else {
  //     this.isReplyToMyReplyAllowed = false;
  //   }
  // }

  // ignore: avoid_positional_boolean_parameters
  Future<void> toggleSubscriptionForNewPostTopic(bool value) async {
    const topic = 'newPost';
    final userRef = firestore.collection('users').doc(currentUser.uid);
    if (value) {
      // subscribeToNewPost
      isNewPostTopicAllowed = true;
      notifyListeners();
      await _messaging.subscribeToTopic(topic);
      await userRef.update({
        'topics': FieldValue.arrayUnion(<String>[topic]),
      });
    } else {
      // unsubscribeFromNewPost
      isNewPostTopicAllowed = false;
      notifyListeners();
      await _messaging.unsubscribeFromTopic(topic);
      await userRef.update({
        'topics': FieldValue.arrayRemove(<String>[topic]),
      });
    }
  }

  // ignore: avoid_positional_boolean_parameters
  Future<void> togglePermissionForReplyToMyPost(bool value) async {
    const notification = 'replyToMyPost';
    final userRef = firestore.collection('users').doc(currentUser.uid);
    if (value) {
      // allowReplyToMyPost
      isReplyToMyPostAllowed = true;
      notifyListeners();
      await userRef.update({
        'pushNoticesSetting': FieldValue.arrayUnion(<String>[notification]),
      });
    } else {
      // doNotAllowReplyToMyPost
      isReplyToMyPostAllowed = false;
      notifyListeners();
      await userRef.update({
        'pushNoticesSetting': FieldValue.arrayRemove(<String>[notification]),
      });
    }
  }

  // Future<void> togglePermissionForReplyToMyReply(bool value) async {
  //   final notification = 'replyToMyReply';
  //   final userRef = firestore.collection('users').doc(currentUser.uid);
  //   if (value) {
  //     // allowReplyToMyReply
  //     isReplyToMyReplyAllowed = true;
  //     notifyListeners();
  //     await userRef.update({
  //       'pushNoticesSetting': FieldValue.arrayUnion([notification]),
  //     });
  //   } else {
  //     // doNotAllowReplyToMyReply
  //     isReplyToMyReplyAllowed = false;
  //     notifyListeners();
  //     await userRef.update({
  //       'pushNoticesSetting': FieldValue.arrayRemove([notification]),
  //     });
  //   }
  // }

  void startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void stopLoading() {
    isLoading = false;
    notifyListeners();
  }
}
