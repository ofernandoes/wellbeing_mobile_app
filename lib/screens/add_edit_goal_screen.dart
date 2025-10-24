// lib/screens/add_edit_goal_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart'; // Required for generating unique IDs for new goals
import 'package:wellbeing_mobile_app/theme/app_colors.dart';
import '../models/goal_model.dart';
// FIX: Using alias 'as service' to resolve ambiguity
import '../services/goal_service.dart' as service; 

const uuid = Uuid(); // Instantiate Uuid generator

class AddEditGoalScreen extends StatefulWidget {
  // Use the Goal model from the models folder
  final Goal? goal; 

  const AddEditGoalScreen({super.key, this.goal});

  @override
  State<AddEditGoalScreen> createState() => _AddEditGoalScreenState();
}

class _AddEditGoalScreenState extends State<AddEditGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  // FIX: Use service alias for GoalService type and constructor
  final service.GoalService _goalService = service.GoalService();
  
  // State variables for goal fields
  late String _title;
  late String _description;
  late DateTime _startDate;
  DateTime? _targetDate;
  late int _progress;
  late GoalStatus _status;

  @override
  void initState() {
    super.initState();
    // Initialize fields based on whether we are editing or adding
    final goal = widget.goal;
    if (goal != null) {
      _title = goal.title;
      _description = goal.description;
      _startDate = goal.startDate;
      _targetDate = goal.targetDate;
      _progress = goal.progress;
      _status = goal.status;
    } else {
      _title = '';
      _description = '';
      _startDate = DateTime.now();
      _targetDate = null;
      _progress = 0;
      _status = GoalStatus.active;
    }
  }

  // --- Helper Methods ---
  
  // Method to handle saving the goal
  Future<void> _saveGoal() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // Determine ID: use existing or generate new one
      final String goalId = widget.goal?.id ?? uuid.v4(); 
      // Determine Category: a placeholder, as the screen doesn't have a selector
      final String goalCategory = widget.goal?.category ?? 'General';
      
      final Goal newGoal = Goal(
        id: goalId, 
        title: _title,
        description: _description,
        startDate: _startDate,
        targetDate: _targetDate,
        progress: _progress,
        status: _status,
        // Since isCompleted and targetValue are needed for the model but not directly set here, 
        // we'll default them or inherit from the old goal.
        isCompleted: _progress == 100,
        category: goalCategory,
        targetValue: widget.goal?.targetValue ?? 1, // Placeholder
      );

      // FIX: Call the service using the alias
      await _goalService.saveGoal(newGoal);
      
      if (mounted) {
        Navigator.pop(context, true); 
      }
    }
  }
  
  // Method to handle deleting the goal
  Future<void> _deleteGoal() async {
    if (widget.goal == null) return;
    
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this goal? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // FIX: Call the service using the alias
      await _goalService.deleteGoal(widget.goal!.id);
      
      if (mounted) {
        Navigator.pop(context, true); 
      }
    }
  }
  
  // Method to show the date picker for the target date
  Future<void> _selectTargetDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: _startDate, 
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)), // 10 years out
    );
    if (picked != null && picked != _targetDate) {
      setState(() {
        _targetDate = picked;
      });
    }
  }


  // --- Widget Builders ---
  
  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.goal != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Goal' : 'New Goal'),
        actions: [
          if (isEditing) 
            IconButton(
              icon: const Icon(Icons.delete_forever, color: AppColors.error),
              onPressed: _deleteGoal,
            ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveGoal,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // 1. Title Field
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(
                  labelText: 'Goal Title',
                  hintText: 'e.g., Run a 5K, Meditate Daily',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a goal title';
                  }
                  return null;
                },
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 16),
              
              // 2. Description Field
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(
                  labelText: 'Description / Details',
                  hintText: 'What steps will you take to achieve this goal?',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                onSaved: (value) => _description = value!,
              ),
              const SizedBox(height: 24),

              // 3. Target Date Selector
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Target Completion Date',
                  style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  _targetDate == null 
                    ? 'Optional: Tap to set a deadline' 
                    : DateFormat('EEEE, MMM d, yyyy').format(_targetDate!),
                  style: TextStyle(
                    color: _targetDate == null ? AppColors.textSubtle : AppColors.primaryColor,
                    fontSize: 16,
                  ),
                ),
                trailing: Icon(
                  _targetDate == null ? Icons.calendar_today : Icons.edit,
                  color: AppColors.primaryColor,
                ),
                onTap: _selectTargetDate,
              ),
              const Divider(height: 0),
              const SizedBox(height: 24),
              
              // 4. Progress Slider
              Text(
                'Progress: $_progress%',
                style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600),
              ),
              Slider(
                value: _progress.toDouble(),
                min: 0,
                max: 100,
                divisions: 20, // 5% increments
                label: '$_progress%',
                activeColor: AppColors.primaryColor,
                onChanged: (double value) {
                  setState(() {
                    _progress = value.round();
                    // Auto-update status if progress hits 100%
                    if (_progress == 100 && _status != GoalStatus.completed) {
                      _status = GoalStatus.completed;
                    } else if (_progress < 100 && _status == GoalStatus.completed) {
                      _status = GoalStatus.active;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // 5. Status Dropdown
              DropdownButtonFormField<GoalStatus>(
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                initialValue: _status,
                items: GoalStatus.values.map((GoalStatus status) {
                  return DropdownMenuItem<GoalStatus>(
                    value: status,
                    child: Text(
                      status.toString().split('.').last.toUpperCase(),
                      style: TextStyle(
                        color: status == GoalStatus.active ? AppColors.primaryColor :
                               status == GoalStatus.completed ? AppColors.success :
                               AppColors.textSubtle,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (GoalStatus? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _status = newValue;
                      // Keep progress consistent with status
                      if (newValue == GoalStatus.completed) {
                        _progress = 100;
                      } else if (newValue == GoalStatus.active && _progress == 100) {
                        _progress = 99; // Assume progress is less than 100 if moving back to active
                      }
                    });
                  }
                },
                onSaved: (value) => _status = value ?? GoalStatus.active,
              ),
            ],
          ),
        ),
      ),
    );
  }
}