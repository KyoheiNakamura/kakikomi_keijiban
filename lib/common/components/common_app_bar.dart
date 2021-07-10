import 'package:flutter/material.dart';

const kCommonAppBarHeight = 50;

PreferredSizeWidget commonAppBar({
  required String title,
  Widget? action,
}) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(50),
    child: AppBar(
      title: Text(title),
      actions: action != null ? [action] : null,
    ),
  );
}
