import 'package:flutter/material.dart';
import 'package:aimy/core/core.dart';
import 'package:aimy/domain/domain.dart';
import 'profile_viewmodel.dart';

/// Profile (tap-to-call) screen — Step 1 in outbound journey.
/// UI-only: Call button does not start a real call until Twilio SDK is integrated.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    this.profileId = '1',
    this.viewModel,
  });

  final String profileId;
  final ProfileViewModel? viewModel;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? ProfileViewModel();
    _viewModel.loadProfile(widget.profileId);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              if (_viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_viewModel.error != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _viewModel.error!,
                      style: const TextStyle(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              final p = _viewModel.profile;
              if (p == null) {
                return const Center(child: Text('Profile not found'));
              }
              return _buildContent(p);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ProfileEntity p) {
    const paddingH = AimyPhoneDesignTokens.screenPaddingH;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: paddingH,
        vertical: AimyPhoneDesignTokens.screenPaddingV,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () async {
                await _viewModel.clearDemoData();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Demo data reset')),
                );
              },
              icon: const Icon(Icons.restart_alt, size: 18),
              label: const Text('Reset demo'),
            ),
          ),
          const SizedBox(height: AimyPhoneDesignTokens.space8),
          _buildHeader(p),
          const SizedBox(height: AimyPhoneDesignTokens.space24),
          _buildContactSection(p),
          if (_viewModel.postCallData != null) ...[
            const SizedBox(height: AimyPhoneDesignTokens.space16),
            _buildPostCallSection(_viewModel.postCallData!),
          ],
          if (_viewModel.callError != null) ...[
            const SizedBox(height: 12),
            Text(
              _viewModel.callError!,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(ProfileEntity p) {
    // Layout/spacing tokens (phone design spec).
    final avatar = profileAvatarImageProvider(p);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: AimyPhoneDesignTokens.profileAvatarSize / 2,
          backgroundColor: AppColors.surface,
          backgroundImage: avatar,
          child: avatar == null
              ? Text(
                  p.displayName.isNotEmpty ? p.displayName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: AimyPhoneDesignTokens.textH1,
                    color: AppColors.onSurface,
                  ),
                )
              : null,
        ),
        const SizedBox(width: AimyPhoneDesignTokens.space16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.displayName,
                style: const TextStyle(
                  fontSize: AimyPhoneDesignTokens.textH2,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              if (p.title != null || p.company != null) ...[
                const SizedBox(height: AimyPhoneDesignTokens.space4),
                Text(
                  [p.title, p.company].whereType<String>().join(' • '),
                  style: const TextStyle(
                    fontSize: AimyPhoneDesignTokens.textBodySm,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(ProfileEntity p) {
    return Container(
      padding: const EdgeInsets.all(AimyPhoneDesignTokens.space20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AimyPhoneDesignTokens.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Phone',
                  style: TextStyle(
                    fontSize: AimyPhoneDesignTokens.textCaption,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: AimyPhoneDesignTokens.space4),
                Text(
                  p.phoneNumber ?? '—',
                  style: const TextStyle(
                    fontSize: AimyPhoneDesignTokens.textBody,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (p.canCall)
            GestureDetector(
              onTap: _viewModel.isPlacingCall ? null : _viewModel.onCallTap,
              child: Container(
                width: AimyPhoneDesignTokens.profileCallButtonSize,
                height: AimyPhoneDesignTokens.profileCallButtonSize,
                decoration: const BoxDecoration(
                  color: AimyPhoneDesignTokens.answerGreen,
                  shape: BoxShape.circle,
                ),
                child: _viewModel.isPlacingCall
                    ? const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.call,
                        color: Colors.white,
                        size: AimyPhoneDesignTokens.profileCallButtonIconSize,
                      ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime d) {
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    return '$day/$month/${d.year} $hour:$minute';
  }

  Widget _buildPostCallSection(PostCallDataEntity data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x3321262D),
        borderRadius: BorderRadius.circular(AimyPhoneDesignTokens.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Latest call outcome',
            style: TextStyle(
              color: Colors.white,
              fontSize: AimyPhoneDesignTokens.textBodySm,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.summary,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: AimyPhoneDesignTokens.textCaption,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Notes: ${data.recruiterNotes.length}',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: AimyPhoneDesignTokens.textCaption,
            ),
          ),
          if (data.scheduledInterviewAt != null) ...[
            const SizedBox(height: 4),
            Text(
              'Interview: ${_formatDateTime(data.scheduledInterviewAt!)}',
              style: const TextStyle(
                color: AppColors.accentBlue,
                fontSize: AimyPhoneDesignTokens.textCaption,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
