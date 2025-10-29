// lib/models/daily_checkin_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/**
 * DailyCheckin Model
 * Represents a single daily entry tracking mood, notes, and activities.
 */
class DailyCheckin {
  // Document ID for Firestore (optional, used when reading/updating)
  final String? id; 
  final String userId;
  final DateTime date;
  // Mood score from 1 (Terrible) to 5 (Excellent)
  final int moodScore; 
  final String note;
  // List of strings representing activities completed that day
  final List<String> activities; 

  DailyCheckin({
    this.id,
    required this.userId,
    required this.date,
    required this.moodScore,
    this.note = '',
    this.activities = const [],
  });

  /**
   * Factory constructor to create a DailyCheckin from a Firestore DocumentSnapshot.
   */
  factory DailyCheckin.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      // Return a minimal, invalid entry if data is null, or throw an error.
      // Returning a valid, defaulted object is safer for streams.
      return DailyCheckin(
        userId: 'invalid-user',
        date: DateTime.now(),
        moodScore: 3,
        note: 'Error: Data missing for check-in.',
        id: doc.id,
      );
    }

    // Safely retrieve mood score, defaulting to 3
    int score = (data['moodScore'] is int) ? data['moodScore'] : 3;
    
    // Handle date conversion from Firestore Timestamp
    DateTime checkinDate;
    if (data['date'] is Timestamp) {
      checkinDate = (data['date'] as Timestamp).toDate();
    } else {
      // Fallback: If date is missing or invalid, use today's date
      checkinDate = DateTime.now(); 
    }

    // Handle list of activities, ensuring they are strings
    List<String> activitiesList = (data['activities'] is List)
        ? List<String>.from((data['activities'] as List).whereType<String>())
        : [];

    return DailyCheckin(
      id: doc.id,
      userId: data['userId'] as String? ?? 'unknown',
      date: checkinDate,
      moodScore: score,
      note: data['note'] as String? ?? '',
      activities: activitiesList,
    );
  }

  /**
   * Method to convert a DailyCheckin object to a Map for Firestore storage.
   */
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      // Store date as a Firestore Timestamp
      'date': Timestamp.fromDate(date), 
      'moodScore': moodScore,
      'note': note,
      'activities': activities,
      'timestamp': FieldValue.serverTimestamp(), 
    };
  }
}

// Global constant list of activity options for the UI (used in DailyCheckinScreen)
const List<Map<String, dynamic>> checkinActivities = [
  {'label': 'Workout 💪', 'icon': Icons.fitness_center},
  {'label': 'Meditated 🧘', 'icon': Icons.self_improvement},
  {'label': 'Socialized 🫂', 'icon': Icons.group},
  {'label': 'Good Sleep 😴', 'icon': Icons.bed},
  {'label': 'Ate Well 🍎', 'icon': Icons.restaurant},
  {'label': 'Learned Something 🧠', 'icon': Icons.school},
  {'label': 'Worked on a Goal 🎯', 'icon': Icons.track_changes},
];
