// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wellbeing_mobile_app/theme/app_colors.dart';
// NOTE: Assuming these are your existing model/service imports.
import 'package:wellbeing_mobile_app/services/api_service.dart';
import 'package:wellbeing_mobile_app/models/weather_model.dart';
import 'package:wellbeing_mobile_app/models/quote_model.dart';

// Check-in Imports
import '../services/checkin_service.dart'; // Must be the Firestore version
import 'daily_checkin_screen.dart';
import 'history_screen.dart'; 
import '../widgets/app_drawer.dart'; 
import '../widgets/weather_card.dart'; 
import '../widgets/quote_card.dart'; 


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
  
  // 2. Initialize CheckinService for the StreamBuilder
  final CheckinService _checkinService = CheckinService();
  bool _isApiLoading = true; // Separate loading state for API data

  @override
  void initState() {
    super.initState();
    _weatherData = WeatherModel.loading();
    _quoteData = QuoteModel.loading();
    
    _fetchInitialData();
  }

  // UPDATED: Fetches only the API data, as check-in data now comes from the Stream.
  Future<void> _fetchInitialData() async {
    try {
      final results = await Future.wait([
        _apiService.fetchWeatherData('New York'), 
        _apiService.fetchQuoteData(),
      ]);

      if (mounted) {
        setState(() {
          _weatherData = results[0] as WeatherModel;
          _quoteData = results[1] as QuoteModel;
          _isApiLoading = false; // API data is ready
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _weatherData = WeatherModel.loading(); 
          _quoteData = QuoteModel.loading();
          _isApiLoading = false; // Still need to stop loading even on error
        });
      }
      debugPrint("Error fetching initial data: $e");
    }
  }

  // NEW: Synchronous function to calculate summary data from the Stream data
  Map<String, dynamic> _calculateSummary(List<DailyCheckin> history) {
    history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    final latestCheckin = history.isNotEmpty ? history.first : null;

    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    
    final recentCheckins = history.where(
      (c) => c.timestamp.isAfter(sevenDaysAgo) && c.timestamp.isBefore(DateTime.now())
    ).toList();
    
    final checkinCountLast7Days = recentCheckins.length;
    double recentAverageMood = 0.0;

    if (checkinCountLast7Days > 0) {
      final totalScore = recentCheckins.fold(0, (sum, item) => sum + item.moodScore);
      recentAverageMood = totalScore / checkinCountLast7Days;
    }

    return {
      'latestCheckin': latestCheckin,
      'recentAverageMood': recentAverageMood,
      'checkinCountLast7Days': checkinCountLast7Days,
    };
  }

  // Helper function to handle navigation and refresh
  Future<void> _navigateToCheckinScreen(BuildContext context) async {
    // We don't need to await the result or call setState here, 
    // because the StreamBuilder will automatically rebuild the UI
    // when a new check-in is saved to Firestore.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DailyCheckinScreen(),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('I2.0 - Wellbeing Coach'),
        // ... (App Bar Actions and Leading are unchanged)
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
      
      // CRITICAL UPDATE: Using StreamBuilder for real-time check-in data
      body: StreamBuilder<List<DailyCheckin>>(
        stream: _checkinService.getCheckinsStream(),
        builder: (context, snapshot) {
          
          // 1. Check for connection states
          if (snapshot.connectionState == ConnectionState.waiting || _isApiLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading data: ${snapshot.error}'));
          }

          // 2. Data is ready: Get history and calculate summary
          final checkinHistory = snapshot.data ?? [];
          final summary = _calculateSummary(checkinHistory);
          final DailyCheckin? latestCheckin = summary['latestCheckin'];
          final double recentAverageMood = summary['recentAverageMood'];
          final int checkinCountLast7Days = summary['checkinCountLast7Days'];

          // 3. Build the main content using the retrieved data
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              // Pass data to Greeting
              _buildGreeting(context, latestCheckin), 
              const SizedBox(height: 20),
              
              // Add Check-in Button (FAB is no longer here, so this stays)
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
              
              // 1. 7-Day Mood Summary (Pass calculated values)
              _buildMoodSummary(recentAverageMood, checkinCountLast7Days), 
              const SizedBox(height: 20),
              
              // 2. Latest Check-in Card (Pass latest check-in object)
              if (latestCheckin != null) _buildLatestCheckinCard(latestCheckin),
              const SizedBox(height: 20),

              // 3. Weather Card (API data is ready if we passed the loading check)
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
              
              // 6. Current Focus/Goal (Mock Data)
              const Text('Your Current Focus:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              _buildFocusCard(context),
            ],
          );
        },
      ),
      // IMPORTANT: Add the FAB back to the main Scaffold
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCheckinScreen(context),
        child: const Icon(Icons.add),
        tooltip: 'New Check-in',
      ),
    );
  }

  // --- Widget Builders ---
  
  // UPDATED: Now requires latestCheckin as an argument
  Widget _buildGreeting(BuildContext context, DailyCheckin? latestCheckin) {
    // UPDATED: Dynamic greeting based on latest check-in
    final String greetingText = latestCheckin != null
      ? 'Welcome back, Fernando.' // Personalized text
      : 'No recent check-ins – how are you feeling today?';
      
    final String subtitleText = latestCheckin != null
        ? 'Your last check-in was at ${DateFormat('h:mm a, MMM d').format(latestCheckin.timestamp)}.'
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

  // UPDATED: Now requires recentAverageMood and checkinCountLast7Days as arguments
  Widget _buildMoodSummary(double recentAverageMood, int checkinCountLast7Days) {
    if (checkinCountLast7Days == 0) {
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
    
    if (recentAverageMood >= 4.0) {
      summaryText = 'Great job! Your average mood is High.';
      summaryColor = AppColors.accent;
    } else if (recentAverageMood >= 3.0) {
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
                      recentAverageMood.toStringAsFixed(2),
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: summaryColor),
                    ),
                    const Text(
                      'Average Score / 5',
                      style: TextStyle(color: AppColors.textSubtle, fontSize: 12),
                    ),
                  ],
                ),
                Text(
                  'from $checkinCountLast7Days entries',
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
                  // The stream handles refresh, no need for manual _loadCheckinData()
                },
                child: const Text('View Full History >>', style: TextStyle(color: AppColors.primaryColor)),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // UPDATED: Now requires DailyCheckin object as an argument
  Widget _buildLatestCheckinCard(DailyCheckin latestCheckin) {
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