import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DateUtil {
  static String formatTimestampToString(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final diffInSecounds = now.difference(date).inSeconds;
    final diffInMinutes = now.difference(date).inMinutes;
    final diffInHours = now.difference(date).inHours;
    final diffInDays = now.difference(date).inDays;

    if (diffInSecounds >= 0 && diffInSecounds < 60) {
      return '${diffInSecounds.toString()}秒前';
    } else if (diffInMinutes >= 1 && diffInMinutes < 60) {
      return '${diffInMinutes.toString()}分前';
    } else if (diffInHours >= 1 && diffInHours < 24) {
      return '${diffInHours.toString()}時間前';
    } else if (diffInDays >= 1 && diffInDays < 7) {
      return '${diffInDays.toString()}日前';
    } else {
      // final formatter = DateFormat('yyyy/MM/dd HH:mm');
      final formatter = DateFormat('MM/dd HH:mm');
      return formatter.format(date);
    }
  }
}
