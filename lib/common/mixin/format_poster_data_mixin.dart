mixin FormatPosterDataMixin {
  String getFormattedPosterData(post) {
    String posterInfo = '';
    String formattedPosterInfo = '';

    List<String> posterData = [
      '${post.nickname}さん',
      post.gender,
      post.age,
      post.area,
      post.position,
    ];

    for (var data in posterData) {
      data.isNotEmpty ? posterInfo += '$data/' : posterInfo += '';
      int lastSlashIndex = posterInfo.length - 1;
      formattedPosterInfo = posterInfo.substring(0, lastSlashIndex);
    }
    return formattedPosterInfo;
  }
}
