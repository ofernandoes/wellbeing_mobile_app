// lib/home_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// --- CRITICAL IMPORTS ---
import 'package:wellbeing_mobile_app/theme/app_colors.dart';
import 'package:wellbeing_mobile_app/api_service.dart'; // Assuming this handles quote/weather
import 'package:wellbeing_mobile_app/services/checkin_service.dart';
import 'package:wellbeing_mobile_app/models/daily_checkin_model.dart'; // Correct Model Import
import 'package:wellbeing_mobile_app/widgets/stats_chart.dart';
import 'package:wellbeing_mobile_app/daily_checkin_screen.dart'; // For starting a new checkin

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Services and Data containers
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiService _apiService = ApiService(); // Handles quotes and weather
  final CheckinService _checkinService = CheckinService(); // Handles check-ins

  // State variables
  String _greeting = 'Hello!';
  String _dailyQuote = 'Loading quote...';
  String _weather = 'Loading weather...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllInitialData();
  }

  // --- Initial Data Loading ---
  Future<void> _loadAllInitialData() async {
    await Future.wait([
      _initializeUserAndGreeting(),
      _loadDailyQuote(),
      _fetchWeatherData(),
    ]);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _initializeUserAndGreeting() async {
    final user = _auth.currentUser;
    String name = user?.displayName ?? 'User';
    String timeOfDay = DateFormat('a').format(DateTime.now());

    if (timeOfDay == 'AM') {
      _greeting = 'Good morning, $name!';
    } else if (DateTime.now().hour < 17) { // Before 5 PM
      _greeting = 'Good afternoon, $name!';
    } else {
      _greeting = 'Good evening, $name!';
    }
  }

  Future<void> _loadDailyQuote() async {
    try {
      final quote = await _apiService.fetchDailyQuote();
      if (mounted) {
        setState(() {
          _dailyQuote = '"${quote['quote']}" - ${quote['author']}';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _dailyQuote = 'Failed to load quote.';
        });
      }
    }
  }

  Future<void> _fetchWeatherData() async {
    try {
      // NOTE: Assuming default location or user location logic exists in ApiService
      final weatherData = await _apiService.fetchWeather();
      if (mounted) {
        setState(() {
          _weather = '${weatherData['temp']}°C in ${weatherData['city']}';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _weather = 'Weather data unavailable.';
        });
      }
    }
  }
  
  // --- UI Components ---
  Widget _buildGreetingAndQuote(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _greeting,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _dailyQuote,
            style: const TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _weather,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartCheckinButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // Navigate to the check-in screen to start a new entry
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const DailyCheckinScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        label: const Text(
          'Start Daily Check-in',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(List<DailyCheckin> checkins) {
    // Only use the last 7 entries for the weekly chart
    final recentCheckins = checkins.take(7).toList(); 

    // Create the data list for the chart (reversed to show oldest on the left)
    final moodData = recentCheckins.reversed.map((c) => c.moodScore.toDouble()).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Weekly Mood Snapshot',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          // Use the fixed StatsChart widget
          child: StatsChart(moodData: moodData),
        ),
      ],
    );
  }

  Widget _buildRecentCheckinsList(List<DailyCheckin> checkins) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Entries',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...checkins.take(3).map((checkin) {
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 10),
            color: AppColors.secondary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: _buildMoodIcon(checkin.moodScore),
              title: Text(
                // FIX: Use the correct property 'date'
                DateFormat('EEE, MMM d').format(checkin.date), 
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                // FIX: Use the correct property 'note'
                checkin.note.isNotEmpty ? checkin.note : 'No note recorded', 
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSubtle),
              onTap: () {
                // Navigate to detail or edit screen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    // FIX: Ensure correct parameter name is used if DailyCheckinScreen handles editing
                    builder: (context) => DailyCheckinScreen(checkin: checkin),
                  ),
                );
              },
            ),
          );
        }).toList(),
      ],
    );
  }

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wellbeing Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              // Assuming this logs out and pushes to the login screen
              _auth.signOut();
              // Replace this with your actual navigation logic to the login/entry screen
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 1. Greeting and Daily Info
                  _buildGreetingAndQuote(context),
                  const SizedBox(height: 30),

                  // 2. Start Check-in Button
                  _buildStartCheckinButton(context),
                  const SizedBox(height: 30),

                  // 3. Stats and Recent Check-ins
                  // CRITICAL FIX: Use StreamBuilder for real-time check-in data
                  StreamBuilder<List<DailyCheckin>>(
                    stream: _checkinService.getCheckinsStream(), // FIX: Correct method call
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: LinearProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        // FIX: Added error handling
                        return Center(child: Text('Error loading data: ${snapshot.error}'));
                      }
                      
                      final checkins = snapshot.data ?? [];

                      if (checkins.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text('No entries yet. Start your first check-in!', style: TextStyle(color: AppColors.textSubtle)),
                          ),
                        );
                      }

                      return Column(
                        children: [
                          _buildStatsSection(checkins),
                          const SizedBox(height: 30),
                          _buildRecentCheckinsList(checkins),
                          const SizedBox(height: 20),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
