import 'package:aimy/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PostCallDataEntity serializes/deserializes correctly', () {
    final savedAt = DateTime(2026, 4, 23, 12, 30);
    final scheduledAt = DateTime(2026, 4, 24, 10, 15);
    final entity = PostCallDataEntity(
      profileId: '1',
      summary: 'Call completed',
      recruiterNotes: const ['Strong communication', 'Follow up next week'],
      savedAt: savedAt,
      scheduledInterviewAt: scheduledAt,
    );

    final json = entity.toJson();
    final restored = PostCallDataEntity.fromJson(json);

    expect(restored.profileId, '1');
    expect(restored.summary, 'Call completed');
    expect(restored.recruiterNotes.length, 2);
    expect(restored.recruiterNotes.first, 'Strong communication');
    expect(restored.savedAt.toIso8601String(), savedAt.toIso8601String());
    expect(
      restored.scheduledInterviewAt?.toIso8601String(),
      scheduledAt.toIso8601String(),
    );
  });
}
