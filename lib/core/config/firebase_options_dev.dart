import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase options from `--dart-define` (no google-services.json required).
/// Add a Firebase app for Android + iOS and paste values from the console.
class FirebaseOptionsDev {
  FirebaseOptionsDev._();

  static const String _apiKey =
      String.fromEnvironment('FIREBASE_API_KEY', defaultValue: '');
  static const String _projectId =
      String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: '');
  static const String _messagingSenderId =
      String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID', defaultValue: '');
  static const String _storageBucket =
      String.fromEnvironment('FIREBASE_STORAGE_BUCKET', defaultValue: '');
  static const String _androidAppId =
      String.fromEnvironment('FIREBASE_ANDROID_APP_ID', defaultValue: '');
  static const String _iosAppId =
      String.fromEnvironment('FIREBASE_IOS_APP_ID', defaultValue: '');

  static bool isConfiguredForCurrentPlatform() {
    if (kIsWeb) return false;
    if (_apiKey.isEmpty || _projectId.isEmpty || _messagingSenderId.isEmpty) {
      return false;
    }
    if (Platform.isAndroid) return _androidAppId.isNotEmpty;
    if (Platform.isIOS) return _iosAppId.isNotEmpty;
    return false;
  }

  static FirebaseOptions? currentPlatform() {
    if (kIsWeb) return null;
    if (_apiKey.isEmpty || _projectId.isEmpty || _messagingSenderId.isEmpty) {
      return null;
    }

    final bucket =
        _storageBucket.isEmpty ? '$_projectId.appspot.com' : _storageBucket;

    if (Platform.isAndroid) {
      if (_androidAppId.isEmpty) return null;
      return FirebaseOptions(
        apiKey: _apiKey,
        appId: _androidAppId,
        messagingSenderId: _messagingSenderId,
        projectId: _projectId,
        storageBucket: bucket,
      );
    }
    if (Platform.isIOS) {
      if (_iosAppId.isEmpty) return null;
      return FirebaseOptions(
        apiKey: _apiKey,
        appId: _iosAppId,
        messagingSenderId: _messagingSenderId,
        projectId: _projectId,
        storageBucket: bucket,
        iosBundleId: 'com.aimy.aimy',
      );
    }
    return null;
  }

  static String? missingMessage() {
    if (isConfiguredForCurrentPlatform()) return null;
    return 'Firebase: set FIREBASE_API_KEY, FIREBASE_PROJECT_ID, '
        'FIREBASE_MESSAGING_SENDER_ID, FIREBASE_ANDROID_APP_ID (Android) or '
        'FIREBASE_IOS_APP_ID (iOS). Optional: FIREBASE_STORAGE_BUCKET. '
        'FCM token is required on Android for Twilio Voice registration.';
  }
}
