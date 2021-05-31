/// 不要な空行
///   - 冒頭の改行
///   - 途中に 3つ以上続く改行
///   - 末尾の改行
/// を取り除く
String removeUnnecessaryBlankLines(String input) {
  final headBlankLines = RegExp(r'^\n+');
  final blankLines = RegExp(r'\n{3,}');
  final lastBlankLines = RegExp(r'\n+$');
  return input
      .replaceAll(headBlankLines, '')
      .replaceAll(blankLines, '\n\n')
      .replaceAll(lastBlankLines, '');
}
