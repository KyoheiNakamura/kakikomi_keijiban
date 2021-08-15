import 'package:kakikomi_keijiban/entity/infinite_scroll.dart';

abstract class PostTab extends InfiniteScroll {}

class NewPostTab extends PostTab {}

class EmpathizedPostTab extends PostTab {}

class BookmarkedPostTab extends PostTab {}

class MyPostTab extends PostTab {}

class MyReplyTab extends PostTab {}

class SearchResultPostTab extends PostTab {}
