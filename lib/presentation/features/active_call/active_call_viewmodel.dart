import 'dart:async';

import 'package:flutter/foundation.dart';

/// ViewModel for the Active Call screen (UI-first, demo-focused).
class ActiveCallViewModel extends ChangeNotifier {
  ActiveCallViewModel({
    String? callSid,
    Duration initialElapsed = const Duration(minutes: 1, seconds: 12),
  })  : _callSid = callSid,
        _elapsed = initialElapsed {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed = _elapsed + const Duration(seconds: 1);
      notifyListeners();
    });
  }

  late final Timer _ticker;
  Duration _elapsed;
  bool _isMuted = false;
  bool _isOnHold = false;
  bool _isEnding = false;
  final String? _callSid;

  Duration get elapsed => _elapsed;
  bool get isMuted => _isMuted;
  bool get isOnHold => _isOnHold;
  bool get isEnding => _isEnding;
  String? get callSid => _callSid;

  List<String> get transcript => const [
    'Rep: Hi Youssef, thanks for taking this call.',
    'Candidate: Thanks, happy to speak now.',
    'Rep: I will share role details and next steps.',
    'Candidate: Sounds good, I am available this week.',
  ];

  void toggleMute() {
    _isMuted = !_isMuted;
    notifyListeners();
  }

  void toggleHold() {
    _isOnHold = !_isOnHold;
    notifyListeners();
  }

  Future<void> endCall() async {
    if (_isEnding) return;
    _isEnding = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 350));
  }

  String formatElapsed() {
    final m = _elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }
}
