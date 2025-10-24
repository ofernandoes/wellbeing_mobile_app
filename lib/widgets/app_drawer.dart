// lib/widgets/app_drawer.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wellbeing_mobile_app/theme/app_colors.dart';

// Import the new GoalsScreen
import '../screens/goals_screen.dart'; 
// Import existing screens
import '../screens/history_screen.dart';
import '../screens/home_screen.dart';


class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          // Header Section
          Container(
            height: 120,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            alignment: Alignment.centerLeft,
            color: AppColors.primaryColor,
            child: const Text(
              'Wellbeing Navigator',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 26,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // --- Navigation Items ---
          
          // 1. Home
          _buildListTile(
            context,
            'Home',
            Icons.home,
            () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),
          
          // 2. Goals (NEW)
          _buildListTile(
            context,
            'Goals & Planning',
            Icons.military_tech,
            () {
              // Close drawer and navigate
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const GoalsScreen()),
              );
            },
          ),
          
          // 3. History
          _buildListTile(
            context,
            'Check-in History',
            FontAwesomeIcons.chartLine,
            () {
              // Close drawer and navigate
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
          
          // 4. Settings
          _buildListTile(
            context,
            'Settings',
            Icons.settings,
            () {
              // Implementation for settings screen later
              Navigator.of(context).pop(); 
            },
          ),
          
          const Spacer(), // Pushes the next item to the bottom
          
          // 5. Chao - Exit/Backup Reminder (Personalized Feature)
          _buildListTile(
            context,
            'Chao - Exit',
            Icons.logout,
            () {
              // Close drawer first
              Navigator.of(context).pop(); 
              
              // **PERSONALIZATION REMINDER**
              // When user says "Chao" (or taps 'Chao - Exit'), remind them to back up.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Chao! 👋 Remember to back up your progress before leaving."),
                  duration: Duration(seconds: 3),
                ),
              );
              
              // Simulate exit behavior (optional)
              // This is where you might implement an app exit or log out function.
            },
          ),
        ],
      ),
    );
  }

  // Generic helper method for consistency
  Widget _buildListTile(BuildContext context, String title, IconData icon, VoidCallback tapHandler) {
    return ListTile(
      leading: Icon(
        icon,
        size: 26,
        color: AppColors.primaryColor,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
      ),
      onTap: tapHandler,
    );
  }
}
