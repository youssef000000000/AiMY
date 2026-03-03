import 'package:flutter/material.dart';
import '../core/theme/theme.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

/// Main AiMY dashboard: sidebar, top nav, center content, bottom input.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const List<NavItem> _navItems = [
    NavItem(id: 'sales', label: 'AiMY Sales'),
    NavItem(id: 'widgets', label: 'AiMY Widgets'),
    NavItem(id: 'intelligence', label: 'AiMY Intelligence'),
  ];

  static const List<String> _promptCards = [
    'Who is Ahmed Mahfouz at Flairstech?',
    'What are the top AI companies in Egypt?',
    'Who is Iman El Atter who worked at Flairstech?',
    'Can you tell me about Ahmed Mahfouz at Flairstech?',
    'How does the onboarding and implementation process work?',
    'Who is Iman Elattar?',
  ];

  static List<ChatItem> get _chatItems => [
        const ChatItem(
          id: '1',
          title: 'Software Engineer with 2 YOE Needed',
        ),
        const ChatItem(id: '2', title: 'Sick Leave Policy at Flairstech'),
        const ChatItem(id: '3', title: 'Who is Ahmed Mahfouz at Flairstech?'),
      ];

  String _activeNavId = 'sales';
  String? _selectedChatId = '3';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: _buildLayout(context),
      ),
      drawer: _buildDrawer(context),
    );
  }

  Widget _buildLayout(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = width >= 900;
        final isTablet = width >= 600 && width < 900;
        final isMobile = width < 600;

        if (isMobile) {
          return _buildMobileLayout(context);
        }
        if (isTablet) {
          return _buildTabletLayout(context);
        }
        return _buildDesktopLayout(context);
      },
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SidebarWidget(
          chats: _chatItems,
          selectedChatId: _selectedChatId,
          onChatSelected: (id) => setState(() => _selectedChatId = id),
          onNewChat: () => setState(() => _selectedChatId = null),
          sidebarWidth: 280,
        ),
        Expanded(
          child: Column(
            children: [
              TopNavigationWidget(
                items: _navItems,
                activeId: _activeNavId,
                onItemSelected: (id) => setState(() => _activeNavId = id),
                leading: [
                  IconButton(
                    icon: const Icon(Icons.call_outlined),
                    onPressed: () {},
                    color: AppColors.textMuted,
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {},
                    color: AppColors.textMuted,
                  ),
                ],
                trailing: [
                  _UserChip(
                    name: 'Samaa Mohamed',
                    status: 'Offline',
                  ),
                ],
              ),
              Expanded(child: _buildMainContent(context)),
              AIInputFieldWidget(
                placeholder: 'Start to find the best talent...',
                onSubmitted: (_) {},
                onMicTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SidebarWidget(
          chats: _chatItems,
          selectedChatId: _selectedChatId,
          onChatSelected: (id) => setState(() => _selectedChatId = id),
          onNewChat: () => setState(() => _selectedChatId = null),
          sidebarWidth: 260,
        ),
        Expanded(
          child: Column(
            children: [
              TopNavigationWidget(
                items: _navItems,
                activeId: _activeNavId,
                onItemSelected: (id) => setState(() => _activeNavId = id),
              ),
              Expanded(child: _buildMainContent(context)),
              AIInputFieldWidget(
                placeholder: 'Start to find the best talent...',
                onSubmitted: (_) {},
                onMicTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            color: AppColors.onSurface,
          ),
          title: ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.accentGradient.createShader(bounds),
            child: const Text('AiMY', style: TextStyle(color: Colors.white)),
          ),
          backgroundColor: Colors.transparent,
        ),
        TopNavigationWidget(
          items: _navItems,
          activeId: _activeNavId,
          onItemSelected: (id) => setState(() => _activeNavId = id),
        ),
        Expanded(child: _buildMainContent(context)),
        AIInputFieldWidget(
          placeholder: 'Start to find the best talent...',
          onSubmitted: (_) {},
          onMicTap: () {},
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.sidebarBackground,
      child: SidebarWidget(
        chats: _chatItems,
        selectedChatId: _selectedChatId,
        onChatSelected: (id) {
          setState(() => _selectedChatId = id);
          Navigator.of(context).pop();
        },
        onNewChat: () {
          setState(() => _selectedChatId = null);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final nav = _navItems.firstWhere(
      (e) => e.id == _activeNavId,
      orElse: () => _navItems.first,
    );
    final title = nav.label;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width >= 600 ? 32 : 16,
        vertical: 24,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.accentGradient.createShader(bounds),
              child: Text(
                title,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'AI-powered platform for knowledge management, automation, and smart insights.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textMuted,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _buildPromptGrid(context),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptGrid(BuildContext context) {
    final crossAxisCount = _getCrossAxisCount(context);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemCount: _promptCards.length,
      itemBuilder: (context, index) {
        return PromptCardWidget(
          prompt: _promptCards[index],
          onTap: () {},
        );
      },
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 900) return 3;
    if (width >= 600) return 2;
    return 1;
  }
}

class _UserChip extends StatelessWidget {
  const _UserChip({required this.name, required this.status});

  final String name;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.secondary,
          child: Text(
            name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join(),
            style: const TextStyle(
              color: AppColors.onPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontSize: 12,
                  ),
            ),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  status,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
