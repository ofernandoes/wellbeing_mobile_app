// lib/history_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wellbeing_mobile_app/theme/app_colors.dart';
import '../services/checkin_service.dart';
import 'daily_checkin_screen.dart'; // Used for editing existing check-ins

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Instantiate the service to access the Firestore stream
    final CheckinService checkinService = CheckinService();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in History'),
        backgroundColor: AppColors.primaryColor,
      ),
      
      // CRITICAL: Use StreamBuilder to listen for all check-ins in real-time
      body: StreamBuilder<List<DailyCheckin>>(
        // Call the new stream function from the Firestore service
        stream: checkinService.getCheckinsStream(),
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading history: ${snapshot.error}'));
          }
          
          // Data is ready (list of DailyCheckin objects)
          final List<DailyCheckin> history = snapshot.data ?? [];
          
          if (history.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.history_toggle_off, size: 60, color: AppColors.textSubtle),
                    const SizedBox(height: 10),
                    Text(
                      'No check-ins recorded yet.',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    const Text('Start tracking your mood by creating your first daily check-in.'),
                  ],
                ),
              ),
            );
          }
          
          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final checkin = history[index];
              // DateFormat is now available because you added the 'intl' package
              final formattedDate = DateFormat('EEEE, MMM d, yyyy h:mm a').format(checkin.timestamp);
              
              // Map mood score to an icon/label
              final moodText = checkin.moodScore == 5 ? 'Great' : 
                               checkin.moodScore == 4 ? 'Good' : 
                               checkin.moodScore == 3 ? 'Okay' : 
                               checkin.moodScore == 2 ? 'Bad' : 'Awful';
              final moodColor = checkin.moodScore == 5 ? AppColors.accent : 
                                checkin.moodScore == 4 ? AppColors.success : 
                                checkin.moodScore == 3 ? AppColors.textSubtle : 
                                checkin.moodScore == 2 ? AppColors.warning : AppColors.error;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                child: ListTile(
                  leading: Icon(
                    _getMoodIcon(checkin.moodScore),
                    color: moodColor,
                    size: 30,
                  ),
                  title: Text(
                    '$moodText (Score ${checkin.moodScore})',
                    style: TextStyle(fontWeight: FontWeight.bold, color: moodColor),
                  ),
                  subtitle: Text(
                    '$formattedDate\n${checkin.notes.isNotEmpty ? checkin.notes : 'No notes recorded.'}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.edit, color: AppColors.textSubtle),
                  onTap: () {
                    // Navigate to DailyCheckinScreen for editing
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DailyCheckinScreen(
                          checkinToEdit: checkin,
                        ),
                      ),
                    );
                    // The StreamBuilder will automatically rebuild the list when the item is updated/saved.
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Helper function reused from daily_checkin_screen
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
}