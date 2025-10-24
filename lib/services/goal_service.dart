// lib/services/goal_service.dart
import '../models/goal_model.dart'; // Import the Goal model you defined

class GoalService {
  // This list will simulate a database/backend store
  final List<Goal> _goals = []; 

  // Singleton pattern (Optional, but common for service classes)
  static final GoalService _instance = GoalService._internal();
  factory GoalService() => _instance;
  GoalService._internal();

  // --- Methods to satisfy potential usages in screens ---

  // Fetches all goals (used by goals_screen)
  Future<List<Goal>> getGoals() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 50)); 
    return _goals;
  }

  // Adds or updates a goal (used by add_edit_goal_screen)
  Future<void> saveGoal(Goal goal) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 50));
    
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index >= 0) {
      // Update existing goal
      _goals[index] = goal;
    } else {
      // Add new goal
      _goals.add(goal);
    }
  }

  // Deletes a goal
  Future<void> deleteGoal(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _goals.removeWhere((g) => g.id == id);
  }
}