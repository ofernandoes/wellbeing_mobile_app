import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wellbeing_mobile_app/models/wellbeing_entry.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper to get the current authenticated user's ID
  String get currentUserId {
    return _auth.currentUser?.uid ?? '';
  }

  // Method to save a new wellbeing entry
  Future<void> saveEntry(WellbeingEntry entry) async {
    final userId = currentUserId;
    if (userId.isEmpty) {
      throw Exception("User is not authenticated. Cannot save entry.");
    }
    
    // Use the toFirestore method from the model
    await _firestore.collection('wellbeing_entries').add(entry.toFirestore());
  }

  // Method to check if the user has already submitted an entry today
  Future<bool> hasUserSubmittedToday(String userId) async {
    if (userId.isEmpty) return false;

    // Start of today (midnight)
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    // Query for entries by this user since the start of today
    final snapshot = await _firestore
        .collection('wellbeing_entries')
        .where('userId', isEqualTo: userId)
        .where('timestamp', isGreaterThanOrEqualTo: startOfToday)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // NEW: Method to get a real-time stream of wellbeing entries
  Stream<List<WellbeingEntry>> getEntriesStream() {
    final userId = currentUserId;
    if (userId.isEmpty) {
      // Return an empty stream if no user is logged in
      return Stream.value([]); 
    }

    return _firestore
        .collection('wellbeing_entries')
        .where('userId', isEqualTo: userId)
        // Order by timestamp descending (most recent first)
        .orderBy('timestamp', descending: true) 
        // Snapshot stream gives real-time updates
        .snapshots() 
        .map((snapshot) {
      // Map the Firestore QuerySnapshot to a List of WellbeingEntry models
      return snapshot.docs.map((doc) {
        return WellbeingEntry.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }
}
