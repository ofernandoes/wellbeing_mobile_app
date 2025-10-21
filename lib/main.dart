// lib/main.dart (REPLACEMENT CODE)

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_tts/flutter_tts.dart';

// ---------------------- NEW FIREBASE IMPORTS ----------------------
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'firebase_options.dart'; 
// ------------------------------------------------------------------

import 'entry_screen.dart';
// Note: We are no longer using 'package:wellbeing_mobile_app/widgets/forecast_day.dart' 
// in main.dart, but it's used in HomeScreen, which is defined later in this file.
// We'll keep the entire file structure as you had it, but will remove this unused import 
// from the main section for cleaner code.
import 'package:wellbeing_mobile_app/widgets/forecast_day.dart'; 

import 'package:wellbeing_mobile_app/theme/app_colors.dart'; 

// --- MOCK DATA/GLOBAL CONSTANTS ---
// ... (All your existing const data stays here) ...
const List<String> weatherSuggestions = [
  'It\'s a fresh start! Get outside for 15 minutes to soak up some sun.',
  'Great day for movement! Try a quick 30-minute walk or light jog.',
  'It looks cozy! A perfect time for an indoor yoga session or mindfulness exercise.',
  'Wind down time. Make sure your bedroom is dark and cool for deep sleep.'
];

const List<Map<String, dynamic>> staticWeatherPatterns = [
    {"icon_code": 801, "max_c": 19, "min_c": 10},  // Pattern 1: Clouds/Mild
    {"icon_code": 500, "max_c": 16, "min_c": 9},   // Pattern 2: Light Rain/Cooler
    {"icon_code": 803, "max_c": 20, "min_c": 11},  // Pattern 3: Broken Clouds/Warmest
    {"icon_code": 600, "max_c": 15, "min_c": 8},   // Pattern 4: Light Snow/Cold
    {"icon_code": 701, "max_c": 10, "min_c": 5},   // Pattern 5: Mist/Coldest
    {"icon_code": 800, "max_c": 17, "min_c": 9},   // Pattern 6: Clear/Average
    {"icon_code": 300, "max_c": 14, "min_c": 7},   // Pattern 7: Drizzle/Chilly
];
// --------------------------------------------------------------------------


// -------------------------- MODIFIED MAIN --------------------------
void main() async { 
  // 1. MUST BE FIRST: Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. NEW: Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // 3. Run the main app widget
  runApp(const WellbeingApp());
}

// Renamed from MyApp to WellbeingApp for clarity (optional, but good practice)
class WellbeingApp extends StatelessWidget {
  const WellbeingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wellbeing App',
      // ⚠️ YOUR EXISTING THEME SETUP REMAINS ⚠️
      theme: ThemeData(
        // 1. Primary Color
        primaryColor: AppColors.primaryColor, 

        // 2. Scaffold/Screen Background
        scaffoldBackgroundColor: AppColors.background, 

        // 3. Color Scheme Setup (Essential for Material 3 components)
        colorScheme: ColorScheme.light(
          primary: AppColors.primaryColor,
          secondary: AppColors.accent,
          background: AppColors.background,
          surface: AppColors.secondary,
        ),

        // 4. App Bar style
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primaryColor,
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        
        // 5. Text Theme
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: AppColors.textDark,
          displayColor: AppColors.textDark,
        ),

        useMaterial3: true,
        primarySwatch: MaterialColor(AppColors.primaryColor.value, {
          50: AppColors.primaryColor.withOpacity(0.1),
          100: AppColors.primaryColor.withOpacity(0.2),
          500: AppColors.primaryColor,
          700: AppColors.primaryColor.withOpacity(0.7),
          900: AppColors.primaryColor.withOpacity(0.9),
        }),
      ),
      // ------------------------------------
      
      debugShowCheckedModeBanner: false,  
      // NEW: Start with the AuthWrapper to handle sign-in
      home: const AuthWrapper(),
    );
  }
}

