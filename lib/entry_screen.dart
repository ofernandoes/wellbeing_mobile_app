import 'package:flutter/material.dart';
// Assuming these imports are correct based on previous code:
import 'package:wellbeing_mobile_app/services/firestore_service.dart'; 
import 'package:wellbeing_mobile_app/models/wellbeing_entry.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; // Needed for FirebaseAuth check

class EntryScreen extends StatefulWidget {
  const EntryScreen({super.key});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  // ✅ FIX 1: Removed 'const' keyword, as FirestoreService is not a const class.
  // ✅ FIX 2: Added 'final' keyword to the service instance (no reassignment needed).
  final FirestoreService _firestoreService = FirestoreService();
  
  // ✅ FIX 3 & 4: Added 'final' keyword to fields that are NOT state-managed 
  // (they are initialized but not changed later in the provided code).
  // If these were changed with setState, 'final' would need to be removed.
  final int _waterIntake = 0; 
  final String _gratitudePrompt = '';
  
  // Note: If you later add sliders/text fields to change these, remove 'final' 
  // and make them state variables. For now, they clear the linter warning.

  Future<void> _submitCheckin() async {
    // Use FirebaseAuth to get the current user ID
    final userId = FirebaseAuth.instance.currentUser?.uid;
    
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: You must be logged in to submit a check-in.')),
        );
      }
      return;
    }

    try {
      final entry = WellbeingEntry( 
        waterIntake: _waterIntake,
        gratitudePrompt: _gratitudePrompt,
      );

      // Save the entry using the service
      await _firestoreService.saveEntry(entry.toJson()); 

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Check-in completed! Great job.')),
        );
        Navigator.of(context).pop(); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving entry: Check console for details.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Check-in')),
      body: Center(
        child: ElevatedButton(
          onPressed: _submitCheckin, 
          child: const Text('Submit Check-in'),
        ),
      ),
    );
  }
}