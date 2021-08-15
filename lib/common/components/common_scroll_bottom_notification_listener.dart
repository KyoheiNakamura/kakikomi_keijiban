import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/manager/firestore_manager.dart';
import 'package:kakikomi_keijiban/presentation/home_posts/home_posts_page.dart';

/// 無限スクロールをするためのウィジェット
class CommonScrollBottomNotificationListener extends StatelessWidget {
  const CommonScrollBottomNotificationListener({
    required this.model,
    required this.child,
    this.type,
    Key? key,
  }) : super(key: key);

  final dynamic model;
  final Widget child;
  final CommonPostsType? type;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        print('notification.metrics.pixels: ${notification.metrics.pixels}');
        print(
            'notification.metrics.maxScrollExtent: ${notification.metrics.maxScrollExtent}');

        if (notification.metrics.pixels ==
            notification.metrics.maxScrollExtent) {
          if (type != null) {
            if (model.isLoading(type) as bool) {
              return false;
            } else {
              if (model.canLoadMore(type) as bool) {
                // ignore: unnecessary_statements
                model.loadPostsWithReplies(type: type);
              }
            }
          } else {
            if (model.isLoading as bool) {
              return false;
            } else {
              if (model.canLoadMore as bool) {
                // ignore: unnecessary_statements
                model.loadPostsWithReplies();
              }
            }
          }
        } else {
          return false;
        }
        return false;
      },
      child: child,
    );
  }
}
