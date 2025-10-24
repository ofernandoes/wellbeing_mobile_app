import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';

class WellbeingApiService {
  // CRITICAL: Set to Android Emulator alias (10.0.2.2) to reach Flask server running on host.

// In api_service.dart
final String _baseUrl = 'http://localhost:5000/api/log_entry';

  Future<bool> logWellbeingEntry({
    required int moodScore,
    required int sleepScore,
    required int exerciseScore,
    String notes = '',
  }) async {
    // 1. Prepare data in the JSON structure expected by Flask's WellbeingEntry model
    final Map<String, dynamic> data = {
      'mood_score': moodScore,
      'sleep_score': sleepScore,
      'exercise_score': exerciseScore,
      'notes': notes,
    };

    try {
      // 2. Send POST request to the Flask endpoint
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      // 3. Check for successful creation status (201 Created)
      if (response.statusCode == 201) {
        debugPrint('Entry logged successfully to Flask: ${response.body}');
        return true;
      } else {
        debugPrint('Failed to log entry. Status: ${response.statusCode}, Body: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Network or serialization error: $e');
      return false;
    }
  }
}
