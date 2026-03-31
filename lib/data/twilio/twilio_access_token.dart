import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import 'package:aimy/core/config/twilio_config.dart';

/// Builds a Twilio Voice access token (JWT) for the mobile Voice SDK.
///
/// Twilio docs: https://www.twilio.com/docs/iam/access-tokens
class TwilioAccessToken {
  TwilioAccessToken._();

  /// [ttl] defaults to 1 hour; Twilio accepts typical short-lived tokens.
  static String mint({Duration ttl = const Duration(hours: 1)}) {
    if (!TwilioConfig.hasCredentials) {
      throw StateError(TwilioConfig.validateOrNull() ?? 'Missing Twilio config');
    }

    final jwt = JWT(
      {
        'grants': {
          'identity': TwilioConfig.clientIdentity,
          'voice': {
            'incoming': {'allow': true},
            'outgoing': {
              'application_sid': TwilioConfig.twimlApplicationSid,
            },
          },
        },
      },
      issuer: TwilioConfig.apiKeySid,
      subject: TwilioConfig.accountSid,
      jwtId:
          '${TwilioConfig.apiKeySid}-${DateTime.now().millisecondsSinceEpoch}',
    );

    return jwt.sign(
      SecretKey(TwilioConfig.apiKeySecret),
      algorithm: JWTAlgorithm.HS256,
      expiresIn: ttl,
    );
  }
}
