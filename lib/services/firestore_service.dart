// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <<< ESSENTIAL NEW IMPORT
import 'package:flutter/foundation.dart';
import 'package:wellbeing_mobile_app/models/user_data.dart'; // Check path: lib/models/user_data.dart

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId {
    // LINTER FIX: Use null-aware operator
    return _auth.currentUser?.uid;
  }

  // Future<bool> hasEntrySubmittedToday(String? userId) - (Not shown in image, but assuming exists)

  // FIX: Renamed 'saveCheckIn' to 'saveEntry' to fix error in lib/entry_screen.dart
  Future<void> saveEntry(Map<String, dynamic> entry) async {
    final userId = currentUserId;

    if (userId == null) {
      throw Exception('User is not authenticated. Cannot save data.');
    }

    try {
      final userName = await getUserNameFromPrefs() ?? 'User'; // FIX: Get saved name
      final userCheckinRef = _db.collection('users').doc(userId).collection('checkins');

      await userCheckinRef.add({
        ...entry,
        'timestamp': FieldValue.serverTimestamp(),
        'userName': userName, // Added for potential filtering/display ease
      });
      debugPrint('Check-in saved successfully for user $userId');
    } on FirebaseException catch (e) {
      debugPrint('Error saving entry: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error saving entry: $e');
      rethrow;
    }
  }

  // The previous saveCheckIn is now saveEntry, so this function is removed or replaced

  Future<void> saveUserDetails({
    required String username,
    required int age,
    required String primaryGoal,
  }) async {
    final userId = currentUserId;

    if (userId == null) {
      throw Exception('User is not authenticated. Cannot save details.');
    }

    try {
      // LINTER FIX: Added final keyword
      final userProfileRef = _db.collection('users').doc(userId).collection('profile').doc('details');

      await userProfileRef.set(
        <String, dynamic>{
          'userName': username,
          'age': age,
          'primaryGoal': primaryGoal,
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true), // LINTER FIX: Added const
      );

      // LINTER FIX: Added final keyword
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', username); // Save to preferences for quick access

      debugPrint('User details saved successfully for user $userId');

    } on FirebaseException catch (e) {
      debugPrint('Error saving user details: ${e.message}');
      rethrow;
    }
  }
  
  // ADDED METHOD: Fetches the user name saved in local storage (prefs)
  Future<String?> getUserNameFromPrefs() async {
    // LINTER FIX: Added final keyword
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName');
  }

  Future<UserData?> getProfileDetails() async {
    final userId = currentUserId;

    if (userId == null) {
      return null;
    }

    try {
      final doc = await _db.collection('users').doc(userId).collection('profile').doc('details').get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          final userData = UserData.fromMap(data);
          return userData;
        }
      }
      return null;
    } on FirebaseException catch (e) {
      debugPrint('Error fetching user profile details: ${e.message}');
      return null;
    }
  }
}
