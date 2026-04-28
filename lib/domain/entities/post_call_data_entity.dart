class PostCallDataEntity {
  const PostCallDataEntity({
    required this.profileId,
    required this.summary,
    required this.recruiterNotes,
    required this.savedAt,
    this.scheduledInterviewAt,
  });

  final String profileId;
  final String summary;
  final List<String> recruiterNotes;
  final DateTime savedAt;
  final DateTime? scheduledInterviewAt;

  Map<String, dynamic> toJson() {
    return {
      'profileId': profileId,
      'summary': summary,
      'recruiterNotes': recruiterNotes,
      'savedAt': savedAt.toIso8601String(),
      'scheduledInterviewAt': scheduledInterviewAt?.toIso8601String(),
    };
  }

  static PostCallDataEntity fromJson(Map<String, dynamic> json) {
    return PostCallDataEntity(
      profileId: json['profileId'] as String,
      summary: json['summary'] as String,
      recruiterNotes: (json['recruiterNotes'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      savedAt: DateTime.tryParse(json['savedAt'] as String? ?? '') ?? DateTime.now(),
      scheduledInterviewAt: json['scheduledInterviewAt'] == null
          ? null
          : DateTime.tryParse(json['scheduledInterviewAt'] as String),
    );
  }
}
