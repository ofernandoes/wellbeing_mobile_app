// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Signs in a user anonymously and returns the User object.
  // This is called by the WelcomeScreen buttons.
  Future<User?> signInAnonymously() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      return result.user;
    } catch (e) {
      print("Error signing in anonymously: $e");
      return null;
    }
  }

  // Returns the currently logged-in user (null if none).
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Signs out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}