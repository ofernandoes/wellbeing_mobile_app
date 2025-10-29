// lib/history_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wellbeing_mobile_app/theme/app_colors.dart';
// CRITICAL FIX: Update Imports to correct file names
import 'package:wellbeing_mobile_app/models/daily_checkin_model.dart';
import 'package:wellbeing_mobile_app/services/checkin_service.dart';
import 'package:wellbeing_mobile_app/daily_checkin_screen.dart'; // Screen to open for editing

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Check-in History'),
      ),
      // Use a StreamBuilder to display the real-time list of check-ins
      body: StreamBuilder<List<DailyCheckin>>(
        // CRITICAL FIX: Calling getCheckinsStream() correctly, and casting the type
        stream: CheckinService().getCheckinsStream(), 
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // 2. Error State
          if (snapshot.hasError) {
            return Center(child: Text('Error loading history: ${snapshot.error}'));
          }
          // 3. No Data (Empty) State
          final checkins = snapshot.data;
          if (checkins == null || checkins.isEmpty) {
            return const Center(
              child: Text('No check-ins recorded yet!'),
            );
          }

          // 4. Data Loaded State
          return ListView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: checkins.length,
            itemBuilder: (context, index) {
              final checkin = checkins[index];
              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  // Mood score icon on the left
                  leading: _buildMoodIcon(checkin.moodScore),
                  // Date and Mood
                  title: Text(
                    DateFormat('EEEE, MMM d, y').format(checkin.date),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mood: ${_getMoodLabel(checkin.moodScore)}', style: const TextStyle(fontSize: 14)),
                      if (checkin.note.isNotEmpty)
                        Text(
                          'Note: ${checkin.note}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontStyle: FontStyle.italic, color: AppColors.textSubtle),
                        ),
                    ],
                  ),
                  // Arrow to open for editing
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primaryColor),
                  onTap: () {
                    // CRITICAL FIX: Navigate to DailyCheckinScreen and pass the checkin object for editing
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DailyCheckinScreen(checkin: checkin), // Use 'checkin' parameter
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Helper function to get the descriptive mood label
  String _getMoodLabel(int score) {
    switch (score) {
      case 1:
        return 'Terrible 😞';
      case 2:
        return 'Bad 🙁';
      case 3:
        return 'Okay 😐';
      case 4:
        return 'Good 🙂';
      case 5:
        return 'Excellent 😄';
      default:
        return 'N/A';
    }
  }

  // Helper function to get the mood icon
  Widget _buildMoodIcon(int score) {
    IconData icon;
    Color color;
    switch (score) {
      case 5:
        icon = Icons.sentiment_very_satisfied;
        color = AppColors.success;
        break;
      case 4:
        icon = Icons.sentiment_satisfied;
        color = Colors.green;
        break;
      case 3:
        icon = Icons.sentiment_neutral;
        color = AppColors.warning;
        break;
      case 2:
        icon = Icons.sentiment_dissatisfied;
        color = AppColors.error;
        break;
      case 1:
        icon = Icons.sentiment_very_dissatisfied;
        color = Colors.red[900]!;
        break;
      default:
        icon = Icons.help_outline;
        color = Colors.grey;
    }
    return Icon(icon, color: color, size: 30);
  }
}
