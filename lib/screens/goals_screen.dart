// lib/screens/goals_screen.dart
import 'package:flutter/material.dart';
import 'package:wellbeing_mobile_app/theme/app_colors.dart';
import '../models/goal_model.dart';
import '../services/goal_service.dart';
import 'add_edit_goal_screen.dart'; // We will create this next

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> with SingleTickerProviderStateMixin {
  final GoalService _goalService = GoalService();
  List<Goal> _goals = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadGoals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Load goals from the service
  Future<void> _loadGoals() async {
    setState(() {
      _isLoading = true;
    });
    
    final loadedGoals = await _goalService.getGoals();
    
    // Sort active goals first, then by target date
    loadedGoals.sort((a, b) {
      // 1. Prioritize active goals
      if (a.status == GoalStatus.active && b.status != GoalStatus.active) return -1;
      if (a.status != GoalStatus.active && b.status == GoalStatus.active) return 1;
      
      // 2. Sort by target date (active goals first)
      if (a.targetDate != null && b.targetDate != null) {
        return a.targetDate!.compareTo(b.targetDate!);
      }
      return 0;
    });

    if (mounted) {
      setState(() {
        _goals = loadedGoals;
        _isLoading = false;
      });
    }
  }

  // Helper method to navigate to the Add/Edit screen
  Future<void> _navigateToAddEditGoal({Goal? goal}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditGoalScreen(goal: goal),
      ),
    );
    // If the goal was saved (result == true), reload the list
    if (result == true) {
      _loadGoals();
    }
  }

  // --- Widget Builders ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Goals'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: AppColors.textSubtle,
          indicatorColor: AppColors.primaryColor,
          tabs: const [
            Tab(text: 'Active Goals', icon: Icon(Icons.star)),
            Tab(text: 'Completed/Archived', icon: Icon(Icons.archive)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildGoalList(GoalStatus.active),
                _buildGoalList([GoalStatus.completed, GoalStatus.deferred, GoalStatus.abandoned]),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddEditGoal(),
        label: const Text('New Goal'),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }
  
  // Renders the list of goals based on the required status(es)
  Widget _buildGoalList(dynamic statuses) {
    List<GoalStatus> filterStatuses;
    if (statuses is GoalStatus) {
      filterStatuses = [statuses];
    } else if (statuses is List<GoalStatus>) {
      filterStatuses = statuses;
    } else {
      filterStatuses = []; // Should not happen
    }
    
    final filteredGoals = _goals.where((g) => filterStatuses.contains(g.status)).toList();

    if (filteredGoals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            filterStatuses.contains(GoalStatus.active)
                ? 'You don\'t have any active goals right now. Tap the "+" button to set one!'
                : 'No archived goals found. Completed and past goals will show up here.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: AppColors.textSubtle),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80.0, top: 8.0), // Space for FAB
      itemCount: filteredGoals.length,
      itemBuilder: (context, index) {
        final goal = filteredGoals[index];
        return _buildGoalListItem(goal);
      },
    );
  }

  // Renders a single goal item in the list
  Widget _buildGoalListItem(Goal goal) {
    final statusColor = goal.status == GoalStatus.active ? AppColors.primaryColor : 
                        goal.status == GoalStatus.completed ? AppColors.success : 
                        AppColors.textSubtle;
                        
    final progressColor = goal.progress == 100 ? AppColors.accent : statusColor;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: ListTile(
        onTap: () => _navigateToAddEditGoal(goal: goal),
        leading: CircleAvatar(
          backgroundColor: progressColor.withOpacity(0.1),
          child: Text('${goal.progress}%', style: TextStyle(color: progressColor, fontWeight: FontWeight.bold)),
        ),
        title: Text(
          goal.title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (goal.targetDate != null)
              Text(
                'Target: ${DateFormat('MMM d, yyyy').format(goal.targetDate!)}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSubtle),
              ),
            Text(
              'Status: ${goal.status.toString().split('.').last.toUpperCase()}',
              style: TextStyle(fontSize: 12, color: statusColor, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSubtle),
      ),
    );
  }
}
