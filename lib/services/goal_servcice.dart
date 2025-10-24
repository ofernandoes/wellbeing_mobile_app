// lib/services/goal_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/goal_model.dart'; // Import the new Goal model

class GoalService {
  static const _goalsKey = 'goal_history';

  // --- Utility Method ---
  Future<SharedPreferences> _getPrefs() async {
    return SharedPreferences.getInstance();
  }

  // --- CRUD Operations ---

  // 1. Get All Goals
  Future<List<Goal>> getGoals() async {
    final prefs = await _getPrefs();
    final goalsJson = prefs.getStringList(_goalsKey);

    if (goalsJson == null) {
      return [];
    }

    return goalsJson.map((jsonString) {
      final jsonMap = json.decode(jsonString);
      return Goal.fromJson(jsonMap);
    }).toList();
  }

  // 2. Save/Update Goal
  Future<void> saveGoal(Goal goal) async {
    final prefs = await _getPrefs();
    final List<Goal> currentGoals = await getGoals();

    // Remove the old version if it exists (for updates)
    currentGoals.removeWhere((g) => g.id == goal.id);

    // Add the new/updated goal
    currentGoals.add(goal);

    // Convert the entire list back to a list of JSON strings
    final goalsJsonList = currentGoals.map((g) => json.encode(g.toJson())).toList();

    await prefs.setStringList(_goalsKey, goalsJsonList);
  }

  // 3. Delete Goal
  Future<void> deleteGoal(String goalId) async {
    final prefs = await _getPrefs();
    final List<Goal> currentGoals = await getGoals();

    // Filter out the goal to be deleted
    currentGoals.removeWhere((g) => g.id == goalId);

    // Convert the remaining list back to a list of JSON strings
    final goalsJsonList = currentGoals.map((g) => json.encode(g.toJson())).toList();

    await prefs.setStringList(_goalsKey, goalsJsonList);
  }
}
