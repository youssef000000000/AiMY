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

  /// Ensures Firebase is initialized when [FirebaseOptionsDev] is complete.
  Future<void> _ensureFirebase() async {
    if (_firebaseInitialized) return;
    final opts = FirebaseOptionsDev.currentPlatform();
    if (opts == null) {
      throw StateError(
        FirebaseOptionsDev.missingMessage() ?? 'Firebase options missing',
      );
    }
    await Firebase.initializeApp(options: opts);
    _firebaseInitialized = true;
  }

  /// Requests mic/phone permissions, mints a Voice JWT, registers FCM (Android),
  /// and calls [TwilioVoice.instance.setTokens].
  Future<void> register() async {
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
      await TwilioVoice.instance.requestCallPhonePermission();
      await TwilioVoice.instance.requestReadPhoneStatePermission();
      await TwilioVoice.instance.registerPhoneAccount();
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

  /// Places an outbound PSTN call using your TwiML Application (bot / IVR).
  Future<void> placeOutboundCall(String toE164) async {
    if (!_registered) {
      await register();
    }
    final ok = await TwilioVoice.instance.call.place(
      from: TwilioConfig.clientIdentity,
      to: toE164,
      extraOptions: <String, dynamic>{
        '__TWI_SUBJECT': 'AiMY demo',
      },
    );
    if (ok != true) {
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
