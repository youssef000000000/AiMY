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
    this.avatarAssetPath,
  });

  final String id;
  final String displayName;
  final String? title;
  final String? company;
  final String? phoneNumber;
  final String? avatarUrl;
  /// Bundled image asset (e.g. `assets/images/youssef_emad.png`). Used before [avatarUrl].
  final String? avatarAssetPath;

  /// Whether the profile has a phone number (Call button visible).
  bool get canCall => phoneNumber != null && phoneNumber!.trim().isNotEmpty;
}
