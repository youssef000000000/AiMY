import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:aimy/domain/domain.dart';
import 'package:aimy/data/data.dart';

/// ViewModel for Profile (tap-to-call) screen.
/// MVVM: presentation logic and state; no UI.
class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel({ProfileRepository? profileRepository})
      : _profileRepository = profileRepository ?? MockProfileRepository();

  final ProfileRepository _profileRepository;

  ProfileEntity? _profile;
  bool _isLoading = true;
  String? _error;

  bool _isPlacingCall = false;
  String? _callError;
  String? _lastCallSid;
  PostCallDataEntity? _postCallData;

  ProfileEntity? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isPlacingCall => _isPlacingCall;
  String? get callError => _callError;
  String? get lastCallSid => _lastCallSid;
  PostCallDataEntity? get postCallData => _postCallData;

  /// Loads profile by id (e.g. from route or list tap).
  Future<void> loadProfile(String profileId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _profileRepository.getProfile(profileId);
      _postCallData = await _profileRepository.getPostCallData(profileId);
      _error = null;
    } catch (e, st) {
      _error = e.toString();
      debugPrintStack(stackTrace: st);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Called when user taps Call.
  /// Demo mode: place a plain Twilio outbound call via our backend endpoint
  /// (no Twilio Voice SDK authentication required).
  void onCallTap() {
    if (_profile?.canCall != true) return;
    unawaited(_placeOutboundDemoCall(_profile!.phoneNumber!));
  }

  Future<void> _placeOutboundDemoCall(String toRaw) async {
    _isPlacingCall = true;
    _callError = null;
    _lastCallSid = null;
    notifyListeners();

    const baseUrl = String.fromEnvironment(
      'TWILIO_DEMO_SERVER_BASE_URL',
      defaultValue: 'http://10.0.2.2:3000',
    );

    final uri = Uri.parse('$baseUrl/twilio/outbound-call');

    final client = HttpClient();
    try {
      final payload = jsonEncode(<String, dynamic>{'to': toRaw});

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
      debugPrint('Twilio demo call created. sid=$_lastCallSid to=$toRaw');
    } catch (e, st) {
      _callError = e.toString();
      debugPrint('Twilio demo outbound call failed: $_callError');
      debugPrintStack(stackTrace: st);
    } finally {
      client.close(force: true);
      _isPlacingCall = false;
      notifyListeners();
    }
  }
}
