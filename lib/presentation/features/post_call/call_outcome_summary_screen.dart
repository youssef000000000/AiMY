import 'package:aimy/core/core.dart';
import 'package:aimy/domain/domain.dart';
import 'package:flutter/material.dart';

import '../profile/profile_screen.dart';

class CallOutcomeSummaryScreen extends StatelessWidget {
  const CallOutcomeSummaryScreen({
    super.key,
    required this.profile,
    required this.postCallData,
  });

  final ProfileEntity profile;
  final PostCallDataEntity postCallData;

  String _formatDateTime(DateTime d) {
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    return '$day/$month/${d.year} $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AimyPhoneDesignTokens.screenPaddingH,
              AimyPhoneDesignTokens.screenPaddingV,
              AimyPhoneDesignTokens.screenPaddingH,
              AimyPhoneDesignTokens.screenPaddingV,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0x1A58A6FF),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.borderGlow),
                  ),
                  child: const Text(
                    'Demo mode • local data',
                    style: TextStyle(
                      color: Color(0xFFCFE6FF),
                      fontSize: AimyPhoneDesignTokens.textCaption,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Call outcome summary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AimyPhoneDesignTokens.textH2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  profile.displayName,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AimyPhoneDesignTokens.textBodySm,
                  ),
                ),
                const SizedBox(height: 16),
                _InfoCard(
                  title: 'Summary',
                  body: postCallData.summary,
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  title: 'Recruiter notes',
                  body: postCallData.recruiterNotes.isEmpty
                      ? 'No notes added.'
                      : postCallData.recruiterNotes.map((n) => '• $n').join('\n'),
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  title: 'Interview',
                  body: postCallData.scheduledInterviewAt == null
                      ? 'Not scheduled yet.'
                      : 'Scheduled at ${_formatDateTime(postCallData.scheduledInterviewAt!)}',
                ),
                const SizedBox(height: 10),
                Text(
                  'Saved: ${_formatDateTime(postCallData.savedAt)}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: AimyPhoneDesignTokens.textCaption,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute<void>(
                          builder: (_) => ProfileScreen(profileId: profile.id),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text('Go to profile'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AimyPhoneDesignTokens.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: AimyPhoneDesignTokens.textBodySm,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: AimyPhoneDesignTokens.textCaption,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
