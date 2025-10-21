import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wellbeing_mobile_app/theme/app_colors.dart';
import 'package:wellbeing_mobile_app/models/wellbeing_entry.dart';
import 'package:wellbeing_mobile_app/services/firestore_service.dart';

// Import mood options (to display the mood icon/color)
// NOTE: We rely on the options defined in entry_screen.dart, 
// so we'll re-define moodOptions here for simplicity. 
// In a large app, this would be in a central constants file.

const List<Map<String, dynamic>> moodOptions = [
  {'value': 1, 'label': 'Disaster Mode', 'subtitle': 'Rough day, but still standing.', 'color': Color(0xFFE57373), 'icon': '🚨'}, // Red
  {'value': 2, 'label': 'Low Battery', 'subtitle': 'Energy’s low; but still online.', 'color': Color(0xFFFFB74D), 'icon': '🔋'}, // Orange
  {'value': 3, 'label': 'Cruise Control', 'subtitle': 'Keeping pace, autopilot engaged.', 'color': Color(0xFFFFEB3B), 'icon': '🚗'}, // Yellow
  {'value': 4, 'label': 'Feeling Solid', 'subtitle': 'Focused and calm; just executing.', 'color': Color(0xFF64B5F6), 'icon': '👍'}, // Blue
  {'value': 5, 'label': 'Absolutely Stellar', 'subtitle': 'Running on pure momentum, everything’s clicking.', 'color': Color(0xFF81C784), 'icon': '✨'}, // Green
];


// Initialize the service
final FirestoreService _firestoreService = FirestoreService();

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Entry History'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.background,
        elevation: 0,
      ),
      // The StreamBuilder listens to the service for real-time data
      body: StreamBuilder<List<WellbeingEntry>>(
        stream: _firestoreService.getEntriesStream(),
        builder: (context, snapshot) {
          // 1. Handle Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.accent));
          }

          // 2. Handle Error State
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading data: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textDark),
              ),
            );
          }

          // 3. Handle No Data State
          final entries = snapshot.data;
          if (entries == null || entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.sentiment_dissatisfied, size: 50, color: AppColors.textSubtle),
                  const SizedBox(height: 10),
                  Text(
                    'No wellbeing entries found.',
                    style: TextStyle(fontSize: 18, color: AppColors.textDark),
                  ),
                  Text(
                    'Time to log your first check-in!',
                    style: TextStyle(color: AppColors.textSubtle),
                  ),
                ],
              ),
            );
          }

          // 4. Display Data (ListView)
          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return _buildEntryCard(context, entry);
            },
          );
        },
      ),
    );
  }

  // Helper function to build a visually appealing entry card
  Widget _buildEntryCard(BuildContext context, WellbeingEntry entry) {
    final formattedDate = _formatDate(entry.timestamp);

    // Get the mood label based on the score (using the constants)
    final moodOption = moodOptions.cast<Map<String, dynamic>?>().firstWhere(
      (opt) => opt?['value'] == entry.moodScore,
      orElse: () => {'label': 'N/A', 'icon': '❓', 'color': AppColors.textSubtle},
    )!;

    final moodIcon = moodOption['icon'] as String;
    final moodLabel = moodOption['label'] as String;
    final moodColor = moodOption['color'] as Color;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 15.0),
      color: AppColors.secondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        title: Row(
          children: [
            // Date
            Text(
              formattedDate,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textDark,
              ),
            ),
            const Spacer(),
            // Mood Display
            Text(
              moodIcon,
              style: TextStyle(fontSize: 24, color: moodColor),
            ),
            const SizedBox(width: 8),
            Text(
              moodLabel,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: moodColor,
              ),
            ),
          ],
        ),
        subtitle: Text(
          'Tap for details. Logged at ${_formatTime(entry.timestamp)}',
          style: TextStyle(color: AppColors.textSubtle, fontSize: 12),
        ),
        
        // Detailed data in the expansion
        children: <Widget>[
          Divider(height: 1, color: AppColors.textSubtle.withOpacity(0.3)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Mood Score:', entry.moodScore.toString(), moodColor),
                _buildDetailRow('Sleep Rating:', '${entry.sleepRating} / 4', AppColors.primaryColor),
                _buildDetailRow('Movement Level:', '${entry.exerciseValue} / 5', AppColors.accent),
                _buildDetailRow('Water Intake:', '${entry.waterGlasses} Glasses (≈${(entry.waterGlasses * 0.25).toStringAsFixed(1)}L)', AppColors.textDark),
                const SizedBox(height: 10),
                // Notes Section
                if (entry.notes.isNotEmpty) ...[
                  Text('Notes / Gratitude:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 4),
                  Text(entry.notes, style: TextStyle(fontStyle: FontStyle.italic, color: AppColors.textSubtle)),
                ] else ...[
                  Text('Notes: N/A', style: TextStyle(fontStyle: FontStyle.italic, color: AppColors.textSubtle)),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Simple row for detail display
  Widget _buildDetailRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textDark)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  // Date formatting helpers
  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
