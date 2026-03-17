import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../data/local/home_facade.dart';
import '../../di/injection.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _facade = sl<HomeFacade>();
  HomeData? _data;
  bool _loading = true;

  // Motivational lines that rotate
  static const _motivations = [
    'Consistency beats intensity.',
    'One more question than yesterday.',
    'Small daily gains compound.',
    'The grind is the shortcut.',
    'Every question is a rep.',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _facade.loadHomeData();
      if (mounted) {
        setState(() {
          _data = data;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _motivationalLine {
    final dayOfYear = DateTime.now().difference(
      DateTime(DateTime.now().year),
    ).inDays;
    return _motivations[dayOfYear % _motivations.length];
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 1.5),
        ),
      );
    }

    final data = _data;
    if (data == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text('Could not load data', style: TextStyle(color: AppColors.grey500)),
        ),
      );
    }

    final now = DateTime.now();
    final dateStr = DateFormat('EEE, MMM d').format(now);
    final target = data.todayTarget;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          color: Colors.black,
          onRefresh: _loadData,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            children: [
              // Header row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CATch',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dateStr,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Settings gear
                  GestureDetector(
                    onTap: () => context.push('/settings'),
                    child: const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(
                        Icons.settings_outlined,
                        size: 22,
                        color: AppColors.grey500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Countdown + streak row
              Row(
                children: [
                  if (data.daysToExam != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.grey900,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${data.daysToExam} days to CAT',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (data.streak > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${data.streak} day streak',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey800,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 8),

              // Motivational line
              Text(
                _motivationalLine,
                style: const TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: AppColors.grey400,
                ),
              ),

              const SizedBox(height: 28),

              // Today's focus recommendation
              if (data.conceptsToReview > 0) ...[
                GestureDetector(
                  onTap: () => context.push('/learn/review'),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.grey50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.grey200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_outline, size: 20, color: AppColors.grey600),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${data.conceptsToReview} concepts due for review',
                            style: const TextStyle(fontSize: 14, color: AppColors.grey700),
                          ),
                        ),
                        const Icon(Icons.chevron_right, size: 18, color: AppColors.grey400),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Daily minimum
              const Text(
                'DAILY MINIMUM',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: AppColors.grey500,
                ),
              ),
              const SizedBox(height: 12),

              _buildChecklistItem('DILR', target.dilrMinCompleted, target.dilrMinTarget),
              _buildChecklistItem('Quant', target.qaMinCompleted, target.qaMinTarget),
              _buildChecklistItem('VARC', target.varcMinCompleted, target.varcMinTarget),

              const SizedBox(height: 16),

              if (!target.isDailyMinComplete)
                _buildButton(
                  'Start daily minimum',
                  onTap: () async {
                    await context.push('/practice/session?mode=daily_min');
                    _loadData();
                  },
                )
              else
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Daily minimum complete',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),

              const SizedBox(height: 36),

              // Focused practice
              const Text(
                'FOCUSED PRACTICE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: AppColors.grey500,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.grey200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Section.fromCode(target.focusSection ?? 'QA').label,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: target.focusTarget > 0
                            ? target.focusCompleted / target.focusTarget
                            : 0,
                        backgroundColor: AppColors.grey200,
                        valueColor: const AlwaysStoppedAnimation(AppColors.grey800),
                        minHeight: 3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${target.focusCompleted} of ${target.focusTarget}',
                      style: const TextStyle(fontSize: 13, color: AppColors.grey500),
                    ),
                    const SizedBox(height: 16),
                    _buildButton(
                      'Continue',
                      onTap: () async {
                        await context.push(
                          '/practice/session?mode=focused&section=${target.focusSection ?? "QA"}',
                        );
                        _loadData();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // Stats row
              if ((data.stats['total'] ?? 0) > 0) ...[
                const Text(
                  'STATS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: AppColors.grey500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatCell('Solved', '${data.stats['total']}'),
                    const SizedBox(width: 24),
                    _buildStatCell('Accuracy', '${data.stats['accuracy']}%'),
                    const SizedBox(width: 24),
                    _buildStatCell('Streak', '${data.streak}'),
                  ],
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistItem(String label, int completed, int target) {
    final done = completed >= target;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? AppColors.grey900 : Colors.white,
              border: Border.all(
                color: done ? AppColors.grey900 : AppColors.grey300,
                width: 1.5,
              ),
            ),
            child: done
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: done ? AppColors.grey500 : AppColors.grey900,
              decoration: done ? TextDecoration.lineThrough : null,
            ),
          ),
          const Spacer(),
          Text(
            '$completed/$target',
            style: TextStyle(
              fontSize: 14,
              color: done ? AppColors.grey400 : AppColors.grey600,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String label, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.grey900,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCell(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.grey500),
        ),
      ],
    );
  }
}
