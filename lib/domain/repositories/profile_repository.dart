import '../entities/profile_entity.dart';

/// Abstract repository for profile data (candidate/lead).
/// Implementation will be added when backend/API is ready.
abstract class ProfileRepository {
  /// Fetches a single profile by id (e.g. for profile screen).
  Future<ProfileEntity?> getProfile(String id);

  /// Persists post-call output (summary/notes/next step) for a profile.
  Future<void> savePostCallData({
    required String profileId,
    required String summary,
    required List<String> recruiterNotes,
    DateTime? scheduledInterviewAt,
  });

  /// Placeholder for list; can be extended later.
  // Future<List<ProfileEntity>> getProfiles();
}
