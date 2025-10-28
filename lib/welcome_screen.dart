// lib/screens/welcome_screen.dart

import 'package:flutter/material.dart';
import 'package:wellbeing_mobile_app/services/auth_service.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Future<void> _handleAnonymousSignIn(BuildContext context) async {
    final authService = AuthService();
    try {
      await authService.signInAnonymously();
      // FIX: Check mounted before using context for navigation
      if (context.mounted) { 
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      // Handle error
      if (context.mounted) { 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing in anonymously: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed('/login'),
              child: const Text('Sign In'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed('/register'),
              child: const Text('Register'),
            ),
            TextButton(
              onPressed: () => _handleAnonymousSignIn(context),
              child: const Text('Continue as Guest'),
            ),
          ],
        ),
      ),
    );
  }
}