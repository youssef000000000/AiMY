import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

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
  final SpeechToText _speech = SpeechToText();
  final List<String> _liveTranscript = <String>[
    'Rep: Hi Youssef, thanks for taking this call.',
    'Candidate: Thanks, happy to speak now.',
    'Rep: I will share role details and next steps.',
    'Candidate: Sounds good, I am available this week.',
  ];
  Duration _elapsed;
  bool _isMuted = false;
  bool _isOnHold = false;
  bool _isEnding = false;
  bool _isVoiceAiActive = false;
  bool _isSpeechAvailable = false;
  bool _isListening = false;
  String _audioRoute = 'Earpiece';
  String? _transcriptError;
  final String? _callSid;

  Duration get elapsed => _elapsed;
  bool get isMuted => _isMuted;
  bool get isOnHold => _isOnHold;
  bool get isEnding => _isEnding;
  bool get isVoiceAiActive => _isVoiceAiActive;
  bool get isSpeechAvailable => _isSpeechAvailable;
  bool get isListening => _isListening;
  String get audioRoute => _audioRoute;
  String? get transcriptError => _transcriptError;
  String? get callSid => _callSid;

  List<String> get transcript => List.unmodifiable(_liveTranscript);

  void toggleMute() {
    _isMuted = !_isMuted;
    notifyListeners();
  }

  void toggleHold() {
    _isOnHold = !_isOnHold;
    notifyListeners();
  }

  void setAudioRoute(String route) {
    _audioRoute = route;
    notifyListeners();
  }

  void toggleVoiceAiHandoff() {
    _isVoiceAiActive = !_isVoiceAiActive;
    notifyListeners();
  }

  Future<void> toggleLiveMicTranscript() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
      notifyListeners();
      return;
    }

    _transcriptError = null;
    _isSpeechAvailable = await _speech.initialize(
      onError: (error) {
        _isListening = false;
        _transcriptError = error.errorMsg;
        notifyListeners();
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          _isListening = false;
          notifyListeners();
        }
      },
    );

    if (!_isSpeechAvailable) {
      _transcriptError = 'Speech recognition is not available on this device.';
      notifyListeners();
      return;
    }

    _isListening = true;
    notifyListeners();
    await _speech.listen(
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        partialResults: false,
      ),
      onResult: _onSpeechResult,
    );
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    final text = result.recognizedWords.trim();
    if (text.isEmpty || !result.finalResult) return;
    _liveTranscript.add('You: $text');
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
    unawaited(_speech.stop());
    super.dispose();
  }
}
