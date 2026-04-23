import 'dart:convert';

import 'package:aimy/domain/domain.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// In-memory profile for stakeholder demos (squad/manager).
/// Set [phoneNumber] to an E.164 number your Twilio account may call for tests.
/// Replace with real API/datasource when backend is ready.
class MockProfileRepository implements ProfileRepository {
  static const String _postCallPrefix = 'aimy.postcall.';
  @override
  Future<ProfileEntity?> getProfile(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return const ProfileEntity(
      id: '1',
      displayName: 'Youssef Emad',
      title: 'Senior Developer',
      company: 'AiMY Talent',
      phoneNumber: '+201065332025',
      avatarUrl: null,
      avatarAssetPath: 'assets/images/youssef_emad.png',
    );
  }

  @override
  Future<void> savePostCallData({
    required String profileId,
    required String summary,
    required List<String> recruiterNotes,
    DateTime? scheduledInterviewAt,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    final payload = PostCallDataEntity(
      profileId: profileId,
      summary: summary,
      recruiterNotes: List<String>.from(recruiterNotes),
      scheduledInterviewAt: scheduledInterviewAt,
      savedAt: DateTime.now(),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_postCallPrefix$profileId',
      jsonEncode(payload.toJson()),
    );
  }

  @override
  Future<PostCallDataEntity?> getPostCallData(String profileId) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_postCallPrefix$profileId');
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return PostCallDataEntity.fromJson(decoded);
  }

  @override
  Future<void> clearPostCallData(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_postCallPrefix$profileId');
  }
}
