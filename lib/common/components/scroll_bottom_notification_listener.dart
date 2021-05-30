import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/presentation/home_posts/home_posts_page.dart';

class ScrollBottomNotificationListener extends StatelessWidget {
  ScrollBottomNotificationListener({
    required this.model,
    required this.child,
    this.tabType,
  });

  final model;
  final Widget child;
  final TabType? tabType;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels ==
            notification.metrics.maxScrollExtent) {
          if (model.isLoading) {
            return false;
          } else {
            if (tabType != null) {
              if (model.canLoadMore(tabType)) {
                // ignore: unnecessary_statements
                model.loadPostsWithReplies(tabType);
              }
            } else {
              if (model.canLoadMore) {
                // ignore: unnecessary_statements
                model.loadPostsWithReplies;
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
