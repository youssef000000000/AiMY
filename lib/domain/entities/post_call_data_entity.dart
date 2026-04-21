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
}
