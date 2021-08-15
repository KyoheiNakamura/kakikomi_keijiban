import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kakikomi_keijiban/entity/post.dart';
import 'package:kakikomi_keijiban/entity/reply.dart';

class InfiniteScroll {
  List<Post> posts = [];
  bool isLoading = false;
  bool canLoadMore = false;
  QueryDocumentSnapshot? lastVisibleOfTheBatch;
}


