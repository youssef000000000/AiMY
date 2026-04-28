import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:aimy/domain/domain.dart';
import 'package:aimy/data/data.dart';
import 'package:url_launcher/url_launcher.dart';

/// ViewModel for Profile (tap-to-call) screen.
/// MVVM: presentation logic and state; no UI.
class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel({ProfileRepository? profileRepository})
      : _profileRepository = profileRepository ?? MockProfileRepository();

  final ProfileRepository _profileRepository;
  String? _currentProfileId;

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
    _currentProfileId = profileId;
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

  Future<void> clearDemoData() async {
    final profileId = _currentProfileId ?? _profile?.id;
    if (profileId == null) return;
    await _profileRepository.clearPostCallData(profileId);
    _postCallData = null;
    notifyListeners();
  }

  /// Called when user taps Call.
  /// Opens the native phone dialer with the profile number.
  void onCallTap() {
    if (_profile?.canCall != true) return;
    unawaited(_openPhoneDialer(_profile!.phoneNumber!));
  }

  Future<void> _openPhoneDialer(String toRaw) async {
    _isPlacingCall = true;
    _callError = null;
    _lastCallSid = null;
    notifyListeners();
    try {
      final to = _normalizeE164(toRaw);
      final uri = Uri(scheme: 'tel', path: to);
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) {
        _callError = 'Could not open phone dialer for $to.';
      }
    } catch (e, st) {
      _callError = 'Could not open phone dialer. ${e.toString()}';
      debugPrint('Dialer launch failed: $_callError');
      debugPrintStack(stackTrace: st);
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
}
