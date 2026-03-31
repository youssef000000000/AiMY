import '../entities/profile_entity.dart';

/// Abstract repository for profile data (candidate/lead).
/// Implementation will be added when backend/API is ready.
abstract class ProfileRepository {
  /// Fetches a single profile by id (e.g. for profile screen).
  Future<ProfileEntity?> getProfile(String id);

  /// Placeholder for list; can be extended later.
  // Future<List<ProfileEntity>> getProfiles();
}
