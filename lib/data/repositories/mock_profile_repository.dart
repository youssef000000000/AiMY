import 'package:aimy/domain/domain.dart';

/// In-memory profile for stakeholder demos (squad/manager).
/// Set [phoneNumber] to an E.164 number your Twilio account may call for tests.
/// Replace with real API/datasource when backend is ready.
class MockProfileRepository implements ProfileRepository {
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
  }
}
