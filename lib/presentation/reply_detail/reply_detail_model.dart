import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/mixin/provide_common_posts_method_mixin.dart';
import 'package:kakikomi_keijiban/entity/reply.dart';

class ReplyDetailModel extends ChangeNotifier
    with ProvideCommonPostsMethodMixin {
  ReplyDetailModel({required this.reply});

  final Reply reply;

  final ScrollController scrollController = ScrollController();

  Future<void> init() async {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
    await reloadReplies();
    notifyListeners();
    await Future(() {
      scrollController.jumpTo(
        scrollController.position.maxScrollExtent,
      );
    });
  }

  Future<void> reloadReplies() async {
    // final empathizedPostsIds = await getEmpathizedPostsIds();
    await getRepliesToReply([reply]);
    notifyListeners();
  }
}
