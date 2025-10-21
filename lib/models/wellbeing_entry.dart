import 'package:cloud_firestore/cloud_firestore.dart';

class WellbeingEntry {
  final int moodScore;
  final int sleepRating;
  final int exerciseValue;
  final int waterGlasses;
  final String notes;
  final DateTime timestamp;
  final String userId;

  WellbeingEntry({
    required this.moodScore,
    required this.sleepRating,
    required this.exerciseValue,
    required this.waterGlasses,
    required this.notes,
    required this.timestamp,
    required this.userId,
  });

  // Convert the object to a Firestore-compatible Map
  Map<String, dynamic> toFirestore() {
    return {
      'moodScore': moodScore,
      'sleepRating': sleepRating,
      'exerciseValue': exerciseValue,
      'waterGlasses': waterGlasses,
      'notes': notes,
      'timestamp': Timestamp.fromDate(timestamp), // Use Firestore Timestamp
      'userId': userId,
    };
  }

  // Create a WellbeingEntry object from a Firestore document snapshot
  factory WellbeingEntry.fromFirestore(Map<String, dynamic> firestoreData, String id) {
    final timestampValue = firestoreData['timestamp'];
    DateTime dateTime;

    if (timestampValue is Timestamp) {
      dateTime = timestampValue.toDate();
    } else if (timestampValue is DateTime) {
      dateTime = timestampValue;
    } else {
      // Fallback or error handling if timestamp is missing/wrong type
      dateTime = DateTime.now(); 
    }

    return WellbeingEntry(
      moodScore: firestoreData['moodScore'] as int? ?? 0,
      sleepRating: firestoreData['sleepRating'] as int? ?? 0,
      exerciseValue: firestoreData['exerciseValue'] as int? ?? 0,
      waterGlasses: firestoreData['waterGlasses'] as int? ?? 0,
      notes: firestoreData['notes'] as String? ?? '',
      timestamp: dateTime,
      userId: firestoreData['userId'] as String? ?? '',
    );
  }
}
