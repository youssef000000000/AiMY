import 'package:aimy/core/core.dart';
import 'package:aimy/data/data.dart';
import 'package:aimy/domain/domain.dart';
import 'package:flutter/material.dart';

import 'incoming_call_viewmodel.dart';

class IncomingCallScreen extends StatefulWidget {
  const IncomingCallScreen({
    super.key,
    this.profileId = '1',
    this.viewModel,
    this.profileRepository,
  });

  final String profileId;
  final IncomingCallViewModel? viewModel;
  final ProfileRepository? profileRepository;

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  late final IncomingCallViewModel _viewModel;
  late final ProfileRepository _profileRepository;

  ProfileEntity? _profile;
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? IncomingCallViewModel();
    _profileRepository = widget.profileRepository ?? MockProfileRepository();
    _loadProfile();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final loaded = await _profileRepository.getProfile(widget.profileId);
      setState(() {
        _profile = loaded;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _loadError = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _loadError!,
            style: const TextStyle(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (_profile == null) {
      return const Center(child: Text('Profile not found'));
    }

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AimyPhoneDesignTokens.screenPaddingH,
            vertical: AimyPhoneDesignTokens.screenPaddingV,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Incoming Call',
                style: TextStyle(
                  fontSize: AimyPhoneDesignTokens.textH3,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 42),
              _buildAvatar(),
              const SizedBox(height: 18),
              Text(
                _profile!.displayName,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_profile!.title ?? 'Candidate'} • ${_profile!.company ?? 'AiMY Talent'}',
                style: const TextStyle(
                  fontSize: AimyPhoneDesignTokens.textBodySm,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              _buildContextCard(),
              const SizedBox(height: 32),
              if (_viewModel.error != null) ...[
                Text(
                  _viewModel.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: AimyPhoneDesignTokens.textCaption,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              if (_viewModel.lastCallSid != null) ...[
                Text(
                  'Call started (sid: ${_viewModel.lastCallSid})',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AimyPhoneDesignTokens.answerGreen,
                    fontSize: AimyPhoneDesignTokens.textCaption,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              _buildActions(context),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatar() {
    final initial = _profile!.displayName.isNotEmpty
        ? _profile!.displayName[0].toUpperCase()
        : '?';

    return Container(
      width: AimyPhoneDesignTokens.incomingCallAvatarSize,
      height: AimyPhoneDesignTokens.incomingCallAvatarSize,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white54, width: 3),
      ),
      child: CircleAvatar(
        backgroundColor: AppColors.surface,
        backgroundImage:
            _profile!.avatarUrl != null ? NetworkImage(_profile!.avatarUrl!) : null,
        child: _profile!.avatarUrl == null
            ? Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: AimyPhoneDesignTokens.textH1,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildContextCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x3321262D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Candidate Context',
            style: TextStyle(
              color: Colors.white,
              fontSize: AimyPhoneDesignTokens.textBodySm,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10),
          _ContextRow(
            icon: Icons.verified,
            leading: '94%',
            title: 'Match Score: Excellent',
          ),
          SizedBox(height: 8),
          _ContextRow(
            icon: Icons.access_time_filled,
            title: 'Last Contact',
            trailing: '2 days ago',
          ),
          SizedBox(height: 8),
          _ContextRow(
            icon: Icons.description_rounded,
            title: 'Recent Activity',
            trailing: 'Applied for Backend role',
          ),
          SizedBox(height: 8),
          _ContextRow(
            icon: Icons.checklist_rounded,
            title: 'Open Action Items',
            trailing: '2 Action Items',
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionButton(
          color: AimyPhoneDesignTokens.answerGreen,
          icon: _viewModel.isPlacingCall ? Icons.hourglass_top : Icons.call,
          label: _viewModel.isPlacingCall ? 'Calling' : 'Answer',
          onTap: _viewModel.isPlacingCall
              ? null
              : () => _viewModel.answerCall(_profile!),
        ),
        _ActionButton(
          color: AimyPhoneDesignTokens.declineRed,
          icon: Icons.call_end,
          label: 'Decline',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Call declined')),
            );
          },
        ),
        _ActionButton(
          color: AppColors.accentBlue,
          icon: Icons.alarm,
          label: 'Remind me',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reminder set')),
            );
          },
        ),
      ],
    );
  }
}

class _ContextRow extends StatelessWidget {
  const _ContextRow({
    required this.icon,
    required this.title,
    this.leading,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? leading;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        if (leading != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0x2245E07A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              leading!,
              style: const TextStyle(
                color: Color(0xFF45E07A),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        if (trailing != null)
          Flexible(
            child: Text(
              trailing!,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.onSurface,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.color,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Opacity(
            opacity: disabled ? 0.6 : 1,
            child: Container(
              width: AimyPhoneDesignTokens.incomingCallActionButtonSize,
              height: AimyPhoneDesignTokens.incomingCallActionButtonSize,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: AimyPhoneDesignTokens.incomingCallActionIconSize,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: AimyPhoneDesignTokens.textCaption,
          ),
        ),
      ],
    );
  }
}