// --------------------- NEW AUTHENTICATION WRAPPER ---------------------
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  // Function to sign in anonymously (creates a temporary, scalable user ID)
  Future<User?> _signInAnonymously(BuildContext context) async {
    // Check if a user is already signed in (if the app was previously run)
    final existingUser = FirebaseAuth.instance.currentUser;
    if (existingUser != null) {
      print("User already signed in: ${existingUser.uid}");
      return existingUser;
    }
    
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      print("Signed in with new user ID: ${userCredential.user?.uid}");
      return userCredential.user;
    } catch (e) {
      print("Error during anonymous sign-in: $e");
      // Could be network error, etc.
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use FutureBuilder to wait for the anonymous sign-in to complete
    return FutureBuilder<User?>(
      future: _signInAnonymously(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data != null) {
            // User is signed in, show your main navigation scaffold
            return const MainAppScaffold();
          } else {
            // Error during sign-in/initialization
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    '❌ Initialization Error. Please check your internet connection or Firebase setup.', 
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.error, fontSize: 18),
                  ),
                ),
              ),
            );
          }
        }
        // While waiting, show a loading screen
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          ),
        );
      },
    );
  }
}
// ----------------------------------------------------------------------


// --- TOP LEVEL SCAFFOLD (Handles Top Navigation) ---
// ... (All your existing MainAppScaffold code continues here) ...
class MainAppScaffold extends StatefulWidget {
  const MainAppScaffold({super.key});

  @override
  State<MainAppScaffold> createState() => _MainAppScaffoldState();
}

class _MainAppScaffoldState extends State<MainAppScaffold> {
  // 1. Maintain the current screen index
  int _selectedIndex = 0;  
  
  // 2. Define the icons for the navigation buttons (ICONS ONLY)
  static const List<IconData> _icons = [
    Icons.home,      // Home
    Icons.track_changes, // Goals (Set/Work on Goal)
    Icons.flash_on       // Boost (Set a Quick Boost)
  ];

  // 3. Define the widget options (The screens)
  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(), // Index 0: Home
    const Center(child: Text('Goals Screen', style: TextStyle(fontSize: 30))), // Index 1: Goals
    const Center(child: Text('Boost Screen', style: TextStyle(fontSize: 30))), // Index 2: Boost
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // --- Widget for the custom Top Navigation Buttons (ICONS ONLY) ---
  List<Widget> _buildTopNavigationButtons() {
    return List.generate(_icons.length, (index) {
      bool isSelected = _selectedIndex == index;
      
      // Use AppColors.primaryColor for unselected icons
      Color iconColor = isSelected ? Colors.white : AppColors.primaryColor;  
      
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: InkWell(
          onTap: () => _onItemTapped(index),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Icon(_icons[index], size: 24, color: iconColor),
              // Highlight bar underneath (always white against the primary blue AppBar)
              if (isSelected)  
                Container(
                  margin: const EdgeInsets.only(top: 10),  
                  height: 3,
                  width: 30,  
                  color: Colors.white,
                ),
                if (!isSelected)
                const SizedBox(height: 13),  
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- App Bar ---
      appBar: AppBar(
        // FIX: Ensure the leading menu icon is visible (white)
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white), // Explicitly set to white
              onPressed: () {
                Scaffold.of(context).openDrawer();  
              },
            );
          }
        ),
        
        // App Title
        title: const Text(
          'I2.0 - Wellbeing Coach',  
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)  
        ),

        backgroundColor: AppColors.primaryColor,  
        centerTitle: false,  

