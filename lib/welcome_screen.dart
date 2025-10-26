// lib/welcome_screen.dart (UPDATED)

import 'package:flutter/material.dart';
import 'package:wellbeing_mobile_app/theme/app_colors.dart';
import 'package:wellbeing_mobile_app/services/auth_service.dart';

// Import the new screens (you will need to create these files)
import 'register_screen.dart'; // NEW
import 'login_screen.dart';    // NEW


class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // Helper function to handle the Anonymous Login
  void _startAnonymousTracking(BuildContext context) async {
    final AuthService authService = AuthService();
    final user = await authService.signInAnonymously();

    if (user != null) {
      // Navigate to the home screen route defined in main.dart
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      // Show an error if anonymous sign-in failed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to start anonymous tracking.'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // App Logo or Icon
              const Icon(
                Icons.favorite_border,
                size: 80,
                color: AppColors.primaryColor,
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'Welcome to Wellbeing Tracker',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // Description
              const Text(
                'Log in or create a fresh account to begin tracking your mood, sleep, and activity.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),

              // --- BUTTON 1: Anonymous Login (Existing Functionality) ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _startAnonymousTracking(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Start Tracking Anonymously',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- BUTTON 2: Create Account (Navigate to RegisterScreen) ---
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // Navigate to the new registration screen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.primaryColor, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // --- BUTTON 3: Sign In (Navigate to LoginScreen) ---
              TextButton(
                onPressed: () {
                  // Navigate to the new login screen
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Already have an account? Sign In',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}