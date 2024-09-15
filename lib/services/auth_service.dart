import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawssguardiann/page/home.dart';
import 'package:pawssguardiann/services/database_service.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in
  Future<UserCredential> signInWithEmailPassword(String email, password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  void handleLoginSuccess(BuildContext context) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const HomePage())
    );
  }

  Future<void> verifyEmail() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
      print("Email verification sent to: ${user.email}");
    } else {
      print("No user currently signed in");
    }
  }

  Future<User?> registerUserWithEmailandPassword(String name, String email, String password, int phoneno) async {
    try {
      // Check if all required fields are provided
      if (name.isNotEmpty || email.isNotEmpty || password.isNotEmpty) {
        throw Exception("All fields are required");
      }

      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
          email: email,
          password: password);

      // Call database service to update user data
      await DatabaseServices().updateUserData(email, phoneno, name);

      // After create user, create a new document for users in user collection
      _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'name': name,
        'phone number': phoneno
      });

      return userCredential.user;

    } on FirebaseAuthException catch(e) {
      print("Error during registration: ${e.message}");
      return null;
    }
  }

  Future<void> signOut() async {
    return await _auth.signOut();
  }
}