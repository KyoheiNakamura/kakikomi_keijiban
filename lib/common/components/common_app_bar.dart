import 'package:flutter/material.dart';

PreferredSizeWidget commonAppBar({required String title}) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(50),
    child: AppBar(
      title: Text(title),
    ),
  );
}
