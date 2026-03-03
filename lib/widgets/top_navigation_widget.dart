import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../models/models.dart';

/// Top bar with pill-style nav buttons and active state highlight.
class TopNavigationWidget extends StatelessWidget {
  const TopNavigationWidget({
    super.key,
    required this.items,
    required this.activeId,
    required this.onItemSelected,
    this.leading,
    this.trailing,
  });

  final List<NavItem> items;
  final String activeId;
  final ValueChanged<String> onItemSelected;
  final List<Widget>? leading;
  final List<Widget>? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (leading != null) ...leading!,
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: items.map((item) {
                final isActive = item.id == activeId;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _PillButton(
                    label: item.label,
                    isActive: isActive,
                    onTap: () => onItemSelected(item.id),
                  ),
                );
              }).toList(),
            ),
          ),
          if (trailing != null) ...trailing!,
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? AppColors.primary : AppColors.inputBackground,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isActive ? AppColors.onPrimary : AppColors.textMuted,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
          ),
        ),
      ),
    );
  }
}
