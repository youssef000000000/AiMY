import 'dart:io' show Platform;

import 'package:aimy/core/core.dart';
import 'package:aimy/data/twilio/twilio_voice_service.dart';
import 'package:aimy/domain/domain.dart';
import 'package:flutter/foundation.dart';
import 'package:twilio_voice/twilio_voice.dart';

/// ViewModel for the incoming-call screen.
///
/// [answerCall] uses the Twilio Programmable Voice SDK (`twilio_voice`) to
/// place an outbound PSTN call. Your TwiML Application URL should return
/// bot/IVR TwiML (e.g. `<Say>` then `<Hangup/>`).
class IncomingCallViewModel extends ChangeNotifier {
  bool _isPlacingCall = false;
  String? _error;
  String? _lastCallSid;
  bool _isWarmingUp = false;
  String? _warmUpError;

  bool get isPlacingCall => _isPlacingCall;
  String? get error => _error;
  String? get lastCallSid => _lastCallSid;

  bool get isWarmingUpDemo => _isWarmingUp;
  String? get warmUpError => _warmUpError;

  bool get isDemoConfigReady => DemoPreflight.isDemoConfigReady;

  bool get isTwilioRegistered => TwilioVoiceService.instance.isRegistered;

  /// Priority A: validate config + register Twilio before Answer (so demo issues surface early).
  Future<void> warmUpDemo() async {
    _warmUpError = null;
    notifyListeners();

    final blockers = DemoPreflight.evaluateBlockers();
    if (blockers.isNotEmpty) {
      _warmUpError = blockers.join('\n');
      notifyListeners();
      return;
    }

    _isWarmingUp = true;
    notifyListeners();

    try {
      await TwilioVoiceService.instance.register();
      _warmUpError = null;
    } catch (e) {
      _warmUpError = _friendlyRegistrationError(e);
    } finally {
      _isWarmingUp = false;
      notifyListeners();
    }
  }

  bool canAttemptAnswer(ProfileEntity profile) {
    return profile.canCall &&
        DemoPreflight.isDemoConfigReady &&
        !_isPlacingCall &&
        !_isWarmingUp;
  }

  Future<void> answerCall(ProfileEntity profile) async {
    if (_isPlacingCall || !profile.canCall) return;

    if (!DemoPreflight.isDemoConfigReady) {
      _error = DemoPreflight.evaluateBlockers().join('\n');
      notifyListeners();
      return;
    }

    _isPlacingCall = true;
    _error = null;
    _lastCallSid = null;
    notifyListeners();

    final to = _normalizeE164(profile.phoneNumber!);

    try {
      await TwilioVoiceService.instance.placeOutboundCall(to);
      _lastCallSid = await TwilioVoice.instance.call.getSid();
    } catch (e) {
      _error = _friendlyOutboundError(e);
    } finally {
      _isPlacingCall = false;
      notifyListeners();
    }
  }

  static String _normalizeE164(String raw) {
    final trimmed = raw.trim();
    final digits = trimmed.replaceAll(RegExp(r'[^\d+]'), '');
    if (digits.startsWith('+')) return digits;
    return '+$digits';
  }

  static String _sharedPrefixes(Object e) {
    final s = e.toString();
    if (s.contains('Firebase: set FIREBASE') ||
        s.contains('Firebase options missing')) {
      return 'Firebase not configured. Run with --dart-define-from-file=config/dart_defines.json '
          '(or use Run → AiMY Android in VS Code). See lib/core/config/firebase_options_dev.dart.';
    }
    if (s.contains('Firebase') || s.contains('firebase')) {
      return s.length > 500 ? '${s.substring(0, 500)}…' : s;
    }
    if (s.contains('FCM') || s.contains('messaging')) {
      return 'Push (FCM) failed. Check Firebase app IDs and network on Android.';
    }
    if (s.contains('Microphone')) {
      return 'Microphone permission is required to place a call.';
    }
    if (s.contains('not supported on Windows') ||
        s.contains('not supported on Linux')) {
      return 'Twilio calls work on Android and iOS only. Use the emulator or a phone.';
    }
    return '';
  }

  /// Errors from [TwilioVoiceService.register] / setTokens.
  static String _friendlyRegistrationError(Object e) {
    final shared = _sharedPrefixes(e);
    if (shared.isNotEmpty) return shared;

    final s = e.toString();
    if (s.contains('setTokens') || s.contains('Twilio')) {
      return 'Twilio registration failed. Check API keys, TwiML App SID, '
          'and Twilio debugger; on iOS ensure VoIP / PushKit is set up.';
    }
    return s;
  }

  /// Errors from placing an outbound call (often still contain the word "Twilio").
  static String _friendlyOutboundError(Object e) {
    final shared = _sharedPrefixes(e);
    if (shared.isNotEmpty) return shared;

    final s = e.toString();
    if (s.contains('android_telecom_place_failed')) {
      return 'Could not start the call: Android blocked the outgoing call. '
          'Grant Phone permissions (including Read phone numbers), open system Settings → '
          'Calling accounts / default phone app and enable AiMY, then try again. '
          'If the call connects but drops, then check TwiML Voice URL and Twilio Debugger.';
    }
    if (s.contains('could not start outbound') ||
        s.contains('outbound call') ||
        s.contains('call (result=')) {
      final twilioHint = !kIsWeb && Platform.isAndroid
          ? 'On Android, if this says result=false, fix Phone permissions and the calling account first; '
              'otherwise check TwiML Voice URL, E.164, trial verified numbers, and Twilio Debugger.'
          : 'Check TwiML App Voice URL returns dial TwiML, callee E.164 (trial: use verified numbers), '
              'and Twilio Monitor → Debugger.';
      return 'Could not start the call. $twilioHint';
    }
    if (s.contains('setTokens')) {
      return 'Twilio registration failed. Check API keys, TwiML App SID, and Twilio debugger.';
    }
    return s.length > 400 ? '${s.substring(0, 400)}…' : s;
  }
}