        // Custom Top Navigation buttons and Profile Icon
        actions: [
          // FIX: Updated the icons in the AppBar to match the navigation style in the image
          _selectedIndex == 0  
            ? IconButton(
                icon: const Icon(Icons.home, color: Colors.white),
                onPressed: () => _onItemTapped(0),
              )
            : IconButton(
                icon: const Icon(Icons.home_outlined, color: Colors.white),
                onPressed: () => _onItemTapped(0),
              ),

          _selectedIndex == 1  
            ? IconButton(
                icon: const Icon(Icons.track_changes, color: Colors.white),
                onPressed: () => _onItemTapped(1),
              )
            : IconButton(
                icon: const Icon(Icons.track_changes_outlined, color: Colors.white),
                onPressed: () => _onItemTapped(1),
              ),

          _selectedIndex == 2  
            ? IconButton(
                icon: const Icon(Icons.flash_on, color: Colors.white),
                onPressed: () => _onItemTapped(2),
              )
            : IconButton(
                icon: const Icon(Icons.flash_on_outlined, color: Colors.white),
                onPressed: () => _onItemTapped(2),
              ),

          // Profile Icon (User)
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile Screen Coming Soon'))
              );
            },
          ),
          const SizedBox(width: 8),  
        ],
      ),
      
      // --- Drawer Widget ---
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // Drawer Header with App Name/Version
            DrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.primaryColor,  
              ),
              child: const Text(
                'Wellbeing Coach I2.0',
                style: TextStyle(
                  color: Colors.white,  
                  fontSize: 24,
                ),
              ),
            ),
            // Menu Items
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Community'),
              onTap: () {
                Navigator.pop(context);  
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navigating to Community...'))
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help'),
              onTap: () {
                Navigator.pop(context);  
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navigating to Help/Support...'))
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);  
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navigating to About...'))
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);  
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navigating to Settings...'))
                );
              },
            ),
          ],
        ),
      ),
      
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
    );
  }
}


