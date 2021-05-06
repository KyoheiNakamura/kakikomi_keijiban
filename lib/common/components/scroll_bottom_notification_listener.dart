import 'package:flutter/material.dart';

class ScrollBottomNotificationListener extends StatelessWidget {
  ScrollBottomNotificationListener(
      {required this.model, required this.child, this.tabName});

  final model;
  final Widget child;
  final String? tabName;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels ==
            notification.metrics.maxScrollExtent) {
          if (model.isLoading) {
            return false;
          } else {
            if (tabName != null) {
              if (model.getCanLoadMore(tabName)) {
                // ignore: unnecessary_statements
                model.loadPostsWithReplies(tabName);
              }
            } else {
              if (model.getCanLoadMore) {
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
