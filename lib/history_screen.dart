import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wellbeing_mobile_app/theme/app_colors.dart';
import 'services/checkin_service.dart'; // Import the service and model
import 'checkin_detail_screen.dart';    // <--- Ensure this is imported

// ----------------------------------------------------------------------
// HISTORY SCREEN
// ----------------------------------------------------------------------

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<DailyCheckin> _checkinHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCheckinHistory();
  }

  Future<void> _loadCheckinHistory() async {
    setState(() {
      _isLoading = true;
    });

    final service = CheckinService();
    // Fetch all check-in entries
    final history = await service.getCheckinHistory();

    // Sort to display the newest entries first
    history.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (mounted) {
      setState(() {
        _checkinHistory = history;
        _isLoading = false;
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in History'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _checkinHistory.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'No check-ins recorded yet. Start your journey from the Home screen!',
                      style: TextStyle(color: AppColors.textSubtle, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _checkinHistory.length,
                  itemBuilder: (context, index) {
                    final checkin = _checkinHistory[index];
                    final formattedDate = DateFormat('EEEE, MMM d, yyyy h:mm a').format(checkin.timestamp);
                    final moodIcon = _getMoodIcon(checkin.moodScore);
                    final moodColor = _getMoodColor(checkin.moodScore);

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Icon(moodIcon, color: moodColor, size: 36),
                        title: Text(
                          formattedDate,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          checkin.notes.isNotEmpty 
                            ? checkin.notes 
                            : 'No notes recorded.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.textSubtle),
                        ),
                        trailing: Text(
                          'Score: ${checkin.moodScore}/5',
                          style: TextStyle(fontWeight: FontWeight.bold, color: moodColor),
                        ),
                        // --- UPDATED NAVIGATION LOGIC HERE ---
                        onTap: () {
                          // Navigate to the detail screen and pass the check-in data
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CheckinDetailScreen(
                                checkin: checkin,
                                // Pass the refresh function so the detail screen can reload history if something changes
                                onCheckinUpdated: _loadCheckinHistory, 
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}