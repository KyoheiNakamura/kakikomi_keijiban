/// 不要な空行
///   - 冒頭の改行
///   - 途中に 3つ以上続く改行
///   - 末尾の改行
/// を取り除く
String removeUnnecessaryBlankLines(String input) {
  RegExp headBlankLines = RegExp(r'^\n+');
  RegExp blankLines = RegExp(r'\n{3,}');
  RegExp lastBlankLines = RegExp(r'\n+$');
  return input
      .replaceAll(headBlankLines, '')
      .replaceAll(blankLines, '\n\n')
      .replaceAll(lastBlankLines, '');
}
