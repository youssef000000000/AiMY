import 'dart:convert';
import 'dart:io';

import 'package:aimy/domain/domain.dart';
import 'package:flutter/foundation.dart';

/// ViewModel for the incoming-call screen.
///
/// In this demo, tapping "Answer" triggers an outbound Twilio call through the
/// backend endpoint. This keeps calling logic outside the widget tree.
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

    final baseUrl = const String.fromEnvironment(
      'TWILIO_DEMO_SERVER_BASE_URL',
      defaultValue: 'http://10.0.2.2:3000',
    );

    final uri = Uri.parse('$baseUrl/twilio/outbound-call');
    final client = HttpClient();

    try {
      final payload = jsonEncode(<String, dynamic>{
        'to': profile.phoneNumber,
      });

      final request = await client.postUrl(uri);
      request.headers.contentType = ContentType.json;
      request.add(utf8.encode(payload));

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('HTTP ${response.statusCode}: $body');
      }

      final decoded = jsonDecode(body) as Map<String, dynamic>;
      _lastCallSid = decoded['sid'] as String?;
    } catch (e) {
      _error = e.toString();
    } finally {
      client.close(force: true);
      _isPlacingCall = false;
      notifyListeners();
    }
  }
}