// --- HOME SCREEN (Contains all data loading and UI) ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  late final FlutterTts flutterTts;  

  // Initial State Variables
  String _userName = 'User';
  int _entryCount = 0;    
  String _weatherSuggestion = 'Loading suggestion...';
  
  // Weather State variables
  String _locationName = 'Fetching data...';    
  String _currentTemp = 'N/A';
  String _weatherCondition = 'Loading weather...';
  IconData _weatherIcon = Icons.autorenew;    
  Color _weatherIconColor = Colors.grey;
  List<Map<String, dynamic>> _forecastData = [];
  
  // Quote State
  String _quote = 'Loading quote...';
  String _author = '';
  
  // Future to hold the combined result of all initial tasks
  late Future<void> _initialLoadFuture;    

  // EXPANDED QUOTE LIST    
  final List<Map<String, String>> _quoteList = [
    {'quote': 'The journey of a thousand miles begins with a single step.', 'author': '— Lao Tzu (c. 6th century BC)'},
    {'quote': 'The only way to do great work is to love what you do.', 'author': '— Steve Jobs (1955–2011)'},
    {'quote': 'Happiness is not something readymade. It comes from your own actions.', 'author': '— Dalai Lama (b. 1935)'},
    {'quote': 'What lies behind us and what lies before us are tiny matters compared to what lies within us.', 'author': '— Ralph Waldo Emerson (1803–1882)'},
    {'quote': 'The best time to plant a tree was 20 years ago. The second best time is now.', 'author': '— Chinese Proverb (c. 400 BC)'},
    {'quote': 'Do not wait to strike till the iron is hot; but make the iron hot by striking.', 'author': '— William Butler Yeats (1865–1939)'},
    {'quote': 'It is not the strongest of the species that survives, nor the most intelligent that survives. It is the one that is most adaptable to change.', 'author': '— Charles Darwin (1819–1882)'},
    {'quote': 'The mind is everything. What you think you become.', 'author': '— Buddha (c. 6th century BC)'},
    {'quote': 'Tough times never last, but tough people do.', 'author': '— Robert H. Schuller (1926–2015)'},
    {'quote': 'You miss 100% of the shots you don\'t take.', 'author': '— Wayne Gretzky (b. 1961)'},
    {'quote': 'The successful warrior is the average man, with laser-like focus.', 'author': '— Bruce Lee (1940–1973)'},
    {'quote': 'Believe you can and you\'re halfway there.', 'author': '— Theodore Roosevelt (1858–1919)'},
    {'quote': 'Life is 10% what happens to us and 90% how we react to it.', 'author': '— Charles R. Swindoll (b. 1934)'},
    {'quote': 'Our greatest glory is not in never failing, but in rising up every time we fail.', 'author': '— Ralph Waldo Emerson (1803–1882)'},
    {'quote': 'Strive not to be a success, but rather to be of value.', 'author': '— Albert Einstein (1879–1955)'},
    {'quote': 'The best revenge is massive success.', 'author': '— Frank Sinatra (1915–1998)'},
  ];


  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();  
    _initialLoadFuture = _loadAllInitialData();    
  }
  
  // Consolidated initialization method
  Future<void> _loadAllInitialData() async {
    await Future.wait([
      _initializeUserAndGreeting(),
      _loadDailyQuote(),
      _fetchWeatherData(),
    ]);
    
    if (mounted) {
      setState(() {
        _updateWeatherSuggestion();
      });
    }
  }

  // --- Date Formatting Utility ---
  String _formatDate(DateTime tm) {
    return DateFormat('EEEE, dd of MMMM, yyyy').format(tm);    
  }
  
  // --- Weather/Location Logic (MOCK DATA) ---

  Future<Position> _determinePosition() async {    
    return Position(
      latitude: 51.5074,    
      longitude: 0.1278,    
      timestamp: DateTime.now(),    
      accuracy: 0.0,    
      altitude: 0.0,    
      heading: 0.0,    
      speed: 0.0,    
      speedAccuracy: 0.0,    
      floor: 0,    
      isMocked: true,
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,    
    );
  }

  Future<void> _fetchWeatherData() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      _locationName = 'London';    
      _currentTemp = '18';
      _weatherCondition = 'Cloudy';    
      
      final Map<String, dynamic> weatherVisuals = _getWeatherVisuals(_weatherCondition);
      _weatherIcon = weatherVisuals['icon'];
      _weatherIconColor = AppColors.textDark; // Adjusted for better contrast on secondary color
      
      final List<Map<String, dynamic>> dynamicForecast = [];
      final DateTime today = DateTime.now();
      
      for (int i = 1; i <= 7; i++) {
          final DateTime forecastDate = today.add(Duration(days: i));
          final Map<String, dynamic> pattern = staticWeatherPatterns[(i - 1) % staticWeatherPatterns.length];
          final Map<String, dynamic> visual = _getOpenWeatherVisualsByCode(pattern['icon_code'] as int);

          dynamicForecast.add({
            'day': DateFormat('EEE').format(forecastDate),
            'date': DateFormat('dd/MM').format(forecastDate),
            'icon': visual['icon'],
            'color': visual['color'],
            'temp': '${pattern['max_c']}°/${pattern['min_c']}°',
          });
      }

      _forecastData = dynamicForecast;

    } catch (e) {
      print('Error fetching dynamic mock weather data: $e');
      _locationName = 'Mock Error';
      _currentTemp = 'N/A';
      _weatherCondition = 'Failed to load mock data.';
      _weatherIcon = Icons.error_outline;
      _weatherIconColor = AppColors.error;
      _forecastData = [];
    }
  }

  // Maps main condition text to a Flutter Icon and Color (OpenWeatherMap)
  Map<String, dynamic> _getWeatherVisuals(String condition) {
    if (condition == 'Clear') {
      return {'icon': Icons.wb_sunny, 'color': AppColors.accent}; // Accent: Vibrant Orange
    } else if (condition == 'Rain' || condition == 'Drizzle') {
      return {'icon': Icons.cloudy_snowing, 'color': AppColors.primaryColor};
    } else if (condition == 'Thunderstorm') {
      return {'icon': Icons.thunderstorm, 'color': AppColors.warning}; // Using warning for lightning
    } else if (condition == 'Snow') {
      return {'icon': Icons.ac_unit, 'color': AppColors.primaryColor.withOpacity(0.7)};
    } else if (condition == 'Clouds' || condition == 'Cloudy') {
      return {'icon': Icons.cloud, 'color': AppColors.textSubtle};
    } else if (condition == 'Mist' || condition == 'Fog' || condition == 'Haze') {
      return {'icon': Icons.blur_on, 'color': AppColors.textSubtle};
    } else {
      return {'icon': Icons.cloud, 'color': AppColors.textSubtle};
    }
  }

  // Maps OpenWeatherMap's main code ranges (simplified) to icons for the mock forecast
  Map<String, dynamic> _getOpenWeatherVisualsByCode(int code) {
    if (code >= 200 && code < 300) { // Thunderstorm
      return {'icon': Icons.thunderstorm, 'color': AppColors.warning};
    } else if (code >= 300 && code < 600) { // Drizzle/Rain
      return {'icon': Icons.cloudy_snowing, 'color': AppColors.primaryColor};
    } else if (code >= 600 && code < 700) { // Snow
      return {'icon': Icons.ac_unit, 'color': AppColors.primaryColor.withOpacity(0.7)};
    } else if (code >= 700 && code < 800) { // Atmosphere (Mist, Fog, etc.)
      return {'icon': Icons.blur_on, 'color': AppColors.textSubtle};
    } else if (code == 800) { // Clear
      return {'icon': Icons.wb_sunny, 'color': AppColors.accent}; // Accent: Vibrant Orange
    } else if (code >= 801 && code <= 804) { // Clouds
      return {'icon': Icons.cloud, 'color': AppColors.textSubtle};
    } else {
      return {'icon': Icons.cloud, 'color': AppColors.textSubtle};
    }
  }


  Future<void> _loadDailyQuote() async {
    final prefs = await SharedPreferences.getInstance();
    final String todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final String lastQuoteDate = prefs.getString('lastQuoteDate') ?? '';
    
    String currentQuote;
    String currentAuthor;
    
    if (lastQuoteDate != todayKey) {
      final int dayOfYear = int.parse(DateFormat('D').format(DateTime.now()));    
      final int totalQuotes = _quoteList.length;

      final int yearSeed = DateTime.now().year;    
      final Random random = Random(yearSeed);

      final List<int> yearlyCycle = List<int>.generate(totalQuotes, (i) => i)..shuffle(random);
      
      int newIndex = yearlyCycle[dayOfYear % totalQuotes];    

      final newQuote = _quoteList[newIndex];
      currentQuote = newQuote['quote']!;
      currentAuthor = newQuote['author']!;

      await prefs.setString('lastQuoteDate', todayKey);
      await prefs.setString('dailyQuote', currentQuote);
      await prefs.setString('dailyAuthor', currentAuthor);

    } else {
      currentQuote = prefs.getString('dailyQuote') ?? _quoteList[0]['quote']!;
      currentAuthor = prefs.getString('dailyAuthor') ?? _quoteList[0]['author']!;
    }
    
    _quote = '"$currentQuote"';    
    _author = currentAuthor;
  }

  void _updateWeatherSuggestion() {
    final hour = DateTime.now().hour;
    int suggestionIndex;
    if (hour >= 6 && hour < 10) {
      suggestionIndex = 0;    
    } else if (hour >= 10 && hour < 17) {
        suggestionIndex = Random().nextInt(2) + 1;    
    } else {
        suggestionIndex = 3;    
    }
    _weatherSuggestion = weatherSuggestions[suggestionIndex];
  }

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> _initializeUserAndGreeting() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('userName') ?? 'Fernando';  // Changed default to Fernando
    
    final lastVisit = prefs.getInt('lastVisitTimestamp');
    final now = DateTime.now();
    
    String baseGreeting;
    if (lastVisit != null) {
      final lastVisitTime = DateTime.fromMillisecondsSinceEpoch(lastVisit);    
      if (lastVisitTime.day == now.day && lastVisitTime.month == now.month && lastVisitTime.year == now.year) {
        baseGreeting = 'Welcome back';    
      } else {
        baseGreeting = _getTimeGreeting();
      }
    } else {
      baseGreeting = 'Hello';
    }
    
    await prefs.setInt('lastVisitTimestamp', now.millisecondsSinceEpoch);
  }

  void _openNewEntry(BuildContext context) async {
    // The state is updated only when returning from EntryScreen
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EntryScreen(),    
      ),
    );
    // Reload data on return from entry screen
    _initialLoadFuture = _loadAllInitialData();  
    if (mounted) {
      setState(() {});
    }
  }

  // FIX: New Widget for the Check-in Chip
  Widget _buildNewEntryChip(BuildContext context) {
    return ActionChip(
      // FIX: Changed icon to check_circle_outline
      avatar: const Icon(Icons.check_circle_outline, color: Colors.white),  
      // FIX: Changed label text to "Add Check-in"
      label: const Text('Add Check-in'),
      onPressed: () => _openNewEntry(context),
      backgroundColor: AppColors.primaryColor, // Light Aqua Blue
      labelStyle: const TextStyle(color: Colors.white),
    );
  }
  
  Widget _buildWeatherCard() {
    return Card(
      elevation: 0, // Set elevation low/zero to match the flat look of the image
      // Explicitly set the card color to secondary (Very Pale Aqua)
      color: AppColors.secondary,  
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: BorderSide.none // Remove border for a cleaner look
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Weather & Suggestion (DYNAMIC)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                _weatherIcon,    
                color: _weatherIconColor,    
                size: 40
              ),  
              title: Text(
                '$_currentTemp°C, $_weatherCondition',    
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)
              ),  
              subtitle: Text(_weatherSuggestion, style: TextStyle(color: AppColors.textSubtle)),
            ),
            
            const Divider(height: 20, color: AppColors.textSubtle),
            
            // 1 Week Forecast (DYNAMIC - MOCK DATA)
            const Text('7-Day Forecast:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),  
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                // FIX: Using named parameters (day:, date:, icon:, etc.) to match ForecastDay constructor
                children: _forecastData.isNotEmpty


                  ? _forecastData.map<Widget>((dayData) {


                      // Import is needed here, assuming ForecastDay is in lib/widgets/
                      // Since I don't have the explicit import, I will leave this as is.
                      // NOTE: If you get a Flutter error "ForecastDay is not defined", 
                      // you may need to add: import 'package:wellbeing_mobile_app/widgets/forecast_day.dart'; 
                      // to the top of this file.
                      return ForecastDay(  
                        key: ValueKey(dayData['date']), // Added key for better performance
                        day: dayData['day'] as String,
                        date: dayData['date'] as String,
                        icon: dayData['icon'] as IconData, // Now correctly passed as named parameter
                        color: dayData['color'] as Color,
                        temp: dayData['temp'] as String,
                      );
                    }).toList()
                  : [
                    const Center(child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Fetching forecast...', style: TextStyle(color: AppColors.textSubtle)),  
                    ))  
                  ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const String supportiveSuggestionText = 'No check-ins yet — how are you feeling today?.';
    
    // Remove static date and rely on the weather card for date context

    return SingleChildScrollView( // Removed Stack and Positioned
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // --- A. DYNAMIC GREETING ---
          Text(
            // Use static "Welcome back" to match the image, or _getTimeGreeting() for dynamism
            'Welcome back, $_userName.',  
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryColor),  
          ),
          const SizedBox(height: 4),
          
          // FIX: Wrap the supportive text and the new entry chip in a Row for correct horizontal placement
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                supportiveSuggestionText,
                style: TextStyle(fontSize: 16, color: AppColors.textSubtle),  
              ),
              const SizedBox(width: 8),
              _buildNewEntryChip(context), // Check-in Chip placement
            ],
          ),
          const SizedBox(height: 24),
          
          // --- B. WEATHER CARD ---
          FutureBuilder<void>(
            future: _initialLoadFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: LinearProgressIndicator(minHeight: 10, color: AppColors.primaryColor));  
              } else {
                return _buildWeatherCard();
              }
            },
          ),
          const Divider(height: 40, color: Colors.transparent), // Use transparent divider for spacing

          // --- C. ACTION PROMPT & CHIPS ---
          Text(
            'What do you want to work on right now?',  
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textDark),  
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: [
              ActionChip(
                avatar: const Icon(Icons.track_changes, color: Colors.white),
                label: const Text('Set/Work on a Goal'),
                onPressed: () {
                  final mainState = context.findAncestorStateOfType<_MainAppScaffoldState>();
                  mainState?._onItemTapped(1);  
                },
                backgroundColor: AppColors.primaryColor, // Light Aqua Blue
                labelStyle: const TextStyle(color: Colors.white),
              ),
              ActionChip(
                avatar: const Icon(Icons.flash_on, color: AppColors.textDark),  
                label: const Text('Need a Quick Boost'),
                onPressed: () {
                  final mainState = context.findAncestorStateOfType<_MainAppScaffoldState>();
                  mainState?._onItemTapped(2);
                },
                backgroundColor: AppColors.accent, // Accent (Vibrant Orange/Yellow)
                labelStyle: const TextStyle(color: AppColors.textDark),  
              ),
              ActionChip(
                avatar: const Icon(Icons.assessment, color: Colors.white),
                label: const Text('Review My Progress'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Review Progress Feature Coming Soon!'))
                  );
                },
                backgroundColor: AppColors.success, // Use a distinct color for this action
                labelStyle: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          const Divider(height: 40, color: Colors.transparent),

          // --- D. QUOTE ---
          Text(
            'Your Quote for the Day:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textDark),  
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0, // Set elevation low/zero
            color: AppColors.secondary, // Very Pale Aqua
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _quote,
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: AppColors.textDark),  
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        _author,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.primaryColor),  
                      ),
                    ],
                  ),
                  // Add text-to-speech option
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => flutterTts.speak(_quote),
                      icon: Icon(Icons.volume_up, size: 18, color: AppColors.textSubtle),
                      label: Text('Listen', style: TextStyle(color: AppColors.textSubtle)),
                    ),
                  )
                ],
              ),
            ),
          ),
          const Divider(height: 40, color: Colors.transparent),

          // --- E. Goals Snapshot (PLACEHOLDER) ---
          Text(
            'Your Current Focus:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textDark),  
          ),
          const SizedBox(height: 10),
          Card(
            elevation: 0,
            color: AppColors.secondary, // Very Pale Aqua
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            child: ListTile(
              title: Text(
                'Learn a New Language',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor),  
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Target: 75% complete by December', style: TextStyle(color: AppColors.textDark)),  
                  const SizedBox(height: 4),
                ],
              ),
              isThreeLine: false,
              trailing: Icon(Icons.arrow_forward_ios, color: AppColors.textSubtle),  
              onTap: () {
                final mainState = context.findAncestorStateOfType<_MainAppScaffoldState>();
                mainState?._onItemTapped(1);
              },
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 0.75, // Updated to 75% for visual match
            minHeight: 10,  
            backgroundColor: AppColors.textSubtle.withOpacity(0.3),  
            color: AppColors.primaryColor // Primary Color for the progress bar
          ),  
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text('75% Complete - 9 months remaining.', style: TextStyle(color: AppColors.textSubtle)), // CLOSES MISSING PARENTHESIS HERE
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
} // End of HomeScreen State/Widget
