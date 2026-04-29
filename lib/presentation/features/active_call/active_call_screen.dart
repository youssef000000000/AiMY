import 'package:aimy/core/core.dart';
import 'package:aimy/domain/domain.dart';
import 'package:flutter/material.dart';

import 'active_call_viewmodel.dart';
import '../mini_player/mini_player_screen.dart';
import '../post_call/post_call_screen.dart';

class ActiveCallScreen extends StatefulWidget {
  const ActiveCallScreen({
    super.key,
    required this.profile,
    this.callSid,
    this.initialElapsed = const Duration(minutes: 1, seconds: 12),
    this.viewModel,
  });

  final ProfileEntity profile;
  final String? callSid;
  final Duration initialElapsed;
  final ActiveCallViewModel? viewModel;

  @override
  State<ActiveCallScreen> createState() => _ActiveCallScreenState();
}

class _ActiveCallScreenState extends State<ActiveCallScreen> {
  late final ActiveCallViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ??
        ActiveCallViewModel(
          callSid: widget.callSid,
          initialElapsed: widget.initialElapsed,
        );
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
              horizontal: 16,
              vertical: 12,
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
                      onMinimize: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute<void>(
                            builder: (_) => MiniPlayerScreen(
                              profile: widget.profile,
                              callSid: _viewModel.callSid,
                              elapsed: _viewModel.elapsed,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: CircleAvatar(
                        radius: 34,
                        backgroundColor: AppColors.surface,
                        backgroundImage: avatar,
                        child: avatar == null
                            ? Text(
                                widget.profile.displayName.isNotEmpty
                                    ? widget.profile.displayName[0]
                                        .toUpperCase()
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
                    const SizedBox(height: 12),
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
                      _viewModel.isVoiceAiActive
                          ? 'Voice AI monitoring'
                          : _viewModel.isOnHold
                              ? 'On hold'
                              : 'Connected • ${_viewModel.audioRoute}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AimyPhoneDesignTokens.textCaption,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _TranscriptCard(lines: _viewModel.transcript),
                    ),
                    const SizedBox(height: 10),
                    _LiveMicTranscriptBar(
                      isListening: _viewModel.isListening,
                      error: _viewModel.transcriptError,
                      onToggle: _viewModel.toggleLiveMicTranscript,
                    ),
                    const SizedBox(height: 10),
                    _VoiceAiHandoffCard(
                      isActive: _viewModel.isVoiceAiActive,
                      onToggle: _viewModel.toggleVoiceAiHandoff,
                    ),
                    const SizedBox(height: 10),
                    const _NudgesRow(),
                    const SizedBox(height: 12),
                    _ControlsRow(
                      isMuted: _viewModel.isMuted,
                      isOnHold: _viewModel.isOnHold,
                      isEnding: _viewModel.isEnding,
                      audioRoute: _viewModel.audioRoute,
                      onMute: _viewModel.toggleMute,
                      onHold: _viewModel.toggleHold,
                      onAudioRoute: () => _showAudioRouteSheet(context),
                      onEnd: () async {
                        final navigator = Navigator.of(context);
                        await _viewModel.endCall();
                        if (!mounted) return;
                        await navigator.pushReplacement(
                          MaterialPageRoute<void>(
                            builder: (_) => PostCallScreen(
                              profile: widget.profile,
                              elapsed: _viewModel.elapsed,
                              callSid: _viewModel.callSid,
                            ),
                          ),
                        );
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

  Future<void> _showAudioRouteSheet(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final route = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Audio route',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AimyPhoneDesignTokens.textBody,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                for (final option in const [
                  ('Earpiece', Icons.phone_in_talk),
                  ('Speaker', Icons.volume_up),
                  ('Bluetooth', Icons.bluetooth_audio),
                ])
                  _AudioRouteTile(
                    title: option.$1,
                    icon: option.$2,
                    selected: _viewModel.audioRoute == option.$1,
                    onTap: () => Navigator.of(context).pop(option.$1),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (route == null) return;
    _viewModel.setAudioRoute(route);
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text('Audio routed to $route')),
    );
  }
}

class _AudioRouteTile extends StatelessWidget {
  const _AudioRouteTile({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.accentBlue),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: selected
          ? const Icon(Icons.check_circle,
              color: AimyPhoneDesignTokens.answerGreen)
          : null,
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.name,
    required this.time,
    required this.onMinimize,
  });

  final String name;
  final String time;
  final VoidCallback onMinimize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: AimyPhoneDesignTokens.minTouchTarget,
          height: AimyPhoneDesignTokens.minTouchTarget,
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.55),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: IconButton(
            onPressed: onMinimize,
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: AppColors.primary),
            tooltip: 'Minimize call',
          ),
        ),
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
          const Row(
            children: [
              Icon(Icons.fiber_manual_record,
                  color: Color(0xFF45E07A), size: 10),
              SizedBox(width: 6),
              Text(
                'Live transcript',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: AimyPhoneDesignTokens.textBodySm,
                ),
              ),
            ],
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

