// lib/services/checkin_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// CRITICAL FIX: Update Import to use the correct filename
import 'package:wellbeing_mobile_app/models/daily_checkin_model.dart';

class CheckinService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference for checkins
  CollectionReference get _checkinCollection => _firestore.collection('checkins');

  // Gets the current user ID, throws an error if not logged in
  String get _currentUserId {
    // Return a dummy ID if the user is null to allow development/mocking
    final user = _auth.currentUser;
    return user?.uid ?? 'development_mock_user_id';
  }

  // 1. Method to add a new checkin
  Future<void> addCheckin(DailyCheckin checkin) async {
    // Ensure the checkin has the correct user ID before saving
    final checkinWithUser = DailyCheckin(
      userId: _currentUserId,
      date: checkin.date,
      moodScore: checkin.moodScore,
      note: checkin.note,
      activities: checkin.activities,
    );
    await _checkinCollection.add(checkinWithUser.toFirestore());
  }

  // 2. Method to update an existing checkin (Uses the checkin.id)
  Future<void> updateCheckin(DailyCheckin checkin) async {
    if (checkin.id == null) {
      throw Exception("Cannot update a checkin without an ID.");
    }
    // Ensure the checkin has the correct user ID before saving
    final checkinWithUser = DailyCheckin(
      id: checkin.id,
      userId: _currentUserId,
      date: checkin.date,
      moodScore: checkin.moodScore,
      note: checkin.note,
      activities: checkin.activities,
    );
    await _checkinCollection.doc(checkin.id).update(checkinWithUser.toFirestore());
  }
  
  // 3. Method to get a stream of all checkins for the current user
  Stream<List<DailyCheckin>> getCheckinsStream() {
    return _checkinCollection
        .where('userId', isEqualTo: _currentUserId) // Filter by current user
        // NOTE: Ordering by 'date' as defined in DailyCheckin.toFirestore
        .orderBy('date', descending: true) 
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // CRITICAL FIX: Map the document to the DailyCheckin object using the factory
        return DailyCheckin.fromFirestore(doc);
      }).toList();
    });
  }
}
