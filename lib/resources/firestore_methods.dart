import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:insta_clone/models/posts.dart';
import 'package:insta_clone/resources/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // add posts into firestore

  addImageIntoFirestore(String uid, Uint8List file, String description,
      String username, String profImage) async {
    String res = "error occured";
    try {
      String imageUrl =
          await StorageMethods().addImageToFirebaseStorage('posts', file, true);

      String postId = const Uuid().v1();

      Post post = Post(
          username: username,
          uid: uid,
          description: description,
          postId: postId,
          datePublished: DateTime.now(),
          postUrl: imageUrl,
          profImage: profImage,
          likes: []);
      _firestore.collection('posts').doc(postId).set(post.toJson());
      res = "success";
    } on Exception catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
    } catch (e) {
      print('Error in likePost : $e');
    }
  }

  Future<void> postComment(String postId, String commentText, String userId,
      String name, String profilePic) async {
    try {
      if (commentText.isNotEmpty) {
        String commentId = const Uuid().v1();
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'body': commentText,
          'commentId': commentId,
          'userId': userId,
          'name': name,
          'profilePic': profilePic,
          'datePublished': DateTime.now()
        });
      }
    } on Exception catch (e) {
      print('Error in postComment $e');
    }
  }

  Future<void> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if (following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });
      }
    } catch (e) {
      if (kDebugMode) print(e.toString());
    }
  }

  Future<void> deletePost(String postId) async {
    await _firestore.collection('posts').doc(postId).delete();
  }
}
