import 'package:aimy/core/core.dart';
import 'package:aimy/domain/domain.dart';
import 'package:flutter/material.dart';

import 'active_call_viewmodel.dart';

class ActiveCallScreen extends StatefulWidget {
  const ActiveCallScreen({
    super.key,
    required this.profile,
    this.callSid,
    this.viewModel,
  });

  final ProfileEntity profile;
  final String? callSid;
  final ActiveCallViewModel? viewModel;

  @override
  State<ActiveCallScreen> createState() => _ActiveCallScreenState();
}

class _ActiveCallScreenState extends State<ActiveCallScreen> {
  late final ActiveCallViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? ActiveCallViewModel(callSid: widget.callSid);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatar = profileAvatarImageProvider(widget.profile);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AimyPhoneDesignTokens.screenPaddingH,
              vertical: AimyPhoneDesignTokens.screenPaddingV,
            ),
            child: ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TopBar(
                      name: widget.profile.displayName,
                      time: _viewModel.formatElapsed(),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: CircleAvatar(
                        radius: 34,
                        backgroundColor: AppColors.surface,
                        backgroundImage: avatar,
                        child: avatar == null
                            ? Text(
                                widget.profile.displayName.isNotEmpty
                                    ? widget.profile.displayName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 26,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      widget.profile.displayName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: AimyPhoneDesignTokens.textH2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _viewModel.isOnHold ? 'On hold' : 'Connected',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AimyPhoneDesignTokens.textCaption,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: _TranscriptCard(lines: _viewModel.transcript),
                    ),
                    const SizedBox(height: 12),
                    const _NudgesRow(),
                    const SizedBox(height: 14),
                    _ControlsRow(
                      isMuted: _viewModel.isMuted,
                      isOnHold: _viewModel.isOnHold,
                      isEnding: _viewModel.isEnding,
                      onMute: _viewModel.toggleMute,
                      onHold: _viewModel.toggleHold,
                      onEnd: () async {
                        await _viewModel.endCall();
                        if (!mounted) return;
                        Navigator.of(context).pop();
                      },
                    ),
                    if (_viewModel.callSid != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'sid: ${_viewModel.callSid}',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.name, required this.time});

  final String name;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.graphic_eq_rounded, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Active call with $name',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: AimyPhoneDesignTokens.textBodySm,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0x223FB950),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0x803FB950)),
          ),
          child: Text(
            time,
            style: const TextStyle(
              color: Color(0xFF81C784),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _TranscriptCard extends StatelessWidget {
  const _TranscriptCard({required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x3321262D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Live transcript',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: AimyPhoneDesignTokens.textBodySm,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.separated(
              itemBuilder: (_, i) => Text(
                lines[i],
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: AimyPhoneDesignTokens.textCaption,
                  height: 1.35,
                ),
              ),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: lines.length,
            ),
          ),
        ],
      ),
    );
  }
}

class _NudgesRow extends StatelessWidget {
  const _NudgesRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _NudgeCard(
            icon: Icons.lightbulb_outline,
            title: 'Nudge',
            message: 'Confirm notice period.',
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _NudgeCard(
            icon: Icons.task_alt,
            title: 'Action',
            message: 'Schedule technical interview.',
          ),
        ),
      ],
    );
  }
}

class _NudgeCard extends StatelessWidget {
  const _NudgeCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0x1A58A6FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderGlow),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.accentBlue),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlsRow extends StatelessWidget {
  const _ControlsRow({
    required this.isMuted,
    required this.isOnHold,
    required this.isEnding,
    required this.onMute,
    required this.onHold,
    required this.onEnd,
  });

  final bool isMuted;
  final bool isOnHold;
  final bool isEnding;
  final VoidCallback onMute;
  final VoidCallback onHold;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ControlButton(
          icon: isMuted ? Icons.mic_off : Icons.mic,
          label: isMuted ? 'Unmute' : 'Mute',
          color: AppColors.surface,
          onTap: onMute,
        ),
        _ControlButton(
          icon: isOnHold ? Icons.play_arrow_rounded : Icons.pause,
          label: isOnHold ? 'Resume' : 'Hold',
          color: AppColors.surface,
          onTap: onHold,
        ),
        _ControlButton(
          icon: isEnding ? Icons.hourglass_top : Icons.call_end,
          label: isEnding ? 'Ending' : 'End',
          color: AimyPhoneDesignTokens.declineRed,
          onTap: isEnding ? null : onEnd,
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Opacity(
            opacity: onTap == null ? 0.6 : 1,
            child: Container(
              width: AimyPhoneDesignTokens.activeCallControlButtonSize,
              height: AimyPhoneDesignTokens.activeCallControlButtonSize,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(
                icon,
                color: Colors.white,
                size: AimyPhoneDesignTokens.activeCallControlIconSize,
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
