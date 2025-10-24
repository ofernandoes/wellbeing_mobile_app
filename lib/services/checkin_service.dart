import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// ----------------------------------------------------------------------
// 1. UPDATED DATA MODEL (DailyCheckin)
//    - Added 'id' field for unique identification
// ----------------------------------------------------------------------

// Model to structure the Check-in data
class DailyCheckin {
  final String id; // Unique ID for updating and deleting
  final DateTime timestamp;
  final int moodScore; // 1 (Worst) to 5 (Best)
  final String notes;

  DailyCheckin({
    required this.id, // Must be included
    required this.timestamp,
    required this.moodScore,
    required this.notes,
  });

  // Convert a DailyCheckin object to a JSON map
  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'moodScore': moodScore,
        'notes': notes,
      };

  // Create a DailyCheckin object from a JSON map
  factory DailyCheckin.fromJson(Map<String, dynamic> json) {
    return DailyCheckin(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      moodScore: json['moodScore'] as int,
      notes: json['notes'] as String,
    );
  }
}

// ----------------------------------------------------------------------
// 2. UPDATED SERVICE CLASS (CheckinService)
//    - Now uses a single String key to store the JSON-encoded list.
//    - Includes save (create), get, update, and delete logic.
// ----------------------------------------------------------------------

// Service class to handle data persistence
class CheckinService {
  // Switched to storing as a single JSON string for easier update/delete operations
  static const _historyKey = 'dailyCheckinHistory';

  // Helper to fetch the current list of check-ins from storage
  Future<List<DailyCheckin>> _fetchCurrentHistory(SharedPreferences prefs) async {
    final String? jsonString = prefs.getString(_historyKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => DailyCheckin.fromJson(json)).toList();
    }
    return [];
  }
  
  // Helper to save the entire list back to storage
  Future<void> _saveHistory(SharedPreferences prefs, List<DailyCheckin> history) async {
    final List<Map<String, dynamic>> jsonList = history.map((e) => e.toJson()).toList();
    await prefs.setString(_historyKey, jsonEncode(jsonList));
  }


  // ------------------------------------
  // CRUD OPERATIONS
  // ------------------------------------

  // 1. CREATE (Saves a new check-in entry)
  Future<void> saveCheckin(DailyCheckin checkin) async {
    final prefs = await SharedPreferences.getInstance(); 
    List<DailyCheckin> history = await _fetchCurrentHistory(prefs);
    
    // Add the new entry to the list
    history.add(checkin);
    
    // Save the updated list
    await _saveHistory(prefs, history);
  }

  // 2. READ (Retrieves all check-in entries)
  Future<List<DailyCheckin>> getCheckinHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return await _fetchCurrentHistory(prefs);
  }

  // 3. UPDATE (Updates an existing check-in entry by ID)
  Future<void> updateCheckin(DailyCheckin updatedCheckin) async {
    final prefs = await SharedPreferences.getInstance();
    List<DailyCheckin> history = await _fetchCurrentHistory(prefs);

    // Find the index of the check-in to update
    final index = history.indexWhere((checkin) => checkin.id == updatedCheckin.id);

    if (index != -1) {
      // Replace the old check-in with the updated one
      history[index] = updatedCheckin;
      // Save the modified list back to storage
      await _saveHistory(prefs, history);
    }
  }

  // 4. DELETE (Deletes a check-in entry by ID)
  Future<void> deleteCheckin(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<DailyCheckin> history = await _fetchCurrentHistory(prefs);

    // Remove the item with the matching ID
    history.removeWhere((checkin) => checkin.id == id);

    // Save the updated list back to storage
    await _saveHistory(prefs, history);
  }
}