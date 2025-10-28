// lib/models/wellbeing_entry.dart

class WellbeingEntry {
  final int waterIntake; 
  final String gratitudePrompt;
  
  WellbeingEntry({
    required this.waterIntake, 
    required this.gratitudePrompt,
  });

  /// Converts the WellbeingEntry object into a JSON-compatible Map 
  /// for saving to Firestore.
  Map<String, dynamic> toJson() {
    return {
      'waterIntake': waterIntake,
      'gratitudePrompt': gratitudePrompt,
    };
  }
}