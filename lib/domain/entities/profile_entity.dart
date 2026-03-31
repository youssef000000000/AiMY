/// Domain entity: candidate or lead profile (AiMY Talent / AiMY Sales).
/// Used by the Profile (tap-to-call) screen.
class ProfileEntity {
  const ProfileEntity({
    required this.id,
    required this.displayName,
    this.title,
    this.company,
    this.phoneNumber,
    this.avatarUrl,
  });

  final String id;
  final String displayName;
  final String? title;
  final String? company;
  final String? phoneNumber;
  final String? avatarUrl;

  /// Whether the profile has a phone number (Call button visible).
  bool get canCall => phoneNumber != null && phoneNumber!.trim().isNotEmpty;
}
