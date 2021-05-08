import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';

class EditPushNotificationModel extends ChangeNotifier {
  final currentUser = auth.currentUser!;
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
    final List<dynamic> topics = userSnapshot['topics'];
    if (topics.contains('newPost')) {
      this.isNewPostTopicAllowed = true;
    } else {
      this.isNewPostTopicAllowed = false;
    }
  }

  void initReplyToMyPost(DocumentSnapshot userSnapshot) {
    final List<dynamic> pushNoticesSetting = userSnapshot['pushNoticesSetting'];
    if (pushNoticesSetting.contains('replyToMyPost')) {
      this.isReplyToMyPostAllowed = true;
    } else {
      this.isReplyToMyPostAllowed = false;
    }
  }

  // void initReplyToMyReply(DocumentSnapshot userSnapshot) {
  //   final List<dynamic> pushNoticesSetting = userSnapshot['pushNoticesSetting'];
  //   if (pushNoticesSetting.contains('replyToMyReply')) {
  //     this.isReplyToMyReplyAllowed = true;
  //   } else {
  //     this.isReplyToMyReplyAllowed = false;
  //   }
  // }

  Future<void> toggleSubscriptionForNewPostTopic(bool value) async {
    final topic = 'newPost';
    final userRef = firestore.collection('users').doc(currentUser.uid);
    if (value) {
      // subscribeToNewPost
      isNewPostTopicAllowed = true;
      notifyListeners();
      await _messaging.subscribeToTopic(topic);
      await userRef.update({
        'topics': FieldValue.arrayUnion([topic]),
      });
    } else {
      // unsubscribeFromNewPost
      isNewPostTopicAllowed = false;
      notifyListeners();
      await _messaging.unsubscribeFromTopic(topic);
      await userRef.update({
        'topics': FieldValue.arrayRemove([topic]),
      });
    }
  }

  Future<void> togglePermissionForReplyToMyPost(bool value) async {
    final notification = 'replyToMyPost';
    final userRef = firestore.collection('users').doc(currentUser.uid);
    if (value) {
      // allowReplyToMyPost
      isReplyToMyPostAllowed = true;
      notifyListeners();
      await userRef.update({
        'pushNoticesSetting': FieldValue.arrayUnion([notification]),
      });
    } else {
      // doNotAllowReplyToMyPost
      isReplyToMyPostAllowed = false;
      notifyListeners();
      await userRef.update({
        'pushNoticesSetting': FieldValue.arrayRemove([notification]),
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
