import 'package:aimy/core/core.dart';
import 'package:aimy/domain/domain.dart';
import 'package:aimy/presentation/features/profile/profile_screen.dart';
import 'package:flutter/material.dart';

class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({super.key});

  static const _profile = ProfileEntity(
    id: '1',
    displayName: 'Youssef Emad',
    title: 'Senior Developer',
    company: 'AiMY Talent',
    phoneNumber: '+201065332025',
    avatarAssetPath: 'assets/images/youssef_emad.png',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const Expanded(
                    child: Text(
                      'Notifications',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AimyPhoneDesignTokens.textH3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 12),
              _NotificationCard(
                icon: Icons.call_missed,
                title: 'Missed call',
                body: 'Youssef Emad called 8 minutes ago.',
                action: 'Open profile',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ProfileScreen(profileId: '1'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _NotificationCard(
                icon: Icons.task_alt,
                title: 'Post-call reminder',
                body: 'Complete summary and follow-up actions.',
                action: 'Review',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Post-call deep link demo')),
                  );
                },
              ),
              const SizedBox(height: 10),
              _NotificationCard(
                icon: Icons.phone_callback,
                title: 'Callback reminder',
                body: 'Callback reminder for ${_profile.displayName}.',
                action: 'Call back',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Callback action queued')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.action,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AimyPhoneDesignTokens.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentBlue, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: AimyPhoneDesignTokens.textBodySm,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AimyPhoneDesignTokens.textCaption,
                  ),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onTap, child: Text(action)),
        ],
      ),
    );
  }
}
