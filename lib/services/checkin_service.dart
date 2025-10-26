// lib/services/checkin_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // For @immutable

// ----------------------------------------------------------------------
// 1. DAILY CHECK-IN DATA MODEL
// ----------------------------------------------------------------------

/// Represents a single daily entry for mood tracking.
@immutable
class DailyCheckin {
  final String id;
  final DateTime timestamp;
  final int moodScore; // 1 (worst) to 5 (best)
  final String notes;

  const DailyCheckin({
    required this.id,
    required this.timestamp,
    required this.moodScore,
    this.notes = '',
  });

  // Factory constructor for creating a DailyCheckin from a Firestore DocumentSnapshot
  factory DailyCheckin.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception("Document data was null for ID: ${doc.id}");
    }

    // Convert Firestore Timestamp to Dart DateTime
    Timestamp firestoreTimestamp = data['timestamp'] as Timestamp;

    return DailyCheckin(
      // CRITICAL: Use the Firestore document ID as the Checkin ID
      id: doc.id,
      timestamp: firestoreTimestamp.toDate(),
      moodScore: data['moodScore'] as int? ?? 3,
      notes: data['notes'] as String? ?? '',
    );
  }

  // Convert a DailyCheckin object into a JSON-like structure for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'timestamp': Timestamp.fromDate(timestamp), // Save as Firestore Timestamp
      'moodScore': moodScore,
      'notes': notes,
      // CRITICAL: Link to the current anonymous user's ID
      'userId': FirebaseAuth.instance.currentUser!.uid, 
    };
  }
}

// ----------------------------------------------------------------------
// 2. CHECK-IN SERVICE (FIRESTORE INTEGRATION)
// ----------------------------------------------------------------------

class CheckinService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Private helper to get the collection reference for the current user
  CollectionReference<Map<String, dynamic>> _checkinCollection() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      // This case should ideally not happen if the AuthGate is working
      throw Exception('User is not authenticated. Cannot access Firestore.');
    }
    // Data structure: users/{uid}/checkins/{checkinId}
    return _firestore.collection('users').doc(uid).collection('checkins');
  }

  // CREATE (Save)
  Future<void> saveCheckin(DailyCheckin checkin) async {
    // Firestore generates the permanent ID
    await _checkinCollection().add(checkin.toFirestore());
  }

  // UPDATE
  Future<void> updateCheckin(DailyCheckin checkin) async {
    // Uses the existing Firestore document ID (checkin.id)
    await _checkinCollection().doc(checkin.id).update(checkin.toFirestore());
  }
  
  // DELETE
  Future<void> deleteCheckin(String id) async {
    await _checkinCollection().doc(id).delete();
  }

  // READ (Stream all check-ins for the current user)
  Stream<List<DailyCheckin>> getCheckinsStream() {
    return _checkinCollection()
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DailyCheckin.fromFirestore(doc))
          .toList();
    });
  }
}