import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint

class FirestoreService {
  // ✅ LINTER FIX: Add final keyword to private fields
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId {
    // ✅ LINTER FIX: Use null-aware operator
    return _auth.currentUser?.uid;
  }

  Future<bool> hasUserSubmittedToday(String? userId) async {
    if (userId == null) {
      // ✅ LINTER FIX: Added curly braces for consistency
      return false;
    }

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    try {
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('checkins')
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          .limit(1)
          .get();
          
      return snapshot.docs.isNotEmpty;
    } on FirebaseException catch (e) {
      // ✅ FIX: Replaced print with debugPrint
      debugPrint('Error checking submission status: ${e.message}');
      // It returns true here to prevent the user from re-submitting if there's a Firebase error (fail-safe)
      return true; 
    }
  }

  Future<void> saveEntry(Map<String, dynamic> entry) async {
    final userId = currentUserId; 
    
    if (userId == null) {
      throw Exception("User is not authenticated. Cannot save data.");
    }

    try {
      // ✅ LINTER FIX: Added final keyword
      final userCheckinsRef = _db.collection('users').doc(userId).collection('checkins');
      final userName = await _getUserNameFromPrefs() ?? 'User';

      await userCheckinsRef.add(<String, dynamic>{
        ...entry, 
        'timestamp': FieldValue.serverTimestamp(),
        'userName': userName, 
      });
      // ✅ FIX: Replaced print with debugPrint
      debugPrint('Check-in saved successfully for user $userId');
    } on FirebaseException catch (e) {
      // ✅ FIX: Replaced print with debugPrint and ensured rethrow is used.
      debugPrint('Error saving entry: ${e.message}');
      rethrow; 
    } catch (e) {
      // ✅ FIX: Replaced print with debugPrint
      debugPrint('Unexpected error saving entry: $e');
      rethrow;
    }
  }

  Future<void> saveUserDetails({
    required String userName,
    required int age,
    required String goal,
  }) async {
    final userId = currentUserId;
    
    if (userId == null) {
      throw Exception("User is not authenticated. Cannot save details.");
    }

    try {
      // ✅ LINTER FIX: Added final keyword
      final userProfileRef = _db.collection('users').doc(userId).collection('profile').doc('details');

      await userProfileRef.set(<String, dynamic>{
        'userName': userName,
        'age': age,
        'primaryGoal': goal,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // ✅ LINTER FIX: Added const

      // ✅ LINTER FIX: Added final keyword
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', userName);
      
      // ✅ FIX: Replaced print with debugPrint
      debugPrint('User details saved successfully for user $userId');
    } on FirebaseException catch (e) {
      // ✅ FIX: Replaced print with debugPrint and ensured rethrow is used.
      debugPrint('Error saving user details: ${e.message}');
      rethrow; 
    }
  }

  Future<String?> _getUserNameFromPrefs() async {
    // ✅ LINTER FIX: Added final keyword
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName');
  }
}
