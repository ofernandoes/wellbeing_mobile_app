// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // Required for Navigator

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Authentication state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in anonymously
  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Handle or log the error
      print('Anonymous sign-in failed: ${e.code}');
      return null;
    }
  }

  // Login with email and password
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // Re-throw the exception so the UI can handle it
      throw e;
    }
  }

  // Register with email and password
  Future<void> registerWithEmailPassword({
    required BuildContext context, // 💡 Added context to allow navigation
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Navigate to UserDetailsScreen after successful registration
        if (context.mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/user_details', // Navigate to the new profile completion screen
            (route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      // Re-throw the exception so the UI can handle it
      throw e;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}