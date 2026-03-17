import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';

/// Practice tab — shows practice mode options.
class PracticeMenuScreen extends StatelessWidget {
  const PracticeMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            const Text(
              'Practice',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Choose a practice mode',
              style: TextStyle(fontSize: 14, color: AppColors.grey500),
            ),
            const SizedBox(height: 32),

            _PracticeOption(
              title: 'Daily Minimum',
              subtitle: '3 DILR + 5 QA + 3 VARC',
              icon: Icons.check_circle_outline,
              onTap: () => context.push('/practice/session?mode=daily_min'),
            ),
            const SizedBox(height: 12),

            _PracticeOption(
              title: 'Focused Practice',
              subtitle: 'Deep dive into one section',
              icon: Icons.center_focus_strong_outlined,
              onTap: () => _showSectionPicker(context),
            ),
            const SizedBox(height: 12),

            _PracticeOption(
              title: 'Smart Practice',
              subtitle: 'Adaptive — weakest topics first',
              icon: Icons.psychology_outlined,
              onTap: () => context.push('/practice/session?mode=adaptive'),
            ),
            const SizedBox(height: 12),

            _PracticeOption(
              title: 'Retry Missed',
              subtitle: 'Questions you got wrong this week',
              icon: Icons.replay_outlined,
              onTap: () => context.push('/practice/session?mode=retry_missed'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSectionPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose section',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              for (final section in Section.values) ...[
                ListTile(
                  title: Text(section.label),
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.pop(context);
                    context.push(
                      '/practice/session?mode=focused&section=${section.code}',
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PracticeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _PracticeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: AppColors.grey700),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.grey400,
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen practice session (outside bottom nav).
/// This is a temporary placeholder — will be refactored to BLoC in Phase 3.
class PracticeScreen extends StatelessWidget {
  final String mode;
  final String? section;

  const PracticeScreen({super.key, required this.mode, this.section});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(
          _modeLabel(),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Practice session — will be implemented in Phase 3',
          style: TextStyle(color: AppColors.grey500),
        ),
      ),
    );
  }

  String _modeLabel() {
    return switch (mode) {
      'daily_min' => 'Daily Minimum',
      'focused' => 'Focused: ${section ?? ""}',
      'adaptive' => 'Smart Practice',
      'retry_missed' => 'Retry Missed',
      _ => 'Practice',
    };
  }
}
