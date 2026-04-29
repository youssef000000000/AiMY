import 'package:aimy/presentation/features/active_call/active_call_screen.dart';
import 'package:aimy/presentation/features/mini_player/mini_player_screen.dart';
import 'package:aimy/presentation/features/notifications/notification_center_screen.dart';
import 'package:aimy/presentation/features/profile/profile_screen.dart';
import 'package:aimy/domain/domain.dart';
import 'package:aimy/core/core.dart';
import 'package:flutter/material.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  int _currentIndex = 0;
  bool _showMiniPlayer = true;
  static const ProfileEntity _demoProfile = ProfileEntity(
    id: '1',
    displayName: 'Youssef Emad',
    title: 'Senior Developer',
    company: 'AiMY Talent',
    phoneNumber: '+201065332025',
    avatarAssetPath: 'assets/images/youssef_emad.png',
  );

  void _goHome() {
    if (_currentIndex == 0) return;
    setState(() => _currentIndex = 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: _showMiniPlayer ? 104 : 0),
                child: IndexedStack(
                  index: _currentIndex,
                  children: [
                    _buildDashboardTab(),
                    ProfileScreen(
                      onBack: _goHome,
                    ),
                    _buildCallsTab(context),
                    _buildMoreTab(),
                  ],
                ),
              ),
              if (_showMiniPlayer)
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 28,
                  child: _MiniPlayerBar(
                    onExpand: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const MiniPlayerScreen(
                            profile: _demoProfile,
                            elapsed: Duration(minutes: 3, seconds: 18),
                          ),
                        ),
                      );
                    },
                    onClose: () => setState(() => _showMiniPlayer = false),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.accentBlue,
        unselectedItemColor: AppColors.textMuted,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded), label: 'Menu'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
          BottomNavigationBarItem(
              icon: Icon(Icons.call_outlined), label: 'Calls'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: const [
        _SectionHeader(title: 'Main Menu', subtitle: 'Good Morning, Recruiter'),
        SizedBox(height: 12),
        _ActivityCard(),
        SizedBox(height: 12),
        _PerformanceChartCard(),
        SizedBox(height: 12),
        _TopCandidatesCard(),
      ],
    );
  }

  Widget _buildCallsTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Calls',
            subtitle: 'Active interview sessions',
          ),
          const SizedBox(height: 16),
          _SimpleCard(
            title: 'Continue Active Call',
            subtitle: 'Open candidate interview controls',
            trailing: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        const ActiveCallScreen(profile: _demoProfile),
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
              title: 'More', subtitle: 'Settings and utilities'),
          const SizedBox(height: 16),
          const _SimpleCard(
            title: 'Demo Mode',
            subtitle: 'Local data enabled for presentation',
          ),
          const SizedBox(height: 12),
          _SimpleCard(
            title: 'Notification Center',
            subtitle: 'Missed calls, callback reminders, and post-call alerts',
            trailing: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const NotificationCenterScreen(),
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard();

  @override
  Widget build(BuildContext context) {
    return _SimpleCard(
      title: 'Today',
      subtitle: '4 calls, 2 shortlisted, 1 pending feedback',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.selectedBackground,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          '+12%',
          style: TextStyle(
            color: AppColors.accentBlue,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _PerformanceChartCard extends StatelessWidget {
  const _PerformanceChartCard();

  @override
  Widget build(BuildContext context) {
    const bars = [52.0, 84.0, 68.0, 100.0, 76.0];
    return _SimpleCard(
      title: 'Weekly Performance',
      subtitle: 'Candidate progression score',
      trailing: SizedBox(
        height: 96,
        width: 170,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: bars
              .map(
                (value) => Container(
                  width: 20,
                  height: value,
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _TopCandidatesCard extends StatelessWidget {
  const _TopCandidatesCard();

  @override
  Widget build(BuildContext context) {
    const names = ['Ahmed Mahfouz', 'Mohmed Hani', 'Samaa Mohamed'];
    return _SimpleCard(
      title: 'Top Candidates',
      subtitle: 'Ranked by call quality and confidence',
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: names
            .map(
              (name) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '• $name',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _MiniPlayerBar extends StatelessWidget {
  const _MiniPlayerBar({required this.onExpand, required this.onClose});

  final VoidCallback onExpand;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onExpand,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFF303B4D),
                child: Icon(Icons.mic, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'On-call with Youssef Emad',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Tap to open controls',
                      style: TextStyle(color: Color(0xFFB7C0D1), fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon:
                    const Icon(Icons.close, color: Color(0xFFD0D6E2), size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SimpleCard extends StatelessWidget {
  const _SimpleCard({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          if (trailing != null) ...[
            const SizedBox(height: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}
