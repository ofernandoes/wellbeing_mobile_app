// lib/user_details_screen.dart

import 'package:flutter/material.dart';
import 'package:wellbeing_mobile_app/services/firestore_service.dart';
import 'package:wellbeing_mobile_app/app_colors.dart'; // FIX: Corrected import path based on your file system
class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  String _userName = '';
  String _ageInput = '';
  String _goal = '';
  bool _isLoading = false;

  Future<void> _saveDetails() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final int age = int.tryParse(_ageInput) ?? 0;

      setState(() {
        _isLoading = true;
      });

      try {
        await _firestoreService.saveUserDetails(
          // Correct named parameters
          username: _userName, 
          age: age,
          primaryGoal: _goal,   
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Details saved successfully!')),
          );
          // Assuming '/home' is the route name for HomeScreen
          Navigator.of(context).pushReplacementNamed('/home'); 
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save details: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Tell us a little about yourself to personalize your wellness journey.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // Username Field
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Your Name/Nickname',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _userName = value ?? ''; 
                },
              ),
              const SizedBox(height: 20),

              // Age Field
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Your Age',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cake),
                ),
                validator: (value) {
                  if (value == null || int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid age.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _ageInput = value ?? '';
                },
              ),
              const SizedBox(height: 20),

              // Primary Goal Field
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Your Primary Wellness Goal',
                  hintText: 'e.g., Reduce stress, improve sleep, exercise more',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.track_changes),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your goal.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _goal = value ?? ''; 
                },
              ),
              const SizedBox(height: 40),

              // Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveDetails,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: AppColors.primaryColor, 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Details and Continue',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
