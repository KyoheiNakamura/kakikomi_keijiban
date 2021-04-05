// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';

// このドメイン不要論

// class BookmarkedPost {
//   BookmarkedPost(DocumentSnapshot doc) {
//     this.postId = doc[postId];
//     this.postRef = doc.reference.parent.parent!;
//     this.isActive = doc['isActive'];
//     this._createdAt = doc['createdAt'].toDate();
//   }
//
//   String? postId;
//   DocumentReference? postRef;
//   bool isActive = true;
//   DateTime? _createdAt;
//
//   String get createdAt => _formatDate(_createdAt);
//
//   String _formatDate(date) {
//     final formatter = DateFormat('yyyy/MM/dd/ HH:mm');
//     return date != null ? formatter.format(date) : '';
//   }
// }
