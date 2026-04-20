import 'dart:async';
import 'dart:io' show Platform;

import 'package:aimy/core/config/firebase_options_dev.dart';
import 'package:aimy/core/config/twilio_config.dart';
import 'package:aimy/data/twilio/twilio_access_token.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:twilio_voice/twilio_voice.dart';

/// Twilio Programmable Voice SDK wrapper (Android + iOS).
///
/// Android requires Firebase Cloud Messaging so the plugin can register with
/// Twilio (`deviceToken` on `setTokens`). iOS obtains the VoIP device token
/// inside the native plugin (PushKit); still initialize Firebase if you use FCM.
class TwilioVoiceService {
  TwilioVoiceService._();

  static final TwilioVoiceService instance = TwilioVoiceService._();

  bool _firebaseInitialized = false;
  bool _registered = false;
  StreamSubscription<CallEvent>? _eventSub;

  /// Whether [register] completed successfully this session.
  bool get isRegistered => _registered;

  /// Ensures Firebase is initialized when [FirebaseOptionsDev] is complete.
  Future<void> _ensureFirebase() async {
    if (_firebaseInitialized) return;
    // Hot restart / native google-services may already create [DEFAULT]; avoid duplicate-app.
    if (Firebase.apps.isNotEmpty) {
      _firebaseInitialized = true;
      return;
    }
    final opts = FirebaseOptionsDev.currentPlatform();
    if (opts == null) {
      throw StateError(
        FirebaseOptionsDev.missingMessage() ?? 'Firebase options missing',
      );
    }
    try {
      await Firebase.initializeApp(options: opts);
    } on FirebaseException catch (e) {
      // Native `google-services` often creates [DEFAULT] before Dart runs;
      // `Firebase.apps` can still be empty until after this call fails.
      if (e.code != 'duplicate-app') rethrow;
    } catch (e) {
      final msg = e.toString();
      if (!msg.contains('duplicate-app') && !msg.contains('already exists')) {
        rethrow;
      }
    }
    _firebaseInitialized = true;
  }

  /// Requests mic/phone permissions, mints a Voice JWT, registers FCM (Android),
  /// and calls [TwilioVoice.instance.setTokens].
  Future<void> register() async {
    if (_registered) {
      return;
    }

    if (Platform.isWindows || Platform.isLinux) {
      throw UnsupportedError(
        'Twilio Programmable Voice is not supported on Windows/Linux desktop. '
        'Use Android or iOS for calls; Windows is for UI preview only.',
      );
    }

    final cfgErr = TwilioConfig.validateOrNull();
    if (cfgErr != null) {
      throw StateError(cfgErr);
    }

    await _ensureFirebase();

    final mic = await Permission.microphone.request();
    if (!mic.isGranted) {
      throw StateError('Microphone permission denied.');
    }

    if (!kIsWeb && Platform.isAndroid) {
      // Telecom's `hasCallCapableAccount` returns false if READ_PHONE_STATE is
      // missing — request phone permissions in one place, then Twilio-specific.
      await Permission.phone.request();
      await TwilioVoice.instance.requestReadPhoneStatePermission();
      await TwilioVoice.instance.requestReadPhoneNumbersPermission();
      await TwilioVoice.instance.requestCallPhonePermission();
      await TwilioVoice.instance.requestManageOwnCallsPermission();
      await _syncAndroidPhoneAccountWithTelecom();
    }

    String? fcm;
    if (!kIsWeb && Platform.isAndroid) {
      fcm = await FirebaseMessaging.instance.getToken();
      if (fcm == null || fcm.isEmpty) {
        throw StateError(
          'FCM registration token is empty. Confirm Firebase app IDs and network.',
        );
      }
    }

    final accessToken = TwilioAccessToken.mint();
    final ok = await TwilioVoice.instance.setTokens(
      accessToken: accessToken,
      deviceToken: fcm,
    );
    if (ok != true) {
      throw StateError(
        'Twilio setTokens failed. On iOS wait for VoIP push registration logs; '
        'on Android ensure FCM is valid.',
      );
    }

    _registered = true;
    _eventSub ??= TwilioVoice.instance.callEventsListener.listen((event) {
      if (event == CallEvent.log) return;
      debugPrint('TwilioVoice event: $event');
    });
  }

  /// Registers the ConnectionService [PhoneAccount] with Telecom and ensures it
  /// is enabled; otherwise outgoing [call.place] fails with "No registered phone account".
  Future<void> _syncAndroidPhoneAccountWithTelecom() async {
    if (kIsWeb || !Platform.isAndroid) return;
    final tv = TwilioVoice.instance;
    var openedPhoneAccountSettings = false;
    for (var i = 0; i < 6; i++) {
      await tv.registerPhoneAccount();
      final stateOk = await tv.hasReadPhoneStatePermission();
      final numsOk = await tv.hasReadPhoneNumbersPermission();
      final registered = await tv.hasRegisteredPhoneAccount();
      final enabled = await tv.isPhoneAccountEnabled();
      debugPrint(
        'TwilioVoice telecom sync attempt=$i readState=$stateOk readNums=$numsOk '
        'registered=$registered enabled=$enabled',
      );
      if (stateOk && numsOk && registered && enabled) {
        return;
      }
      if (registered && !enabled && !openedPhoneAccountSettings) {
        openedPhoneAccountSettings = true;
        debugPrint(
          'TwilioVoice: opening Phone account settings — enable AiMY for calling.',
        );
        await tv.openPhoneAccountSettings();
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }
  }

  /// Places an outbound PSTN call using your TwiML Application (bot / IVR).
  Future<void> placeOutboundCall(String toE164) async {
    if (!_registered) {
      await register();
    }
    if (!kIsWeb && Platform.isAndroid) {
      await _syncAndroidPhoneAccountWithTelecom();
    }
    final ok = await TwilioVoice.instance.call.place(
      from: TwilioConfig.clientIdentity,
      to: toE164,
      extraOptions: <String, dynamic>{
        '__TWI_SUBJECT': 'AiMY demo',
      },
    );
    if (ok != true) {
      if (Platform.isAndroid) {
        debugPrint(
          'TwilioVoice call.place returned $ok on Android. The system rejected '
          'the outgoing call before Twilio ran your TwiML (not a Voice URL issue yet). '
          'Grant READ_PHONE_NUMBERS + CALL_PHONE, enable the app Phone account '
          '(Settings → Default apps / Calling accounts), then retry. '
          'Filter logcat: TwilioVoicePlugin. to=$toE164 from=${TwilioConfig.clientIdentity}',
        );
        throw StateError(
          'android_telecom_place_failed: TwilioVoice call.place returned $ok',
        );
      }
      debugPrint(
        'TwilioVoice call.place returned $ok (expected true). to=$toE164 '
        'from=${TwilioConfig.clientIdentity}. Check TwiML App Voice URL and Debugger.',
      );
      throw StateError('Twilio could not start outbound call (result=$ok).');
    }
  }

  Future<void> hangUp() async {
    await TwilioVoice.instance.call.hangUp();
  }

  void dispose() {
    unawaited(_eventSub?.cancel());
    _eventSub = null;
  }
}
