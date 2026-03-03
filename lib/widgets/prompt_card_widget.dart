import 'package:flutter/material.dart';
import '../core/theme/theme.dart';

/// Suggestion prompt card with rounded corners, soft glow border, hover/tap animation.
class PromptCardWidget extends StatefulWidget {
  const PromptCardWidget({
    super.key,
    required this.prompt,
    required this.onTap,
  });

  final String prompt;
  final VoidCallback onTap;

  @override
  State<PromptCardWidget> createState() => _PromptCardWidgetState();
}

class _PromptCardWidgetState extends State<PromptCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _glow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scale.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.cardBackground,
                  border: Border.all(
                    color: Color.lerp(
                      AppColors.border,
                      AppColors.borderGlow,
                      _glow.value,
                    )!,
                    width: 1.5,
                  ),
                  boxShadow: [
                    if (_glow.value > 0)
                      BoxShadow(
                        color: AppColors.primaryGlow,
                        blurRadius: 12 * _glow.value,
                        spreadRadius: 0,
                      ),
                  ],
                ),
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.auto_awesome_outlined,
                  size: 20,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.prompt,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.onSurface,
                        ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
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
