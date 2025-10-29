// lib/checkin_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wellbeing_mobile_app/theme/app_colors.dart';
// CRITICAL FIX: Add the correct model import
import 'package:wellbeing_mobile_app/models/daily_checkin_model.dart';

class CheckinDetailScreen extends StatefulWidget {
  // FIX: Rename parameter from 'checkinToEdit' to 'checkin' 
  final DailyCheckin? checkin;

  // FIX: Update constructor to use the 'checkin' parameter
  const CheckinDetailScreen({super.key, this.checkin}); 

  @override
  State<CheckinDetailScreen> createState() => _CheckinDetailScreenState();
}

class _CheckinDetailScreenState extends State<CheckinDetailScreen> {
  // Simple view/edit screen variables
  late DailyCheckin _currentCheckin;
  late TextEditingController _noteController;
  late int _moodScore;

  @override
  void initState() {
    super.initState();
    // Use the passed checkin or create a new dummy one for viewing/editing structure
    _currentCheckin = widget.checkin ?? DailyCheckin(
      userId: 'N/A', 
      date: DateTime.now(), 
      moodScore: 3, 
      note: 'No details available.',
    );
    _moodScore = _currentCheckin.moodScore;
    _noteController = TextEditingController(text: _currentCheckin.note);
  }

  // Helper function to get the descriptive mood label
  String _getMoodLabel(int score) {
    switch (score) {
      case 1: return 'Terrible 😞';
      case 2: return 'Bad 🙁';
      case 3: return 'Okay 😐';
      case 4: return 'Good 🙂';
      case 5: return 'Excellent 😄';
      default: return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          // Display the date being viewed/edited
          'Details for ${DateFormat('MMM d, y').format(_currentCheckin.date)}',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Mood Score
            Text(
              'Mood: ${_getMoodLabel(_moodScore)}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
            ),
            const SizedBox(height: 10),
            
            // Activities List (A simple display for now)
            const Text(
              'Activities Completed:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 5),
            Wrap(
              spacing: 8.0,
              children: _currentCheckin.activities.isEmpty
                  ? [const Chip(label: Text('No activities recorded'))]
                  : _currentCheckin.activities.map((activity) => Chip(
                        label: Text(activity),
                        backgroundColor: AppColors.secondary,
                      )).toList(),
            ),
            const SizedBox(height: 20),

            // Note/Journal Entry
            const Text(
              'Journal Note:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _noteController.text.isEmpty ? '(No note recorded)' : _noteController.text,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 40),

            // Placeholder button - If editing is required, this should navigate back to DailyCheckinScreen for editing
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // In a real app, this would be a detailed edit screen or an update call
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                label: const Text('Back to History', style: TextStyle(fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
