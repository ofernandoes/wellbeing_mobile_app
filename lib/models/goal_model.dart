// lib/models/goal_model.dart

// Define the Status Enum here (only place needed)
enum GoalStatus { active, completed, deferred, abandoned }

class Goal {
  final String id;
  final String title;
  final String description;
  final bool isCompleted; 
  final String category;
  final int targetValue; 
  // Add the new fields required by the screens
  final DateTime startDate;
  final DateTime? targetDate;
  final int progress;
  final GoalStatus status;

  Goal({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.category,
    required this.targetValue,
    required this.startDate,
    this.targetDate,
    this.progress = 0,
    this.status = GoalStatus.active,
  });

  // 1. JSON Deserialization (Constructor from Map)
  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      isCompleted: json['isCompleted'] as bool,
      category: json['category'] as String,
      targetValue: json['targetValue'] as int,
      // Deserialize new fields
      startDate: DateTime.parse(json['startDate'] as String),
      targetDate: json['targetDate'] != null ? DateTime.parse(json['targetDate'] as String) : null,
      progress: json['progress'] as int,
      status: GoalStatus.values.firstWhere((e) => e.toString() == json['status']),
    );
  }

  // 2. JSON Serialization (Method to Map)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'category': category,
      'targetValue': targetValue,
      // Serialize new fields
      'startDate': startDate.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
      'progress': progress,
      'status': status.toString(),
    };
  }

  // 3. Helper method for updates
  Goal copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    String? category,
    int? targetValue,
    DateTime? startDate,
    DateTime? targetDate,
    int? progress,
    GoalStatus? status,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      targetValue: targetValue ?? this.targetValue,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      progress: progress ?? this.progress,
      status: status ?? this.status,
    );
  }
  
  // 4. Method to toggle completion status
  Goal toggleCompletion() {
    return copyWith(isCompleted: !isCompleted);
  }
}