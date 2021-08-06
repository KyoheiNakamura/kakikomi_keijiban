import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/presentation/home_posts/home_posts_page.dart';

class CommonScrollBottomNotificationListener extends StatelessWidget {
  const CommonScrollBottomNotificationListener({
    required this.model,
    required this.child,
    this.tabType,
    Key? key,
  }) : super(key: key);

  final dynamic model;
  final Widget child;
  final TabType? tabType;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels ==
            notification.metrics.maxScrollExtent) {
          if (model.isLoading as bool) {
            return false;
          } else {
            if (tabType != null) {
              if (model.canLoadMore(tabType) as bool) {
                // ignore: unnecessary_statements
                model.loadPostsWithReplies(tabType);
              }
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
