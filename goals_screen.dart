// File: goals_screen.dart

import 'package:flutter/material.dart';

// --- MOCK DATA STRUCTURE ---
class Goal {
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final int progressPercent;
  final Color color;

  Goal({
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.progressPercent,
    required this.color,
  });
}

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  // Mock list of current user goals
  final List<Goal> _userGoals = [
    Goal(
      title: 'Learn a New Language (Spanish)',
      description: 'Complete 30 minutes of DuoLingo/practice daily.',
      startDate: DateTime(2025, 9, 25),
      endDate: DateTime(2026, 3, 25),
      progressPercent: 25,
      color: Colors.red.shade400,
    ),
    Goal(
      title: 'Complete 10k Steps Daily',
      description: 'Hit the goal every day for a 30-day streak.',
      startDate: DateTime(2025, 10, 1),
      endDate: DateTime(2025, 10, 31),
      progressPercent: 75,
      color: Colors.green.shade600,
    ),
    Goal(
      title: 'Read 2 Books this Month',
      description: 'Finish "The Power of Habit" and "Deep Work".',
      startDate: DateTime(2025, 10, 1),
      endDate: DateTime(2025, 10, 31),
      progressPercent: 50,
      color: Colors.blue.shade600,
    ),
  ];
  
  // Placeholder function for adding a new goal
  void _addNewGoal() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigation to Add New Goal Form (Pending)...'))
    );
  }

  // Placeholder function for managing a specific goal
  void _manageGoal(Goal goal) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening detailed view for: ${goal.title}'))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // NOTE: We don't use an AppBar here because the MainAppScaffold already has one,
      // and we want the goals list to start immediately under the main navigation.
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 16.0, bottom: 80.0), // Padding for FloatingActionButton clearance
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Text(
                'My Wellbeing Goals',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade800,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
              child: Text(
                'You have ${_userGoals.length} active goals. Keep pushing!',
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 16),
            
            // Build the list of Goal Cards
            ..._userGoals.map((goal) {
              final int totalDays = goal.endDate.difference(goal.startDate).inDays;
              final int elapsedDays = DateTime.now().difference(goal.startDate).inDays;
              final int remainingDays = totalDays - elapsedDays;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0, left: 16.0, right: 16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    onTap: () => _manageGoal(goal),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Goal Title
                          Text(
                            goal.title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: goal.color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Goal Description/Metric
                          Text(
                            goal.description,
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                          const SizedBox(height: 12),
                          
                          // Progress Bar
                          LinearProgressIndicator(
                            value: goal.progressPercent / 100,
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade200,
                            color: goal.color,
                          ),
                          const SizedBox(height: 8),

                          // Progress Text
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${goal.progressPercent}% Complete',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                remainingDays < 0 ? 'Overdue' : '$remainingDays days left',
                                style: TextStyle(
                                  color: remainingDays < 7 ? Colors.red : Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
      
      // Floating Action Button to add new goals
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewGoal,
        label: const Text('New Goal'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
