import 'package:aimy/core/core.dart';
import 'package:aimy/domain/domain.dart';
import 'package:flutter/material.dart';

import '../active_call/active_call_screen.dart';

class MiniPlayerScreen extends StatelessWidget {
  const MiniPlayerScreen({
    super.key,
    required this.profile,
    required this.elapsed,
    this.callSid,
  });

  final ProfileEntity profile;
  final Duration elapsed;
  final String? callSid;

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final avatar = profileAvatarImageProvider(profile);
    final time = _format(elapsed);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
            child: const SafeArea(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Mini-player mode\nYou can browse app content while call is active.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: AimyPhoneDesignTokens.textBody,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: AimyPhoneDesignTokens.miniPlayerTotalHeight,
              padding: const EdgeInsets.fromLTRB(
                AimyPhoneDesignTokens.space20,
                AimyPhoneDesignTokens.space12,
                AimyPhoneDesignTokens.space20,
                AimyPhoneDesignTokens.safeAreaBottom * 0.6,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border.withOpacity(0.8))),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: AimyPhoneDesignTokens.miniPlayerAvatarSize / 2,
                    backgroundColor: AppColors.cardBackground,
                    backgroundImage: avatar,
                    child: avatar == null
                        ? Text(
                            profile.displayName.isNotEmpty
                                ? profile.displayName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: AimyPhoneDesignTokens.textBodySm,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          time,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: AimyPhoneDesignTokens.textCaption,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(
                          builder: (_) => ActiveCallScreen(
                            profile: profile,
                            callSid: callSid,
                            initialElapsed: elapsed,
                          ),
                        ),
                      );
                    },
                    child: const Text('Return to call'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
