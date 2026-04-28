import 'package:aimy/data/data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MockProfileRepository post-call persistence', () {
    late MockProfileRepository repository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      repository = MockProfileRepository();
    });

    test('save then read post-call data', () async {
      await repository.savePostCallData(
        profileId: '1',
        summary: 'Saved summary',
        recruiterNotes: const ['note 1', 'note 2'],
        scheduledInterviewAt: DateTime(2026, 4, 24, 10, 0),
      );

      final data = await repository.getPostCallData('1');

      expect(data, isNotNull);
      expect(data!.profileId, '1');
      expect(data.summary, 'Saved summary');
      expect(data.recruiterNotes, ['note 1', 'note 2']);
      expect(data.scheduledInterviewAt, isNotNull);
    });

    test('clear removes saved post-call data', () async {
      await repository.savePostCallData(
        profileId: '1',
        summary: 'Saved summary',
        recruiterNotes: const ['note'],
      );
      await repository.clearPostCallData('1');

      final data = await repository.getPostCallData('1');
      expect(data, isNull);
    });
  });
}
