import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants.dart';
import '../../data/models/answered_question.dart';
import 'cubit/review_cubit.dart';

/// Read-only review of previously answered questions.
class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text(
          'Quick Review',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<ReviewCubit, ReviewState>(
            builder: (context, state) {
              return IconButton(
                onPressed: () => context.read<ReviewCubit>().toggleFilter(),
                icon: Icon(
                  state.wrongOnly
                      ? Icons.filter_alt
                      : Icons.filter_alt_outlined,
                  size: 22,
                  color: state.wrongOnly ? AppColors.error : AppColors.grey600,
                ),
                tooltip: state.wrongOnly ? 'Show all' : 'Wrong only',
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ReviewCubit, ReviewState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
                strokeWidth: 1.5,
              ),
            );
          }

          if (state.questions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  state.wrongOnly
                      ? 'No wrong answers to review.\nGreat job!'
                      : 'No answered questions yet.\nStart practicing to build your review history.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.grey500,
                    height: 1.5,
                  ),
                ),
              ),
            );
          }

          return Column(
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: (state.currentIndex + 1) / state.questions.length,
                backgroundColor: AppColors.grey100,
                valueColor: const AlwaysStoppedAnimation(AppColors.grey800),
                minHeight: 2,
              ),

              // Question content
              Expanded(
                child: _ReviewCard(answered: state.current!),
              ),

              // Navigation
              SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      // Counter
                      Text(
                        '${state.currentIndex + 1} / ${state.questions.length}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.grey500,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const Spacer(),
                      // Previous
                      IconButton(
                        onPressed: state.isFirst
                            ? null
                            : () => context.read<ReviewCubit>().previous(),
                        icon: const Icon(Icons.arrow_back_ios, size: 18),
                        color: AppColors.grey800,
                        disabledColor: AppColors.grey300,
                      ),
                      const SizedBox(width: 8),
                      // Next
                      IconButton(
                        onPressed: state.isLast
                            ? null
                            : () => context.read<ReviewCubit>().next(),
                        icon: const Icon(Icons.arrow_forward_ios, size: 18),
                        color: AppColors.grey800,
                        disabledColor: AppColors.grey300,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final AnsweredQuestion answered;

  const _ReviewCard({required this.answered});

  @override
  Widget build(BuildContext context) {
    final question = answered.question;
    final options = <MapEntry<String, String?>>[];
    if (question.optionA != null) options.add(MapEntry('A', question.optionA));
    if (question.optionB != null) options.add(MapEntry('B', question.optionB));
    if (question.optionC != null) options.add(MapEntry('C', question.optionC));
    if (question.optionD != null) options.add(MapEntry('D', question.optionD));
    if (question.optionE != null) options.add(MapEntry('E', question.optionE));

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Status + section tag
        Row(
          children: [
            Icon(
              answered.isCorrect ? Icons.check_circle : Icons.cancel,
              size: 18,
              color: answered.isCorrect ? AppColors.success : AppColors.error,
            ),
            const SizedBox(width: 6),
            Text(
              answered.isCorrect ? 'Correct' : 'Wrong',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color:
                    answered.isCorrect ? AppColors.success : AppColors.error,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                question.topic,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.grey600,
                ),
              ),
            ),
            if (answered.timeTakenSeconds != null) ...[
              const Spacer(),
              Text(
                '${answered.timeTakenSeconds}s',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.grey400,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 20),

        // Question text
        Text(
          question.questionText,
          style: const TextStyle(fontSize: 16, height: 1.6),
        ),

        const SizedBox(height: 24),

        // Options (read-only, showing correct/wrong)
        ...options.map((entry) {
          final letter = entry.key;
          final text = entry.value ?? '';
          final isCorrect = question.correctAnswer == letter;
          final isUserAnswer = answered.userAnswer == letter;

          Color bgColor = Colors.white;
          Color borderColor = AppColors.grey200;

          if (isCorrect) {
            bgColor = AppColors.success.withAlpha(20);
            borderColor = AppColors.success;
          } else if (isUserAnswer && !isCorrect) {
            bgColor = AppColors.error.withAlpha(20);
            borderColor = AppColors.error;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$letter.',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(text, style: const TextStyle(fontSize: 15)),
                  ),
                  if (isCorrect)
                    const Icon(Icons.check, size: 18, color: AppColors.success),
                  if (isUserAnswer && !isCorrect)
                    const Icon(Icons.close, size: 18, color: AppColors.error),
                ],
              ),
            ),
          );
        }),

        // Explanation
        if (question.explanation != null) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'EXPLANATION',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: AppColors.grey400,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  question.explanation!,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.grey700,
                  ),
                ),
                if (question.explanationImagePath != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      question.explanationImagePath!,
                      errorBuilder: (_, e, s) =>
                          const SizedBox.shrink(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),
      ],
    );
  }
}
