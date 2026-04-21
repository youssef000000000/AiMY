import 'package:aimy/core/core.dart';
import 'package:aimy/data/data.dart';
import 'package:aimy/domain/domain.dart';
import 'package:flutter/material.dart';

import '../active_call/active_call_screen.dart';
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
      await _viewModel.warmUpDemo();
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
        const hPad = AimyPhoneDesignTokens.screenPaddingH;
        const vPad = AimyPhoneDesignTokens.screenPaddingV;

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            hPad,
            vPad,
            hPad,
            vPad + AimyPhoneDesignTokens.safeAreaBottom * 0.35,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDemoStatusBanner(),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const SizedBox(height: 8),
                            const Text(
                              'Incoming Call',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: AimyPhoneDesignTokens.textH3,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Center(child: _buildAvatar()),
                            const SizedBox(height: 16),
                            Text(
                              _profile!.displayName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.1,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_profile!.title ?? 'Candidate'} • ${_profile!.company ?? 'AiMY Talent'}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: AimyPhoneDesignTokens.textBodySm,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildContextCard(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_viewModel.error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _viewModel.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: AimyPhoneDesignTokens.textCaption,
                  ),
                ),
              ],
              if (_viewModel.lastCallSid != null) ...[
                const SizedBox(height: 10),
                Text(
                  'Call started (sid: ${_viewModel.lastCallSid})',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AimyPhoneDesignTokens.answerGreen,
                    fontSize: AimyPhoneDesignTokens.textCaption,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              _buildActions(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDemoStatusBanner() {
    if (_viewModel.isWarmingUpDemo) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Preparing voice (Twilio + Firebase)…',
                style: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.95),
                  fontSize: AimyPhoneDesignTokens.textCaption,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (!_viewModel.isDemoConfigReady) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0x26FFB300),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0x80FFCA28)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFFFFE082), size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Running in demo mode. Answer will start a simulated call until Twilio/Firebase config is added.',
                  style: TextStyle(
                    color: Color(0xFFFFF8E1),
                    fontSize: AimyPhoneDesignTokens.textCaption,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_viewModel.warmUpError != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0x33C62828),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.error.withOpacity(0.6)),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Color(0xFFFFCDD2), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _viewModel.warmUpError!,
                  style: const TextStyle(
                    color: Color(0xFFFFCDD2),
                    fontSize: AimyPhoneDesignTokens.textCaption,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_viewModel.isTwilioRegistered) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0x332E7D32),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AimyPhoneDesignTokens.answerGreen.withOpacity(0.5),
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF81C784), size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Voice ready — tap Answer to place the demo call.',
                  style: TextStyle(
                    color: Color(0xFFC8E6C9),
                    fontSize: AimyPhoneDesignTokens.textCaption,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildAvatar() {
    final initial = _profile!.displayName.isNotEmpty
        ? _profile!.displayName[0].toUpperCase()
        : '?';
    final avatar = profileAvatarImageProvider(_profile!);

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
        backgroundImage: avatar,
        child: avatar == null
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x3321262D),
        borderRadius: BorderRadius.circular(AimyPhoneDesignTokens.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _ActionButton(
            color: AimyPhoneDesignTokens.answerGreen,
            icon: _viewModel.isPlacingCall ? Icons.hourglass_top : Icons.call,
            label: _viewModel.isPlacingCall ? 'Calling' : 'Answer',
            onTap: _viewModel.isPlacingCall ||
                    !_viewModel.canAttemptAnswer(_profile!)
                ? null
                : () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => _CallingScreen(
                          profile: _profile!,
                          viewModel: _viewModel,
                        ),
                      ),
                    );
                  },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            color: AimyPhoneDesignTokens.declineRed,
            icon: Icons.call_end,
            label: 'Decline',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Call declined')),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            color: AppColors.accentBlue,
            icon: Icons.alarm,
            label: 'Remind',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reminder set')),
              );
            },
          ),
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
        Material(
          color: Colors.transparent,
          child: InkResponse(
            onTap: onTap,
            radius: AimyPhoneDesignTokens.incomingCallActionButtonSize * 0.55,
            child: Opacity(
              opacity: disabled ? 0.6 : 1,
              child: Container(
                width: AimyPhoneDesignTokens.incomingCallActionButtonSize,
                height: AimyPhoneDesignTokens.incomingCallActionButtonSize,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: AimyPhoneDesignTokens.incomingCallActionIconSize,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _CallingScreen extends StatefulWidget {
  const _CallingScreen({
    required this.profile,
    required this.viewModel,
  });

  final ProfileEntity profile;
  final IncomingCallViewModel viewModel;

  @override
  State<_CallingScreen> createState() => _CallingScreenState();
}

class _CallingScreenState extends State<_CallingScreen>
    with WidgetsBindingObserver {
  bool _didStart = false;
  String? _localError;
  bool _waitingForReturnFromDialer = false;
  bool _sawBackgroundState = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didStart) return;
    _didStart = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _startCall();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_waitingForReturnFromDialer || _navigated) return;
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _sawBackgroundState = true;
      return;
    }
    if (state == AppLifecycleState.resumed && _sawBackgroundState) {
      _goToActiveCall();
    }
  }

  Future<void> _startCall() async {
    final ok = await widget.viewModel.answerCall(widget.profile);
    if (!mounted) return;
    if (ok) {
      if (widget.viewModel.lastCallUsedDemoFallback) {
        await _goToActiveCall();
        return;
      }
      setState(() {
        _waitingForReturnFromDialer = true;
      });
      return;
    }
    setState(() {
      _localError =
          widget.viewModel.error ?? 'Could not start the call. Please try again.';
    });
  }

  Future<void> _goToActiveCall() async {
    if (!mounted || _navigated) return;
    _navigated = true;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ActiveCallScreen(
          profile: widget.profile,
          callSid: widget.viewModel.lastCallSid,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 52,
                  height: 52,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                const SizedBox(height: 20),
                Text(
                  'Calling ${widget.profile.displayName}...',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AimyPhoneDesignTokens.textH3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.viewModel.willUseDemoFallback
                      ? 'Starting simulated call...'
                      : 'Opening phone app (dialer)...',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AimyPhoneDesignTokens.textBodySm,
                  ),
                ),
                if (_waitingForReturnFromDialer) ...[
                  const SizedBox(height: 10),
                  Text(
                    widget.viewModel.willUseDemoFallback
                        ? 'Simulated call is ready. Continue to Active Call.'
                        : 'After the dialer opens, return to AiMY to see Active Call.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: AimyPhoneDesignTokens.textCaption,
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: _goToActiveCall,
                    child: const Text('Continue in AiMY'),
                  ),
                ],
                if (_localError != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0x33C62828),
                      borderRadius: BorderRadius.circular(AimyPhoneDesignTokens.radiusMd),
                      border: Border.all(color: AppColors.error.withOpacity(0.6)),
                    ),
                    child: Text(
                      _localError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFFFCDD2),
                        fontSize: AimyPhoneDesignTokens.textCaption,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Back'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
