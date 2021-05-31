import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';
import 'package:kakikomi_keijiban/domain/reply_to_reply.dart';

mixin FormatPosterDataMixin {
  String getFormattedPosterData(Post post) {
    var posterInfo = '';
    var formattedPosterInfo = '';

    final posterData = [
      '${post.nickname}さん',
      post.gender,
      post.age,
      post.area,
      post.position,
    ];

    for (final data in posterData) {
      data.isNotEmpty ? posterInfo += '$data/' : posterInfo += '';
      final lastSlashIndex = posterInfo.length - 1;
      formattedPosterInfo = posterInfo.substring(0, lastSlashIndex);
    }
    return formattedPosterInfo;
  }

  String getFormattedReplierData(Reply reply) {
    var replierInfo = '';
    var formattedReplierInfo = '';

    final replierData = [
      '${reply.nickname}さん',
      reply.gender,
      reply.age,
      reply.area,
      reply.position,
    ];

    for (final data in replierData) {
      data.isNotEmpty ? replierInfo += '$data/' : replierInfo += '';
      final lastSlashIndex = replierInfo.length - 1;
      formattedReplierInfo = replierInfo.substring(0, lastSlashIndex);
    }
    return formattedReplierInfo;
  }

  String getFormattedReplyToReplierData(ReplyToReply replyToReply) {
    var replierInfo = '';
    var formattedReplyToReplierInfo = '';

    final replierData = [
      '${replyToReply.nickname}さん',
      replyToReply.gender,
      replyToReply.age,
      replyToReply.area,
      replyToReply.position,
    ];

    for (final data in replierData) {
      data.isNotEmpty ? replierInfo += '$data/' : replierInfo += '';
      final lastSlashIndex = replierInfo.length - 1;
      formattedReplyToReplierInfo = replierInfo.substring(0, lastSlashIndex);
    }
    return formattedReplyToReplierInfo;
  }
}
