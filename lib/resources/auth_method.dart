// ignore_for_file: avoid_print

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:insta_clone/models/user.dart' as model;
import 'package:insta_clone/resources/firebase_storage.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User? currentUser = _auth.currentUser;

    DocumentSnapshot snap =
        await _firestore.collection('users').doc(currentUser!.uid).get();

    return model.User.fromSnap(snap);
  }

  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file,
  }) async {
    String res = "Some error occured";
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          bio.isNotEmpty) {
        // register user
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        print(cred.user!.uid);

        String photoUrl = await StorageMethods()
            .addImageToFirebaseStorage('profilePic', file, false);

        model.User user = model.User(
            username: username,
            uid: cred.user!.uid,
            photoUrl: photoUrl,
            email: email,
            bio: bio,
            followers: [],
            following: []);
        _firestore.collection('users').doc(cred.user!.uid).set(user.toJson());
        res = "success";
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> loginUser(
      {required String email, required String password}) async {
    String res = "Some error has occured";
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      res = "success";
    } catch (e) {
      print('Error in login user : $e)}');
      return e.toString();
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
