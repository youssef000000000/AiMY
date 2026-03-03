import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import 'chat_list_item_widget.dart';
import '../../models/models.dart';

/// Left sidebar: app title, New Chat, search, scrollable chat history.
class SidebarWidget extends StatelessWidget {
  const SidebarWidget({
    super.key,
    required this.chats,
    required this.selectedChatId,
    required this.onChatSelected,
    required this.onNewChat,
    this.sidebarWidth,
  });

  final List<ChatItem> chats;
  final String? selectedChatId;
  final ValueChanged<String> onChatSelected;
  final VoidCallback onNewChat;
  final double? sidebarWidth;

  static const double _defaultWidth = 280;
  static const double _minWidth = 240;
  static const double _maxWidth = 360;

  double get width => sidebarWidth ?? _defaultWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.clamp(_minWidth, _maxWidth),
      decoration: const BoxDecoration(
        color: AppColors.sidebarBackground,
        border: Border(
          right: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          _buildNewChatButton(context),
          _buildSearchField(context),
          Expanded(child: _buildChatList(context)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => AppColors.accentGradient.createShader(bounds),
            child: const Icon(Icons.auto_awesome, size: 28, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Text(
            'AiMY',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewChatButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onNewChat,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, size: 20, color: AppColors.textMuted),
                const SizedBox(width: 8),
                Text(
                  'New chat',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search chats',
          prefixIcon: Icon(Icons.search, size: 20, color: AppColors.textMuted),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        style: Theme.of(context).textTheme.bodyMedium,
        onChanged: (_) {},
      ),
    );
  }

  Widget _buildChatList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return ChatListItemWidget(
          title: chat.title,
          isSelected: chat.id == selectedChatId,
          onTap: () => onChatSelected(chat.id),
        );
      },
    );
  }
}
