// lib/daily_checkin_screen.dart

import 'package:flutter/material.dart';
import 'package:wellbeing_mobile_app/theme/app_colors.dart';
import '../services/checkin_service.dart';

// ----------------------------------------------------------------------
// DAILY CHECK-IN SCREEN (Now also used for EDITING)
// ----------------------------------------------------------------------

class DailyCheckinScreen extends StatefulWidget {
  // Optional parameter for editing an existing check-in
  final DailyCheckin? checkinToEdit;

  const DailyCheckinScreen({
    super.key,
    this.checkinToEdit, // Null if creating new, present if editing
  });

  @override
  State<DailyCheckinScreen> createState() => _DailyCheckinScreenState();
}

class _DailyCheckinScreenState extends State<DailyCheckinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  int _selectedMoodScore = 3; // Default to neutral

  @override
  void initState() {
    super.initState();
    // If we are editing, initialize the form fields with existing data
    if (widget.checkinToEdit != null) {
      _selectedMoodScore = widget.checkinToEdit!.moodScore;
      _notesController.text = widget.checkinToEdit!.notes;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // Helper method to save/update the check-in
  Future<void> _saveCheckin() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final service = CheckinService();

      String successMessage;

      if (widget.checkinToEdit == null) {
        // --- NEW CHECK-IN (CREATE) ---
        final newCheckin = DailyCheckin(
          // CRITICAL FIX: Firestore generates the ID, so we use a temporary placeholder 'new'
          // The CheckinService knows to ignore this ID when calling .add()
          id: 'new', 
          timestamp: DateTime.now(),
          moodScore: _selectedMoodScore,
          notes: _notesController.text.trim(),
        );
        await service.saveCheckin(newCheckin);
        successMessage = 'Mood check-in saved to Cloud Firestore!';
      } else {
        // --- EXISTING CHECK-IN (UPDATE) ---
        final updatedCheckin = DailyCheckin(
          id: widget.checkinToEdit!.id,
          // Keep the original timestamp for historical accuracy
          timestamp: widget.checkinToEdit!.timestamp,
          moodScore: _selectedMoodScore,
          notes: _notesController.text.trim(),
        );
        await service.updateCheckin(updatedCheckin);
        successMessage = 'Check-in successfully updated!';
      }

      // Show success message and navigate back
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage)),
        );
        Navigator.pop(context, true); // Pop with 'true' to indicate a change was made
      }
    }
  }

  // Helper function to return icon based on score
  IconData _getMoodIcon(int score) {
    switch (score) {
      case 5: return Icons.sentiment_very_satisfied;
      case 4: return Icons.sentiment_satisfied;
      case 3: return Icons.sentiment_neutral;
      case 2: return Icons.sentiment_dissatisfied;
      case 1: return Icons.sentiment_very_dissatisfied;
      default: return Icons.sentiment_neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.checkinToEdit != null;
    final String title = isEditing ? 'Edit Check-in' : 'Daily Check-in';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[

              // 1. Mood Selection
              Text(
                '1. How are you feeling right now?',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 20),

              // Mood Slider/Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(5, (index) {
                  final score = index + 1;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMoodScore = score;
                      });
                    },
                    child: Column(
                      children: [
                        Icon(
                          _getMoodIcon(score),
                          size: 48,
                          color: _selectedMoodScore == score
                              ? AppColors.accent
                              : AppColors.textSubtle.withAlpha((255 * 0.5).round()),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$score',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _selectedMoodScore == score
                                ? AppColors.accent
                                : AppColors.textSubtle,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),

              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 20),

              // 2. Notes Section
              Text(
                '2. Notes (What’s on your mind?)',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Optional: Write down any thoughts, goals, or concerns.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: AppColors.secondary,
                ),
                maxLines: 5,
                keyboardType: TextInputType.multiline,
              ),

              const SizedBox(height: 40),

              // Save Button
              ElevatedButton.icon(
                onPressed: _saveCheckin,
                icon: Icon(isEditing ? Icons.save : Icons.check),
                label: Text(isEditing ? 'Update Check-in' : 'Submit Check-in'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}