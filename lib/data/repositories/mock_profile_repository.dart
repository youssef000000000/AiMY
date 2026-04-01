import 'package:aimy/domain/domain.dart';

/// In-memory implementation for UI-only step 1.
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
    );
  }
}
