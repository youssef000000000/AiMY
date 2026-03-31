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

  bool get isPlacingCall => _isPlacingCall;
  String? get error => _error;
  String? get lastCallSid => _lastCallSid;

  Future<void> answerCall(ProfileEntity profile) async {
    if (_isPlacingCall || !profile.canCall) return;

    _isPlacingCall = true;
    _error = null;
    _lastCallSid = null;
    notifyListeners();

    final to = _normalizeE164(profile.phoneNumber!);

    try {
      await TwilioVoiceService.instance.placeOutboundCall(to);
      _lastCallSid = await TwilioVoice.instance.call.getSid();
    } catch (e) {
      _error = _friendlyError(e);
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

  static String _friendlyError(Object e) {
    final s = e.toString();
    if (s.contains('Firebase')) {
      return 'Firebase not configured. Add dart-define Firebase keys (see '
          'lib/core/config/firebase_options_dev.dart).';
    }
    if (s.contains('FCM') || s.contains('messaging')) {
      return 'Push (FCM) failed. Check Firebase app IDs and network on Android.';
    }
    if (s.contains('Twilio') || s.contains('setTokens')) {
      return 'Twilio registration failed. Check API keys, TwiML App SID, '
          'and Twilio debugger; on iOS ensure VoIP / PushKit is set up.';
    }
    if (s.contains('Microphone')) {
      return 'Microphone permission is required to place a call.';
    }
    if (s.contains('not supported on Windows') ||
        s.contains('not supported on Linux')) {
      return 'Twilio calls work on Android and iOS only. Use the emulator or a phone.';
    }
    return s;
  }
}
