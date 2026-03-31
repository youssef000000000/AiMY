import 'package:flutter/material.dart';
import '../core/theme/theme.dart';

/// Website-style logo: gradient icon + "AiMY" + optional "Knowledge" subtitle.
class AimyLogoWidget extends StatelessWidget {
  const AimyLogoWidget({
    super.key,
    this.showKnowledge = true,
    this.iconSize = 28,
    this.fontSize = 18,
    this.compact = false,
  });

  final bool showKnowledge;
  final double iconSize;
  final double fontSize;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.accentGradient.createShader(bounds),
          child: Icon(Icons.auto_awesome, size: iconSize, color: Colors.white),
        ),
        SizedBox(width: compact ? 8 : 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.accentGradient.createShader(bounds),
              child: Text(
                'AiMY',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontSize: fontSize,
                    ),
              ),
            ),
            if (showKnowledge) ...[
              SizedBox(width: compact ? 4 : 6),
              Text(
                'Knowledge',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.onSurface,
                      fontSize: fontSize * 0.85,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
