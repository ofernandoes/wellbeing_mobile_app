// lib/main.dart

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math';


// Local Imports
import 'package:wellbeing_mobile_app/entry_screen.dart'; // FIX: This is the correct screen for check-ins
import 'package:wellbeing_mobile_app/welcome_screen.dart';
import 'package:wellbeing_mobile_app/widgets/forecast_day.dart';
import 'package:wellbeing_mobile_app/theme/app_colors.dart';
import 'package:wellbeing_mobile_app/firebase_options.dart';
import 'package:wellbeing_mobile_app/services/auth_service.dart'; // CRITICAL FIX: Auth Service Import
// --------------------------------------------------------------------------

// --- MOCK DATA/GLOBAL CONSTANTS ---
const List<String> weatherSuggestions = [
  'It\'s a fresh start! Get outside for 15 minutes to soak up some sun.',
  'Great day for movement! Try a quick 30-minute walk or light jog.',
  'It looks cozy! A perfect time for an indoor yoga session or mindfulness exercise.',
  'Wind down time. Make sure your bedroom is dark and cool for deep sleep.'
];

const List<Map<String, dynamic>> staticWeatherPatterns = [
  {"icon_code": 801, "max_c": 19, "min_c": 10},
  {"icon_code": 500, "max_c": 16, "min_c": 9},
  {"icon_code": 803, "max_c": 20, "min_c": 11},
  {"icon_code": 600, "max_c": 15, "min_c": 8},
  {"icon_code": 701, "max_c": 10, "min_c": 5},
  {"icon_code": 800, "max_c": 17, "min_c": 9},
  {"icon_code": 300, "max_c": 14, "min_c": 7},
];
// --------------------------------------------------------------------------

void main() async {
  // 1. MUST BE FIRST
  WidgetsFlutterBinding.ensureInitialized();
  // 2. Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully.');
  } catch (e) {
    debugPrint('Firebase Initialization Failed: $e');
  }

  // 3. Run the main app widget. We will use a StreamBuilder in MyAppWrapper
  runApp(const MyAppWrapper());
}

// --------------------------------------------------------------------------
// 🔥 NEW WIDGET: Handles the initial loading and authentication state stream
class MyAppWrapper extends StatelessWidget {
  const MyAppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp( // FIX: Removed const here as it contains non-const Theme data
      title: 'Wellbeing App',
      // ⚠️ THEME SETUP USING AppColors (Aqua Pop) ⚠️
      theme: ThemeData( // FIX: Removed const here
        // 1. Primary Color
        primaryColor: AppColors.primaryColor,

        // 2. Scaffold/Screen Background
        scaffoldBackgroundColor: AppColors.background,

        // 3. Color Scheme Setup (Essential for Material 3 components)
        colorScheme: const ColorScheme.light( // FIX: Added const back here
          primary: AppColors.primaryColor,
          secondary: AppColors.accent,
          surface: AppColors.secondary,
        ),


        // 4. App Bar style
        appBarTheme: const AppBarTheme( // FIX: Added const back here
          backgroundColor: AppColors.primaryColor,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.white),
        ),

        // 5. Text Theme
        textTheme: const TextTheme( // FIX: Added const back here
          bodyMedium: TextStyle(color: AppColors.textDark), // Simplified text theme application
          displayLarge: TextStyle(color: AppColors.textDark),
          displayMedium: TextStyle(color: AppColors.textDark),
          displaySmall: TextStyle(color: AppColors.textDark),
          headlineMedium: TextStyle(color: AppColors.textDark),
          headlineSmall: TextStyle(color: AppColors.textDark),
          titleLarge: TextStyle(color: AppColors.textDark),
          titleMedium: TextStyle(color: AppColors.textDark),
          titleSmall: TextStyle(color: AppColors.textDark),
          bodyLarge: TextStyle(color: AppColors.textDark),
          bodySmall: TextStyle(color: AppColors.textDark),
          labelLarge: TextStyle(color: AppColors.textDark),
          labelSmall: TextStyle(color: AppColors.textDark),
        ),


        useMaterial3: true,
        // ignore: deprecated_member_use
        primarySwatch: MaterialColor(AppColors.primaryColor.value, {
          // FIX: Updated deprecated withOpacity usage with .withAlpha()
          50: AppColors.primaryColor.withAlpha(25), // ~0.1 opacity
          100: AppColors.primaryColor.withAlpha(51), // ~0.2 opacity
          500: AppColors.primaryColor,
          700: AppColors.primaryColor.withAlpha(178), // ~0.7 opacity
          900: AppColors.primaryColor.withAlpha(230), // ~0.9 opacity
        }),
      ),
      // ------------------------------------

