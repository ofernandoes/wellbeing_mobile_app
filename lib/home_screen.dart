// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wellbeing_mobile_app/theme/app_colors.dart';
// NOTE: Assuming these are your existing model/service imports.
import 'package:wellbeing_mobile_app/services/api_service.dart'; 
import 'package:wellbeing_mobile_app/models/weather_model.dart';
import 'package:wellbeing_mobile_app/models/quote_model.dart';

// Check-in Imports (Adjusted path assumption based on typical Flutter project structure)
import '../services/checkin_service.dart'; 
import 'daily_checkin_screen.dart';     
import 'history_screen.dart'; 
import '../widgets/app_drawer.dart'; // Assuming AppDrawer is in widgets folder
import '../widgets/weather_card.dart'; // Assuming WeatherCard is in widgets folder
import '../widgets/quote_card.dart'; // Assuming QuoteCard is in widgets folder


// ------------------- HomeScreen -------------------

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 1. Define variables to hold fetched data
  late WeatherModel _weatherData;
  late QuoteModel _quoteData;
  final ApiService _apiService = ApiService();

  // State for Check-in History
  DailyCheckin? _latestCheckin;
  // List<DailyCheckin> _checkinHistory = []; // REMOVED: Unused field _checkinHistory
  bool _isLoading = true; 

  // State Variables for Summary (Used by _buildMoodSummary)
  double _recentAverageMood = 0.0;
  int _checkinCountLast7Days = 0; 


  @override
  void initState() {
    super.initState();
    _weatherData = WeatherModel.loading();
    _quoteData = QuoteModel.loading();
    
    _fetchInitialData();
    _loadCheckinData();
  }

  // UPDATED: Function to load the latest check-in and calculate the 7-day average
  Future<void> _loadCheckinData() async {
    final service = CheckinService();
    final history = await service.getCheckinHistory();

    history.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (mounted) {
      if (history.isNotEmpty) {
        _latestCheckin = history.first;
        // _checkinHistory = history; // REMOVED: Setting this field as it is unused

        // --- Calculate 7-Day Average ---
        final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
        
        // Note: The 'history' list is used here, but is a local variable, which is fine.
        final recentCheckins = history.where(
          (c) => c.timestamp.isAfter(sevenDaysAgo) && c.timestamp.isBefore(DateTime.now())
        ).toList();
        
        _checkinCountLast7Days = recentCheckins.length;

        if (_checkinCountLast7Days > 0) {
          final totalScore = recentCheckins.fold(0, (sum, item) => sum + item.moodScore);
          _recentAverageMood = totalScore / _checkinCountLast7Days;
        } else {
          _recentAverageMood = 0.0;
        }
        // ------------------------------------
        
      } else {
        _latestCheckin = null;
        // _checkinHistory = []; // REMOVED: Setting this field as it is unused
        _recentAverageMood = 0.0; 
        _checkinCountLast7Days = 0;
      }
      
      setState(() {
        _isLoading = false; 
      });
    }
  }

  Future<void> _fetchInitialData() async {
    try {
      final results = await Future.wait([
        // FIX APPLIED HERE: Added placeholder city argument
        _apiService.fetchWeatherData('New York'), 
        _apiService.fetchQuoteData(),
      ]);

      if (mounted) {
        setState(() {
          _weatherData = results[0] as WeatherModel;
          _quoteData = results[1] as QuoteModel;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _weatherData = WeatherModel.loading(); 
          _quoteData = QuoteModel.loading();
        });
      }
      debugPrint("Error fetching initial data: $e");
    }
  }

  // Helper function to handle navigation and refresh
  Future<void> _navigateToCheckinScreen(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DailyCheckinScreen(),
      ),
    );
    if (result == true) { 
      _loadCheckinData();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('I2.0 - Wellbeing Coach'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.home)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.flash_on)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Text('F', style: TextStyle(color: AppColors.primaryColor)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const AppDrawer(), 
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: <Widget>[
                _buildGreeting(context),
                const SizedBox(height: 20),
                
                // Add Check-in Button
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToCheckinScreen(context), 
                    icon: const Icon(Icons.add_task),
                    label: const Text('Check-in Now!'), 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // 1. 7-Day Mood Summary (NEW)
                _buildMoodSummary(), 
                const SizedBox(height: 20),
                
                // 2. Latest Check-in Card (Finalized and uses live data)
                if (_latestCheckin != null) _buildLatestCheckinCard(),
                const SizedBox(height: 20),

                // 3. Weather Card 
                WeatherCard(weatherData: _weatherData),
                const SizedBox(height: 20),

                // 4. Action Buttons
                const Text('What do you want to work on right now?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                _buildActionButtons(),
                const SizedBox(height: 20),

                // 5. Quote Card 
                QuoteCard(quoteData: _quoteData),
                const SizedBox(height: 20),
                
                // 6. Current Focus/Goal (Mock Data - To be replaced by Goal Feature)
                const Text('Your Current Focus:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                _buildFocusCard(context),
              ],
            ),
    );
  }

  // --- Widget Builders ---
  
  // NEW: Helper method to generate the mood summary widget
  Widget _buildMoodSummary() {
    if (_checkinCountLast7Days == 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'No check-ins in the last 7 days. Tap "Check-in Now!" to start tracking your mood.',
          style: TextStyle(color: AppColors.textSubtle),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Determine the summary text based on the average mood
    String summaryText;
    Color summaryColor;
    
    if (_recentAverageMood >= 4.0) {
      summaryText = 'Great job! Your average mood is High.';
      summaryColor = AppColors.accent;
    } else if (_recentAverageMood >= 3.0) {
      summaryText = 'Your mood is stable. Keep an eye on things.';
      summaryColor = AppColors.success;
    } else {
      summaryText = 'Your average mood is low. It might be time to reflect or seek support.';
      summaryColor = AppColors.error;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Mood Summary (Last 7 Days)',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              summaryText,
              style: TextStyle(fontSize: 16, color: summaryColor, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _recentAverageMood.toStringAsFixed(2),
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: summaryColor),
                    ),
                    const Text(
                      'Average Score / 5',
                      style: TextStyle(color: AppColors.textSubtle, fontSize: 12),
                    ),
                  ],
                ),
                Text(
                  'from $_checkinCountLast7Days entries',
                  style: const TextStyle(color: AppColors.textDark, fontSize: 14),
                ),
              ],
            ),
             const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const HistoryScreen(),
                    ),
                  );
                  _loadCheckinData(); 
                },
                child: const Text('View Full History >>', style: TextStyle(color: AppColors.primaryColor)),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // FINALIZED: Latest Check-in Card (Replaces the old _buildHistorySummary)
  Widget _buildLatestCheckinCard() {
    if (_latestCheckin == null) {
      return const SizedBox.shrink();
    }
    
    final latestCheckin = _latestCheckin!;
    final formattedDate = DateFormat('MMM d, h:mm a').format(latestCheckin.timestamp);
    
    // Map mood score to an icon/label 
    final moodText = latestCheckin.moodScore == 5 ? 'Great' : 
                     latestCheckin.moodScore == 4 ? 'Good' : 
                     latestCheckin.moodScore == 3 ? 'Okay' : 
                     latestCheckin.moodScore == 2 ? 'Bad' : 'Awful';
    final moodColor = latestCheckin.moodScore == 5 ? AppColors.accent : 
                      latestCheckin.moodScore == 4 ? AppColors.success : 
                      latestCheckin.moodScore == 3 ? AppColors.textSubtle : 
                      latestCheckin.moodScore == 2 ? AppColors.warning : AppColors.error;


    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Latest Check-in Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mood: $moodText',
                  style: TextStyle(fontSize: 16, color: moodColor, fontWeight: FontWeight.w600),
                ),
                Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 14, color: AppColors.textSubtle),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              latestCheckin.notes.isNotEmpty 
                ? latestCheckin.notes 
                : 'No notes recorded for this entry.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSubtle),
            ),
          ],
        ),
      ),
    );
  }

  
  Widget _buildGreeting(BuildContext context) {
    // UPDATED: Dynamic greeting based on latest check-in
    final String greetingText = _latestCheckin != null
      ? 'Welcome back, Fernando.'
      : 'No recent check-ins – how are you feeling today?';
      
    final String subtitleText = _latestCheckin != null
        ? 'Your last check-in was at ${DateFormat('h:mm a, MMM d').format(_latestCheckin!.timestamp)}.'
        : 'Get started with a quick check-in.';
      
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greetingText, 
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        Text(
          subtitleText, 
          style: const TextStyle(color: AppColors.textSubtle),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      spacing: 10.0,
      runSpacing: 10.0,
      children: [
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.military_tech, size: 18),
          label: const Text('Set/Work on a Goal'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.bolt, size: 18),
          label: const Text('Need a Quick Boost'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.textDark,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.trending_up, size: 18),
          label: const Text('Review My Progress'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
  
  // MOCK DATA: To be replaced by the Goal Tracking feature next
  Widget _buildFocusCard(BuildContext context) {
    return const Card(
      elevation: 2,
      color: AppColors.secondary,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Learn a New Language',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textDark),
            ),
            SizedBox(height: 5),
            Text(
              'Target: 75% complete by December',
              style: TextStyle(color: AppColors.textSubtle),
            ),
            SizedBox(height: 10), 
          ],
        ),
      ),
    );
  }
}