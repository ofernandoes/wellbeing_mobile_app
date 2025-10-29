// File: lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

/// Default [FirebaseOptions] for different platforms.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      // Use a common fallback for unsupported or desktop platforms
      default:
        return const FirebaseOptions(
          apiKey: 'PLACEHOLDER_API_KEY_DESKTOP',
          appId: '1:1234567890:web:987654321', // Dummy App ID
          messagingSenderId: '1234567890',
          projectId: 'wellbeing-mobile-app',
        );
    }
  }

  // NOTE: Replace the PLACEHOLDER values with your actual Firebase configuration.

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'PLACEHOLDER_ANDROID_API_KEY',
    appId: '1:1234567890:android:abcdef0123456789',
    messagingSenderId: '1234567890',
    projectId: 'wellbeing-mobile-app',
    storageBucket: 'wellbeing-mobile-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'PLACEHOLDER_IOS_API_KEY',
    appId: '1:1234567890:ios:abcdef0123456789',
    messagingSenderId: '1234567890',
    projectId: 'wellbeing-mobile-app',
    storageBucket: 'wellbeing-mobile-app.appspot.com',
    iosClientId: 'abcdef0123456789-xyzabcdef0123456789.apps.googleusercontent.com',
    iosBundleId: 'com.ofernandoes.wellbeingMobileApp',
  );
}
