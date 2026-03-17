import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants.dart';
import 'cubit/stats_cubit.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatsCubit, StatsState>(
      builder: (context, state) {
        if (state.loading) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.black,
                strokeWidth: 1.5,
              ),
            ),
          );
        }

        final total = state.overall['total'] ?? 0;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: RefreshIndicator(
              color: Colors.black,
              onRefresh: () => context.read<StatsCubit>().load(),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                children: [
                  const Text(
                    'Stats',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Your performance analytics',
                    style: TextStyle(fontSize: 14, color: AppColors.grey500),
                  ),

                  const SizedBox(height: 28),

                  if (total == 0) ...[
                    const SizedBox(height: 100),
                    const Center(
                      child: Text(
                        'No questions answered yet.\nStart practicing to see your stats.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.grey400,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ] else ...[
                    // Overall stats row
                    Row(
                      children: [
                        _StatCard(
                          label: 'Solved',
                          value: '$total',
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          label: 'Correct',
                          value: '${state.overall['correct'] ?? 0}',
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          label: 'Accuracy',
                          value: '${state.overall['accuracy'] ?? 0}%',
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Topic breakdown
                    const Text(
                      'BY TOPIC',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: AppColors.grey500,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ...state.byTopic.map((row) {
                      final topic = row['topic'] as String;
                      final section = row['section'] as String;
                      final topicTotal = (row['total'] as num?)?.toInt() ?? 0;
                      final correct = (row['correct'] as num?)?.toInt() ?? 0;
                      final accuracy =
                          ((row['accuracy'] as num?)?.toDouble() ?? 0) * 100;

                      return _TopicRow(
                        topic: topic,
                        section: section,
                        total: topicTotal,
                        correct: correct,
                        accuracy: accuracy,
                      );
                    }),

                    const SizedBox(height: 32),

                    // Daily activity
                    if (state.dailyAccuracy.isNotEmpty) ...[
                      const Text(
                        'DAILY ACTIVITY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: AppColors.grey500,
                        ),
                      ),
                      const SizedBox(height: 12),

                      ...state.dailyAccuracy.map((row) {
                        final date = row['date'] as String;
                        final dayTotal =
                            (row['total'] as num?)?.toInt() ?? 0;
                        final accuracy =
                            ((row['accuracy'] as num?)?.toDouble() ?? 0) *
                                100;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Text(
                                date,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'monospace',
                                  color: AppColors.grey600,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: LinearProgressIndicator(
                                    value: accuracy / 100,
                                    backgroundColor: AppColors.grey100,
                                    valueColor:
                                        const AlwaysStoppedAnimation(
                                            AppColors.grey800),
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 60,
                                child: Text(
                                  '${accuracy.round()}% ($dayTotal)',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.grey500,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.grey50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.grey500),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicRow extends StatelessWidget {
  final String topic;
  final String section;
  final int total;
  final int correct;
  final double accuracy;

  const _TopicRow({
    required this.topic,
    required this.section,
    required this.total,
    required this.correct,
    required this.accuracy,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  topic,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '$correct/$total',
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: 'monospace',
                  color: AppColors.grey500,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 40,
                child: Text(
                  '${accuracy.round()}%',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: accuracy >= 65
                        ? AppColors.success
                        : accuracy >= 40
                            ? AppColors.grey700
                            : AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: accuracy / 100,
              backgroundColor: AppColors.grey100,
              valueColor: AlwaysStoppedAnimation(
                accuracy >= 65
                    ? AppColors.success
                    : accuracy >= 40
                        ? AppColors.grey700
                        : AppColors.error,
              ),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}
