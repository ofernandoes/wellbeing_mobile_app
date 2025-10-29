// lib/models/user_data.dart

import 'package:cloud_firestore/cloud_firestore.dart'; 

class UserData {
  final String username;
  final int age;
  final String primaryGoal;
  final DateTime createdAt;

  UserData({
    required this.username,
    required this.age,
    required this.primaryGoal,
    required this.createdAt,
  });

  factory UserData.fromMap(Map<String, dynamic> data) {
    final timestamp = data['createdAt'];
    DateTime date;
    
    // Handle Firebase Timestamp conversion
    if (timestamp is DateTime) {
      date = timestamp;
    } else if (timestamp != null && timestamp.runtimeType.toString().contains('Timestamp')) {
      date = (timestamp as Timestamp).toDate();
    } else {
      date = DateTime.now(); // Fallback
    }

    return UserData(
      username: data['username'] as String? ?? 'N/A',
      age: data['age'] as int? ?? 0,
      primaryGoal: data['primaryGoal'] as String? ?? 'N/A',
      createdAt: date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'age': age,
      'primaryGoal': primaryGoal,
    };
  }
}
