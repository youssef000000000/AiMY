import 'dart:io' show Platform;

import 'package:aimy/core/config/firebase_options_dev.dart';
import 'package:aimy/core/config/twilio_config.dart';
import 'package:flutter/foundation.dart';

/// Demo blocker checks before Twilio Voice (Priority A: close the demo path).
class DemoPreflight {
  DemoPreflight._();

  /// Android / iOS only for Programmable Voice in this project.
  static bool get _voicePlatformSupported {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Human-readable blockers; empty means config passes static checks (still may fail at runtime).
  static List<String> evaluateBlockers() {
    final out = <String>[];

    if (!_voicePlatformSupported) {
      out.add(
        'Voice demo: use Android emulator or a physical iPhone (not Windows/web).',
      );
      return out;
    }

    if (!TwilioConfig.hasCredentials) {
      out.add(
        'Twilio: add TWILIO_ACCOUNT_SID, TWILIO_API_KEY_SID, '
        'TWILIO_API_KEY_SECRET, TWILIO_TWIML_APP_SID (run with config/dart_defines.json).',
      );
    } else if (TwilioConfig.isLikelyPlaceholder) {
      out.add(
        'Twilio: replace placeholder values in config/dart_defines.json with real Console values.',
      );
    }

    if (!FirebaseOptionsDev.isConfiguredForCurrentPlatform()) {
      final m = FirebaseOptionsDev.missingMessage();
      if (m != null) {
        out.add(m);
      }
    } else if (FirebaseOptionsDev.isLikelyPlaceholder) {
      out.add(
        'Firebase: replace placeholder values in config/dart_defines.json '
        '(Android package must be com.aimy.aimy).',
      );
    }

    return out;
  }

  static bool get isDemoConfigReady => evaluateBlockers().isEmpty;
}
