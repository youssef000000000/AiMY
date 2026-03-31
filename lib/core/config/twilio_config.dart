import 'package:flutter/foundation.dart';

/// Twilio Programmable Voice + Voice SDK configuration via `--dart-define`.
///
/// **Security:** API keys and secrets must not ship in production builds. Use a
/// token server and short-lived JWTs instead. This path exists only for local
/// development and first integration.
class TwilioConfig {
  TwilioConfig._();

  static const String accountSid =
      String.fromEnvironment('TWILIO_ACCOUNT_SID', defaultValue: '');
  static const String apiKeySid =
      String.fromEnvironment('TWILIO_API_KEY_SID', defaultValue: '');
  static const String apiKeySecret =
      String.fromEnvironment('TWILIO_API_KEY_SECRET', defaultValue: '');
  static const String twimlApplicationSid =
      String.fromEnvironment('TWILIO_TWIML_APP_SID', defaultValue: '');
  static const String clientIdentity =
      String.fromEnvironment('TWILIO_CLIENT_IDENTITY', defaultValue: 'aimy_client');

  static bool get hasCredentials =>
      accountSid.isNotEmpty &&
      apiKeySid.isNotEmpty &&
      apiKeySecret.isNotEmpty &&
      twimlApplicationSid.isNotEmpty;

  static String? validateOrNull() {
    if (hasCredentials) return null;
    return 'Twilio: set --dart-define=TWILIO_ACCOUNT_SID, TWILIO_API_KEY_SID, '
        'TWILIO_API_KEY_SECRET, TWILIO_TWIML_APP_SID (and optional TWILIO_CLIENT_IDENTITY).';
  }

  static void debugLogMissing() {
    final msg = validateOrNull();
    if (msg != null) {
      debugPrint('AiMY Twilio: $msg');
    }
  }
}
