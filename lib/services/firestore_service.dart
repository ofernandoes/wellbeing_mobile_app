import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId {
    return _auth.currentUser?.uid;
  }

  Future<bool> hasUserSubmittedToday(String? userId) async {
    if (userId == null) {
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
      debugPrint('Error checking submission status: ${e.message}');
      return true; 
    }
  }

  Future<void> saveEntry(Map<String, dynamic> entry) async {
    final userId = currentUserId; 
    
    if (userId == null) {
      throw Exception("User is not authenticated. Cannot save data.");
    }

    try {
      final userCheckinsRef = _db.collection('users').doc(userId).collection('checkins');
      final userName = await _getUserNameFromPrefs() ?? 'User';

      await userCheckinsRef.add(<String, dynamic>{
        ...entry, 
        'timestamp': FieldValue.serverTimestamp(),
        'userName': userName, 
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
      final userProfileRef = _db.collection('users').doc(userId).collection('profile').doc('details');

      await userProfileRef.set(<String, dynamic>{
        'userName': userName,
        'age': age,
        'primaryGoal': goal,
        'createdAt': FieldValue.serverTimestamp(),
      }, const SetOptions(merge: true));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', userName);
      
      debugPrint('User details saved successfully for user $userId');
    } on FirebaseException catch (e) {
      debugPrint('Error saving user details: ${e.message}');
      rethrow; 
    }
  }

  Future<String?> _getUserNameFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName');
  }
}