      debugShowCheckedModeBanner: false,

      // FIX: Use StreamBuilder to listen for the user's authentication state
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // If the connection is active and we have data (a user)
          if (snapshot.connectionState == ConnectionState.active) {
            final user = snapshot.data;
            // If the user is logged in (not null), show the MainAppScaffold
            if (user != null) {
              return const MainAppScaffold();
            }
            // If the user is null, show the WelcomeScreen
            return const WelcomeScreen();
          }
          // Show a simple loading screen while checking auth state
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),

      // CRITICAL FIX: Define the routes map to fix the "Could not find generator" error
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        // This is the required route for the WelcomeScreen button to navigate
        '/home': (context) => const MainAppScaffold(),
      },
    );
  }
}

// --------------------------------------------------------------------------

// --- TOP LEVEL SCAFFOLD (Handles Top Navigation) ---
class MainAppScaffold extends StatefulWidget {
  const MainAppScaffold({super.key});

  @override
  State<MainAppScaffold> createState() => _MainAppScaffoldState();
}

class _MainAppScaffoldState extends State<MainAppScaffold> {
// 1. Maintain the current screen index
  int _selectedIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- App Bar ---
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
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
            const DrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
              ),
              child: Text(
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
            // Logout option
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.pop(context);
                // LOGOUT FIX: Use the imported service to sign out and update UI
                await AuthService().signOut();
                // The MyAppWrapper StreamBuilder will automatically rebuild and show WelcomeScreen
              },
            ),
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
  String _weatherSuggestion = 'Loading suggestion...';
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

  // REMOVED UNUSED FIELD: 'final List<Map<String, dynamic>> _checkinHistory = [];'
  // FIX: Added const to the list of quotes
  // EXPANDED QUOTE LIST
  final List<Map<String, String>> _quoteList = const [ 
    {'quote': 'The journey of a thousand miles begins with a single step.', 'author': '— Lao Tzu (c. 6th century BC)'},
    {'quote': 'The only way to do great work is to love what you do.', 'author': '— Steve Jobs (1955–2011)'},
    {'quote': 'Happiness is not something readymade. It comes from your own actions.', 'author': '— Dalai Lama (b. 1935)'},
    {'quote': 'What lies behind us and what lies before us are tiny matters compared to what lies within us.', 'author': '— Ralph Waldo Emerson (1803–1882)'},
    {'quote': 'The best time to plant a tree was 20 years ago. The second best time is now.', 'author': '— Chinese Proverb (c. 400 BC)'},
    {'quote': 'Do not wait to strike till the iron is hot; but make the iron hot by striking.', 'author': '— William Butler Yeats (1865–1939)'},
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


  // --- Weather/Location Logic (MOCK DATA) ---
  Future<void> _fetchWeatherData() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      _currentTemp = '18';
      _weatherCondition = 'Cloudy';

      final Map<String, dynamic> weatherVisuals = _getWeatherVisuals(_weatherCondition);
      _weatherIcon = weatherVisuals['icon'];
      _weatherIconColor = AppColors.textDark;

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
      debugPrint('Location Data: 51.5074, 0.1278 (Mock)');


    } catch (e) {
      debugPrint('Error fetching dynamic mock weather data: $e');
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
      return {'icon': Icons.wb_sunny, 'color': AppColors.accent};
    } else if (condition == 'Rain' || condition == 'Drizzle') {
      return {'icon': Icons.cloudy_snowing, 'color': AppColors.primaryColor};
    } else if (condition == 'Thunderstorm') {
      return {'icon': Icons.thunderstorm, 'color': AppColors.warning};
    } else if (condition == 'Snow') {
      // FIX: Replace deprecated withOpacity usage with a hardcoded value or standard color if precision is not critical here
      return {'icon': Icons.ac_unit, 'color': AppColors.primaryColor.withAlpha(178)}; 
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
      // FIX: Replace deprecated withOpacity usage
      return {'icon': Icons.ac_unit, 'color': AppColors.primaryColor.withAlpha(178)};
    } else if (code >= 700 && code < 800) { // Atmosphere (Mist, Fog, etc.)
      return {'icon': Icons.blur_on, 'color': AppColors.textSubtle};
    } else if (code == 800) { // Clear
      return {'icon': Icons.wb_sunny, 'color': AppColors.accent};
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

    // FIX: Only call setState if the widget is mounted
    if (mounted) {
      setState(() {
        _quote = '"$currentQuote"';
        _author = currentAuthor;
      });
    }
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


  Future<void> _initializeUserAndGreeting() async {
    final prefs = await SharedPreferences.getInstance();
    // Use Firebase user ID as a fallback, but default to 'Fernando' for better UX
    final user = FirebaseAuth.instance.currentUser;
    String newUserName;
    if (user != null && user.isAnonymous) {
      newUserName = 'Guest';
    } else {
      // FIX: Use 'Fernando' as the default fallback only if no name is saved in prefs
      newUserName = prefs.getString('userName') ?? 'Fernando';
    }

    final now = DateTime.now();
    await prefs.setInt('lastVisitTimestamp', now.millisecondsSinceEpoch);
    
    // FIX: Only call setState if the widget is mounted
    if (mounted) {
      setState(() {
        _userName = newUserName;
      });
    }
  }


  void _openNewEntry(BuildContext context) async {
    // The state is updated only when returning from EntryScreen
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EntryScreen(), // <--- FIX: Changed to EntryScreen
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
      elevation: 0,
      color: AppColors.secondary,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: BorderSide.none
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
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)
              ),
              subtitle: Text(_weatherSuggestion, style: const TextStyle(color: AppColors.textSubtle)),
            ),

            const Divider(height: 20, color: AppColors.textSubtle),

            // 1 Week Forecast (DYNAMIC - MOCK DATA)
            const Text('7-Day Forecast:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _forecastData.isNotEmpty
                  ? _forecastData.map((dayData) => ForecastDay(
                        key: ValueKey(dayData['date']),
                        day: dayData['day'] as String,
                        date: dayData['date'] as String,
                        icon: dayData['icon'] as IconData,
                        color: dayData['color'] as Color,
                        temp: dayData['temp'] as String,
                        )).toList()
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // --- A. DYNAMIC GREETING ---
          const Text(
            'Welcome back,',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
          ),
          Text(
            '$_userName.',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
          ),
          const SizedBox(height: 4),

          // Wrap the supportive text and the new entry chip in a Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
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
                return const Center(child: LinearProgressIndicator(minHeight: 10, color: AppColors.primaryColor));
              } else {
                return _buildWeatherCard();
              }
            },
          ),
          const Divider(height: 40, color: Colors.transparent),


          // --- C. ACTION PROMPT & CHIPS ---
          const Text(
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
                backgroundColor: AppColors.primaryColor,
                labelStyle: const TextStyle(color: Colors.white),
              ),
              ActionChip(
                avatar: const Icon(Icons.flash_on, color: AppColors.textDark),
                label: const Text('Need a Quick Boost'),
                onPressed: () {
                  final mainState = context.findAncestorStateOfType<_MainAppScaffoldState>();
                  mainState?._onItemTapped(2);
                },
                backgroundColor: AppColors.accent,
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
                backgroundColor: AppColors.success,
                labelStyle: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          const Divider(height: 40, color: Colors.transparent),


          // --- D. QUOTE ---
          const Text(
            'Your Quote for the Day:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: AppColors.secondary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _quote,
                    style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        _author,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.primaryColor),
                      ),
                    ],
                  ),
                  // Add text-to-speech option
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => flutterTts.speak(_quote),
                      icon: const Icon(Icons.volume_up, size: 18, color: AppColors.textSubtle),
                      label: const Text('Listen', style: TextStyle(color: AppColors.textSubtle)),
                    ),
                  )
                ],
              ),
            ),
          ),
          const Divider(height: 40, color: Colors.transparent),


          // --- E. Goals Snapshot (PLACEHOLDER) ---
          const Text(
            'Your Current Focus:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textDark),
          ),
          const SizedBox(height: 10),
          Card( // FIX: Removed const on Card (line 806)
            elevation: 0,
            color: AppColors.secondary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            child: const ListTile(
              title: Text(
                'Learn a New Language',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Target: 75% complete by December', style: TextStyle(color: AppColors.textDark)),
                  SizedBox(height: 4),
                ],
              ),
              isThreeLine: false,
              trailing: Icon(Icons.trending_up, color: AppColors.success),
            ),
          ),

          // --- F. Bottom Padding to ensure scrolling works well ---
          const SizedBox(height: 100),


        ],
      ),
    );
  }
}
