import 'package:flutter/material.dart';
import '../core/theme/theme.dart';

/// Bottom prompt input: rounded AI-style field, placeholder, mic + send (Gemini-like).
class AIInputFieldWidget extends StatefulWidget {
  const AIInputFieldWidget({
    super.key,
    this.placeholder = 'Start to find the best talent...',
    this.onSubmitted,
    this.onMicTap,
  });

  final String placeholder;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onMicTap;

  @override
  State<AIInputFieldWidget> createState() => _AIInputFieldWidgetState();
}

class _AIInputFieldWidgetState extends State<AIInputFieldWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSubmitted?.call(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Left: attachment / options (Gemini-style)
            _IconButton(
              icon: Icons.add_circle_outline,
              onTap: () {},
            ),
            const SizedBox(width: 4),
            _IconButton(
              icon: Icons.apps_outlined,
              onTap: () {},
            ),
            const SizedBox(width: 8),
            // Center: text field
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: widget.placeholder,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 14,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(
                      Icons.auto_awesome,
                      size: 20,
                      color: AppColors.primary.withValues(alpha: 0.9),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 24,
                  ),
                ),
                style: Theme.of(context).textTheme.bodyLarge,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSubmit(),
                maxLines: 4,
                minLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            // Mic (focus per requirement - Gemini-like)
            _IconButton(
              icon: Icons.mic_none_outlined,
              onTap: widget.onMicTap ?? () {},
              highlight: true,
            ),
            const SizedBox(width: 4),
            // Send / AI action button
            _SendButton(onTap: _handleSubmit),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.onTap,
    this.highlight = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 22,
            color: highlight
                ? AppColors.primary
                : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            Icons.send_rounded,
            size: 20,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
