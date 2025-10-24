import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wellbeing_mobile_app/theme/app_colors.dart';
import '../services/checkin_service.dart'; // Corrected

// ADD THIS LINE:
import 'daily_checkin_screen.dart'; // Assumes the file is at the same level (lib/)

// ----------------------------------------------------------------------
// CHECKIN DETAIL SCREEN
// ----------------------------------------------------------------------

class CheckinDetailScreen extends StatelessWidget {
  final DailyCheckin checkin;
  final Function() onCheckinUpdated; // Callback to refresh history screen

  const CheckinDetailScreen({
    super.key,
    required this.checkin,
    required this.onCheckinUpdated,
  });

  // Helper method to determine the icon based on the mood score
  IconData _getMoodIcon(int score) {
    switch (score) {
      case 5: return Icons.sentiment_very_satisfied;
      case 4: return Icons.sentiment_satisfied;
      case 3: return Icons.sentiment_neutral;
      case 2: return Icons.sentiment_dissatisfied;
      case 1: return Icons.sentiment_very_dissatisfied;
      default: return Icons.help_outline;
    }
  }

  // Helper method to determine the color based on the mood score
  Color _getMoodColor(int score) {
    switch (score) {
      case 5: return AppColors.accent;
      case 4: return AppColors.success;
      case 3: return AppColors.textSubtle;
      case 2: return AppColors.warning;
      case 1: return AppColors.error;
      default: return AppColors.textDark;
    }
  }

  // --- UPDATED NAVIGATION LOGIC (Fix applied here) ---
  void _editCheckin(BuildContext context) async {
    // Line 63 (approx)
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DailyCheckinScreen(
          checkinToEdit: checkin, // Pass the current check-in data to the editor
        ),
      ),
    );

    // Check if the widget is still in the tree after the async operation
    if (!context.mounted) return; // FIX: Prevents using context across the async gap

    // If the check-in was successfully updated (DailyCheckinScreen returns 'true')
    if (result == true) {
      // 1. Call the callback function provided by the HistoryScreen to reload its data.
      onCheckinUpdated();
      
      // 2. Pop the detail screen to automatically show the updated list in the HistoryScreen.
      // Line 71 (approx)
      Navigator.of(context).pop(); 
    }
  }
  // --------------------------------

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, MMM d, yyyy \n(h:mm:ss a)').format(checkin.timestamp);
    final moodIcon = _getMoodIcon(checkin.moodScore);
    final moodColor = _getMoodColor(checkin.moodScore);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in Details'),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editCheckin(context), // Wires up the new function
            tooltip: 'Edit Check-in',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Mood and Date Header
            Row(
              children: [
                Icon(moodIcon, color: moodColor, size: 60),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mood Score: ${checkin.moodScore}/5',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: moodColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSubtle,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 30),
            const Divider(),
            
            // Notes Section
            const Text(
              'Detailed Notes:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                checkin.notes.isNotEmpty ? checkin.notes : 'No detailed notes were recorded for this entry.',
                style: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 40),
            // Placeholder for Future Content (e.g., related goals or advice)
            const Text(
              'Related Coaching Insights (Future Feature)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Based on a score of ${checkin.moodScore}, a personalized recommendation could be displayed here.',
              style: const TextStyle(color: AppColors.textSubtle),
            ),
          ],
        ),
      ),
    );
  }
}