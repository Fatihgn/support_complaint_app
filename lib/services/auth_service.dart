import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:destek_talep_app/screens/admin_screen.dart';
import 'package:destek_talep_app/screens/help_screen.dart';
import 'package:destek_talep_app/screens/home_screen.dart';
import 'package:destek_talep_app/services/models/post_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';

class AuthService {
  final userCollection = FirebaseFirestore.instance.collection('users');
  final firebaseAuth = FirebaseAuth.instance;

  Future<void> signUp(String name, String email, String password,
      BuildContext context, String phone, String tcNo, String vergiNo) async {
    final navigator = Navigator.of(context);
    try {
      final UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null) {
        final User currentUser = FirebaseAuth.instance.currentUser!;
        final String documentId = currentUser.uid;
        print(documentId);
        registerUser(name, email, password, documentId, phone, tcNo, vergiNo);
        navigator.pushReplacement(
            MaterialPageRoute(builder: (context) => const HelpScreen()));
      }
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.message!);
    }
  }

  Future<void> signIn(
      String email, String password, BuildContext context) async {
    final navigator = Navigator.of(context);
    try {
      final UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null) {
        final User currentUser = FirebaseAuth.instance.currentUser!;
        final String documentId = currentUser.uid;
        final doc =
            FirebaseFirestore.instance.collection("admins").doc(documentId);
        final documentSnapshot = await doc.get();
        if (documentSnapshot.exists) {
          navigator.pushReplacement(
              MaterialPageRoute(builder: (context) => const AdminScreen()));
        } else {
          navigator.pushReplacement(
              MaterialPageRoute(builder: (context) => const HelpScreen()));
        }
      }
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.message!);
    }
  }

  Future<void> registerUser(String name, String email, String password,
      String uid, String phone, String tcNo, String vergiNo) async {
    await userCollection.doc(uid).set({
      'email': email,
      'name': name,
      "password": password,
      "posts": [],
      "phone": phone,
      "tcNo": tcNo,
      "vergiNo": vergiNo
    });
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await firebaseAuth.signOut();
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false);
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.message!);
    }
  }
}
