import 'package:flutter/material.dart';

const kCommonAppBarHeight = 48;

PreferredSizeWidget commonAppBar({
  required String title,
  Color? backgroundColor,
  Widget? action,
}) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(48),
    child: AppBar(
      title: Text(title),
      backgroundColor: backgroundColor,
      actions: action != null ? [action] : null,
    ),
  );
}
