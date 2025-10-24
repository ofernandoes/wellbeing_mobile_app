// lib/models/goal_model.dart
import 'package:uuid/uuid.dart';

class Goal {
  final String id;
  String title;
  String description;
  DateTime startDate;
  DateTime? targetDate;
  int progress; // Percentage (0 to 100)
  GoalStatus status;

  Goal({
    String? id,
    required this.title,
    required this.description,
    required this.startDate,
    this.targetDate,
    this.progress = 0,
    this.status = GoalStatus.active,
  }) : id = id ?? const Uuid().v4();

  // Convert a Goal object to a JSON map
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'startDate': startDate.toIso8601String(),
        'targetDate': targetDate?.toIso8601String(),
        'progress': progress,
        'status': status.toString().split('.').last, // Convert enum to string
      };

  // Create a Goal object from a JSON map
  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      targetDate: json['targetDate'] != null ? DateTime.parse(json['targetDate'] as String) : null,
      progress: json['progress'] as int,
      status: GoalStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => GoalStatus.active,
      ),
    );
  }
}

enum GoalStatus {
  active,
  completed,
  deferred,
  abandoned,
}
