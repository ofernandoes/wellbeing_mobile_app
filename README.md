name: wellbeing_mobile_app
description: A new Flutter project for wellbeing tracking.
publish_to: 'none' # Prevents accidental publishing

version: 1.0.0+1

environment:
  # Ensure this matches your current Flutter/Dart SDK version
  sdk: '>=3.0.0 <4.0.0'

# =========================================================
# CRITICAL: There should only be ONE 'dependencies:' section
# =========================================================
dependencies:
  flutter:
    sdk: flutter

  # --- CORE FIREBASE PACKAGES ---
  # Using current stable versions for better compatibility
  firebase_core: ^2.32.0 
  firebase_auth: ^4.20.0 
  cloud_firestore: ^4.17.5 
  
  # --- MISSING UTILITY PACKAGES (REQUIRED) ---
  flutter_tts: ^4.2.3    # Text-to-Speech functionality
  intl: ^0.20.2          # Date and Number Formatting (for DateFormat)
  # -------------------------------------------
  
  # Other necessary packages (keep your existing versions)
  shared_preferences: ^2.2.2
  cupertino_icons: ^1.0.6

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true
  # To add assets to your application, add an assets section below.
  # assets:
  #   - images/a_dot_burr.jpeg
  #   - images/a_dot_ham.jpeg