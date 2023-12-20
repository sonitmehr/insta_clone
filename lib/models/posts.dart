import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String description;
  final String uid;
  final String username;
  final String postId;
  final datePublished;
  final String postUrl;
  final String profImage;
  final List likes;

  const Post(
      {required this.username,
      required this.uid,
      required this.description,
      required this.postId,
      required this.datePublished,
      required this.postUrl,
      required this.profImage,
      required this.likes});

  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Post(
      username: snapshot["username"],
      uid: snapshot["uid"],
      postId: snapshot["postId"],
      description: snapshot["description"],
      datePublished: snapshot["datePublished"],
      postUrl: snapshot["postUrl"],
      profImage: snapshot["profImage"],
      likes: snapshot["likes"],
    );
  }

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "postId": postId,
        "description": description,
        "datePublished": datePublished,
        "postUrl": postUrl,
        "profImage": profImage,
        "likes": likes,
      };
}