class _LiveMicTranscriptBar extends StatelessWidget {
  const _LiveMicTranscriptBar({
    required this.isListening,
    required this.error,
    required this.onToggle,
  });

  final bool isListening;
  final String? error;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isListening ? const Color(0x223FB950) : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isListening
              ? AimyPhoneDesignTokens.answerGreen
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isListening ? Icons.graphic_eq : Icons.mic_none,
            color: isListening
                ? AimyPhoneDesignTokens.answerGreen
                : AppColors.accentBlue,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error ??
                  (isListening
                      ? 'Listening to your voice...'
                      : 'Live mic transcript demo'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: AimyPhoneDesignTokens.textCaption,
              ),
            ),
          ),
          TextButton(
            onPressed: onToggle,
            child: Text(isListening ? 'Stop' : 'Start'),
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
    return const SizedBox(
      height: 80,
      child: Row(
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
      ),
    );
  }
}

class _VoiceAiHandoffCard extends StatelessWidget {
  const _VoiceAiHandoffCard({
    required this.isActive,
    required this.onToggle,
  });

  final bool isActive;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isActive ? const Color(0x22A371F7) : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? AppColors.accentPurple : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.smart_toy : Icons.record_voice_over,
            color: isActive ? AppColors.accentPurple : AppColors.accentBlue,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isActive
                  ? 'Voice AI is handling the call. Monitoring live transcript.'
                  : 'Hand off to Voice AI for demo monitoring mode.',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: AimyPhoneDesignTokens.textCaption,
              ),
            ),
          ),
          TextButton(
            onPressed: onToggle,
            child: Text(isActive ? 'Reclaim' : 'Hand off'),
          ),
        ],
      ),
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
      height: double.infinity,
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
    required this.audioRoute,
    required this.onMute,
    required this.onHold,
    required this.onAudioRoute,
    required this.onEnd,
  });

  final bool isMuted;
  final bool isOnHold;
  final bool isEnding;
  final String audioRoute;
  final VoidCallback onMute;
  final VoidCallback onHold;
  final VoidCallback onAudioRoute;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ControlButton(
          icon: isMuted ? Icons.mic_off : Icons.mic,
          label: isMuted ? 'Unmute' : 'Mute',
          color: AppColors.accentBlue,
          onTap: onMute,
        ),
        _ControlButton(
          icon: isOnHold ? Icons.play_arrow_rounded : Icons.pause,
          label: isOnHold ? 'Resume' : 'Hold',
          color: AppColors.accentPurple,
          onTap: onHold,
        ),
        _ControlButton(
          icon: Icons.volume_up,
          label: audioRoute,
          color: AppColors.surface,
          onTap: onAudioRoute,
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
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0x33FFFFFF)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 12,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
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
