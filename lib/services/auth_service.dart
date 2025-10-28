// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  // ✅ LINTER FIX: Add final to the instance field
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Added stream for monitoring auth state (good practice)
  Stream<User?> get user {
    return _auth.authStateChanges();
  }
  
  // ✅ FIX: Renamed method to match usage in lib/register_screen.dart
  Future<User?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('Registration successful: ${userCredential.user?.uid}');
      return userCredential.user;
    } on FirebaseAuthException {
      rethrow; 
    } catch (e) {
      rethrow;
    }
  }

  // ✅ FIX: Renamed method to match usage in lib/login_screen.dart
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('Sign-in successful: ${userCredential.user?.uid}');
      return userCredential.user;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      debugPrint('Anonymous sign-in successful: ${userCredential.user?.uid}');
      return userCredential.user;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}