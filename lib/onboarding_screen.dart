import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    // Simulate saving a user name from the onboarding process
    await prefs.setString('userName', 'Fernando'); 
    await prefs.setBool('onboarding_complete', true);
    
    // Navigate and replace the current screen with the main app structure
    Navigator.of(context).pushReplacementNamed('/'); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to I2.0')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Placeholder for Onboarding Steps',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'This screen will guide the user through initial setup (e.g., name, goals, permissions).',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => _completeOnboarding(context),
                child: const Text('Start Using App (Skip Onboarding)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
