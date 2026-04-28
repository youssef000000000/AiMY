import 'package:flutter/material.dart';
import 'package:aimy/core/core.dart';
import 'package:aimy/domain/domain.dart';
import 'profile_viewmodel.dart';

/// Profile (tap-to-call) screen — Step 1 in outbound journey.
/// In demo mode this screen uses local persistence and native dialer launch.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    this.profileId = '1',
    this.viewModel,
    this.onBack,
  });

  final String profileId;
  final ProfileViewModel? viewModel;
  final VoidCallback? onBack;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileViewModel _viewModel;
  int _selectedTab = 0;

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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBackTap();
      },
      child: Scaffold(
        body: Container(
          decoration:
              const BoxDecoration(gradient: AppColors.backgroundGradient),
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
      ),
    );
  }

  Widget _buildContent(ProfileEntity p) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _handleBackTap,
                child: const SizedBox(
                  width: 64,
                  height: 56,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
              const Expanded(
                child: Text(
                  'Profile',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_horiz_rounded),
              ),
            ],
          ),
          const _DemoModeBadge(),
          const SizedBox(height: 10),
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
          const SizedBox(height: 8),
          _buildHeader(p),
          const SizedBox(height: 14),
          _buildContactSection(p),
          const SizedBox(height: 14),
          _buildTabs(),
          const SizedBox(height: 10),
          if (_selectedTab == 0) ...[
            _buildActivityTimeline(),
            if (_viewModel.postCallData != null) ...[
              const SizedBox(height: 10),
              _buildPostCallSection(_viewModel.postCallData!),
            ],
          ] else
            _buildNotesPanel(),
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

  void _handleBackTap() {
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  Widget _buildHeader(ProfileEntity p) {
    final avatar = profileAvatarImageProvider(p);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.surface,
            backgroundImage: avatar,
            child: avatar == null
                ? Text(
                    p.displayName.isNotEmpty
                        ? p.displayName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 22,
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.displayName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  [p.title, p.company].whereType<String>().join(' • '),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(ProfileEntity p) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
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
                  style:
                      const TextStyle(fontSize: 16, color: AppColors.onSurface),
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
                  color: Color(0xFF16A34A),
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
                        size: 26,
                      ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'Activity',
              selected: _selectedTab == 0,
              onTap: () => setState(() => _selectedTab = 0),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Notes',
              selected: _selectedTab == 1,
              onTap: () => setState(() => _selectedTab = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTimeline() {
    return const Column(
      children: [
        _TimelineItem(
          title: 'Application reviewed',
          subtitle: 'AI screening marked strong backend fit',
          time: 'Today, 11:34',
          icon: Icons.task_alt_rounded,
        ),
        SizedBox(height: 8),
        _TimelineItem(
          title: 'Recruiter call scheduled',
          subtitle: 'Pending final confirmation',
          time: 'Today, 10:15',
          icon: Icons.calendar_month_rounded,
        ),
        SizedBox(height: 8),
        _TimelineItem(
          title: 'Skills extracted',
          subtitle: 'Node.js, Flutter, and distributed systems',
          time: 'Yesterday',
          icon: Icons.auto_awesome_rounded,
        ),
      ],
    );
  }

  Widget _buildNotesPanel() {
    final notes = _viewModel.postCallData?.recruiterNotes ?? const <String>[];
    if (notes.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Text(
          'No recruiter notes yet. Add notes from Post-call Actions.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: notes
            .map(
              (note) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '• $note',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
            )
            .toList(),
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
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Latest call outcome',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.summary,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Notes: ${data.recruiterNotes.length}',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
          if (data.scheduledInterviewAt != null) ...[
            const SizedBox(height: 4),
            Text(
              'Interview: ${_formatDateTime(data.scheduledInterviewAt!)}',
              style: const TextStyle(
                color: AppColors.accentBlue,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DemoModeBadge extends StatelessWidget {
  const _DemoModeBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String time;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.selectedBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF2563EB)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE8F1FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF1D4ED8) : const Color(0xFF7C879D),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
