import 'package:aimy/domain/domain.dart';
import 'package:aimy/presentation/features/profile/profile_screen.dart';
import 'package:aimy/presentation/features/profile/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeProfileRepository implements ProfileRepository {
  PostCallDataEntity? _postCall = PostCallDataEntity(
    profileId: '1',
    summary: 'Saved summary',
    recruiterNotes: const ['note'],
    savedAt: DateTime(2026, 4, 23, 12, 0),
    scheduledInterviewAt: DateTime(2026, 4, 24, 10, 0),
  );

  @override
  Future<void> clearPostCallData(String profileId) async {
    _postCall = null;
  }

  @override
  Future<PostCallDataEntity?> getPostCallData(String profileId) async => _postCall;

  @override
  Future<ProfileEntity?> getProfile(String id) async {
    return const ProfileEntity(
      id: '1',
      displayName: 'Youssef Emad',
      title: 'Senior Developer',
      company: 'AiMY Talent',
      phoneNumber: '+201065332025',
    );
  }

  @override
  Future<void> savePostCallData({
    required String profileId,
    required String summary,
    required List<String> recruiterNotes,
    DateTime? scheduledInterviewAt,
  }) async {
    _postCall = PostCallDataEntity(
      profileId: profileId,
      summary: summary,
      recruiterNotes: recruiterNotes,
      savedAt: DateTime.now(),
      scheduledInterviewAt: scheduledInterviewAt,
    );
  }
}

void main() {
  testWidgets('reset demo clears latest call outcome section', (tester) async {
    final viewModel = ProfileViewModel(profileRepository: _FakeProfileRepository());

    await tester.pumpWidget(
      MaterialApp(
        home: ProfileScreen(viewModel: viewModel),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Latest call outcome'), findsOneWidget);

    await tester.tap(find.text('Reset demo'));
    await tester.pumpAndSettle();

    expect(find.text('Latest call outcome'), findsNothing);
    expect(find.text('Demo data reset'), findsOneWidget);
  });
}
