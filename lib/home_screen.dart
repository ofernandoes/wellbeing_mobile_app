// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:wellbeing_mobile_app/theme/app_colors.dart';
import 'package:wellbeing_mobile_app/services/api_service.dart';
import 'package:wellbeing_mobile_app/models/weather_model.dart';
import 'package:wellbeing_mobile_app/models/quote_model.dart';

// ------------------- HomeScreen (Now Stateful) -------------------

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

  @override
  void initState() {
    super.initState();
    // Initialize data with loading states
    _weatherData = WeatherModel.loading();
    _quoteData = QuoteModel.loading();
    
    // 2. Start data fetching when the screen initializes
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    // Note: We use Future.wait to fetch data concurrently for speed
    try {
      final results = await Future.wait([
        _apiService.fetchWeatherData(),
        _apiService.fetchQuoteData(),
      ]);

      if (mounted) {
        setState(() {
          _weatherData = results[0] as WeatherModel;
          _quoteData = results[1] as QuoteModel;
        });
      }
    } catch (e) {
      // Handle the case where the API service itself failed (e.g., placeholder key)
      if (mounted) {
        setState(() {
          // Keep loading state or show specific error if desired
          _weatherData = WeatherModel.loading(); 
          _quoteData = QuoteModel.loading();
        });
      }
      print("Error fetching initial data: $e");
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
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Text('F', style: TextStyle(color: AppColors.primaryColor)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildGreeting(context),
            const SizedBox(height: 20),
            
            // Add Check-in Button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Navigate to Daily Check-in screen
                },
                icon: const Icon(Icons.add_task),
                label: const Text('Add Check-in'),
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
            
            // 3. Weather Card (Passes live/loading data)
            WeatherCard(weatherData: _weatherData),
            const SizedBox(height: 20),

            // 4. Action Buttons
            const Text('What do you want to work on right now?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            _buildActionButtons(),
            const SizedBox(height: 20),

            // 5. Quote Card (Passes live/loading data)
            QuoteCard(quoteData: _quoteData),
            const SizedBox(height: 20),
            
            // 6. Current Focus/Goal (Mock Data)
            const Text('Your Current Focus:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            _buildFocusCard(context),
          ],
        ),
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildGreeting(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, Fernando.',
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const Text(
          'No check-ins yet – how are you feeling today?.',
          style: TextStyle(color: AppColors.textSubtle),
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
  
  Widget _buildFocusCard(BuildContext context) {
    return Card(
      elevation: 2,
      color: AppColors.secondary,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Learn a New Language',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textDark),
            ),
            const SizedBox(height: 5),
            const Text(
              'Target: 75% complete by December',
              style: TextStyle(color: AppColors.textSubtle),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: 0.75, 
              backgroundColor: AppColors.primaryColor.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
            const SizedBox(height: 5),
            const Text(
              '75% Complete - 9 months remaining.',
              style: TextStyle(fontSize: 12, color: AppColors.textSubtle),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------- Placeholder Widgets for API Content -------------------

class WeatherCard extends StatelessWidget {
  final WeatherModel weatherData;
  const WeatherCard({super.key, required this.weatherData});

  // Helper to map OpenWeatherMap icons to FontAwesome icons
  IconData _getWeatherIcon(String iconCode) {
    if (iconCode.contains('01')) return FontAwesomeIcons.sun; 
    if (iconCode.contains('02') || iconCode.contains('03')) return FontAwesomeIcons.cloudSun; 
    if (iconCode.contains('04')) return FontAwesomeIcons.cloud; 
    if (iconCode.contains('09') || iconCode.contains('10')) return FontAwesomeIcons.cloudShowersHeavy; 
    if (iconCode.contains('11')) return FontAwesomeIcons.cloudBolt; 
    if (iconCode.contains('13')) return FontAwesomeIcons.snowflake; 
    if (iconCode.contains('50')) return FontAwesomeIcons.smog; 
    return FontAwesomeIcons.cloud; 
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading = weatherData.currentCondition == 'Fetching forecast...';
    
    return Card(
      elevation: 2,
      color: AppColors.secondary,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Current Weather (Displays live/loading data)
            Row(
              children: <Widget>[
                FaIcon(
                  isLoading ? FontAwesomeIcons.spinner : _getWeatherIcon(weatherData.currentIcon), 
                  color: AppColors.textDark, 
                  size: 24
                ),
                const SizedBox(width: 10),
                Text(
                  isLoading
                      ? weatherData.currentCondition 
                      : '${weatherData.currentTemp.round()}°C, ${weatherData.currentCondition.replaceFirst(weatherData.currentCondition[0], weatherData.currentCondition[0].toUpperCase())}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              weatherData.adviceMessage,
              style: const TextStyle(color: AppColors.textSubtle),
            ),
            const Divider(color: AppColors.textSubtle),
            
            // 7-Day Forecast (Displays live/loading data)
            const Text(
              '7-Day Forecast:',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 10),
            _buildForecastRow(context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildForecastRow(BuildContext context) {
    if (weatherData.forecast.isEmpty) {
      // Show a placeholder or loading indicator if data isn't ready
      return const Center(
        child: Text('Loading forecast...', style: TextStyle(color: AppColors.textSubtle))
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: weatherData.forecast.map((item) => _buildForecastDay(context, item)).toList(),
      ),
    );
  }
  
  Widget _buildForecastDay(BuildContext context, ForecastItem item) {
    final date = DateTime.fromMillisecondsSinceEpoch(item.timestamp);
    
    return Container(
      width: 70,
      margin: const EdgeInsets.only(right: 10),
      child: Column(
        children: [
          Text(DateFormat('EEE').format(date), style: const TextStyle(fontWeight: FontWeight.bold)), 
          Text(DateFormat('dd/MM').format(date), style: const TextStyle(fontSize: 10)),
          const SizedBox(height: 5),
          FaIcon(_getWeatherIcon(item.conditionIcon), size: 20, color: AppColors.primaryColor),
          const SizedBox(height: 5),
          Text('${item.temp.round()}°C'),
        ],
      ),
    );
  }
}

class QuoteCard extends StatelessWidget {
  final QuoteModel quoteData;
  const QuoteCard({super.key, required this.quoteData});

  @override
  Widget build(BuildContext context) {
    final bool isLoading = quoteData.content == 'Loading quote...';

    return Card(
      elevation: 2,
      color: AppColors.secondary,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Your Quote for the Day:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
            ),
            const SizedBox(height: 10),
            
            // Quote Content
            Text(
              quoteData.content, 
              style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 16),
            ),
            const SizedBox(height: 10),
            
            // Quote Author
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                isLoading ? quoteData.author : '– ${quoteData.author}',
                style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.textSubtle),
              ),
            ),
            
            // Show loading indicator if fetching
            if (isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: LinearProgressIndicator(color: AppColors.primaryColor),
              ),
          ],
        ),
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primaryColor,
            ),
            child: Text(
              'Wellbeing Coach I2.0',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white),
            ),
          ),
          ListTile(leading: const Icon(Icons.group), title: const Text('Community'), onTap: () {}),
          ListTile(leading: const Icon(Icons.help), title: const Text('Help'), onTap: () {}),
          ListTile(leading: const Icon(Icons.info), title: const Text('About'), onTap: () {}),
          const Divider(),
          ListTile(leading: const Icon(Icons.settings), title: const Text('Settings'), onTap: () {}),
        ],
      ),
    );
  }
}
