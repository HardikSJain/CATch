import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants.dart';
import 'cubit/flashcard_cubit.dart';

class FlashcardScreen extends StatelessWidget {
  const FlashcardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FlashcardCubit, FlashcardState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: const BackButton(),
            title: Text(
              state.completed
                  ? 'Review Complete'
                  : '${state.reviewed + 1} of ${state.total}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            centerTitle: true,
          ),
          body: state.loading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 1.5,
                  ),
                )
              : state.completed
                  ? _buildCompleted(context, state)
                  : _buildFlashcard(context, state),
        );
      },
    );
  }

  Widget _buildCompleted(BuildContext context, FlashcardState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline,
                size: 64, color: AppColors.grey800),
            const SizedBox(height: 24),
            Text(
              state.total == 0
                  ? 'No concepts due for review'
                  : 'All ${state.total} concepts reviewed!',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Come back tomorrow for more.',
              style: TextStyle(fontSize: 14, color: AppColors.grey500),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.grey900,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Done',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlashcard(BuildContext context, FlashcardState state) {
    final concept = state.currentConcept!;
    final title = concept['title'] as String;
    final topic = concept['topic'] as String;
    final content = concept['content'] as String;

    return Column(
      children: [
        // Progress bar
        LinearProgressIndicator(
          value: state.total > 0 ? (state.reviewed + 1) / state.total : 0,
          backgroundColor: AppColors.grey100,
          valueColor: const AlwaysStoppedAnimation(AppColors.grey800),
          minHeight: 2,
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Topic tag
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    topic.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: AppColors.grey500,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Title (always visible)
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 20),

                if (!state.revealed) ...[
                  const Spacer(),
                  const Center(
                    child: Text(
                      'Try to recall the concept,\nthen tap to reveal.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.grey400,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.read<FlashcardCubit>().reveal(),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.grey900,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Show Answer',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  // Revealed content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        content,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.7,
                          color: AppColors.grey700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Rating buttons
                  const Text(
                    'How well did you recall this?',
                    style: TextStyle(fontSize: 13, color: AppColors.grey500),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _RatingButton(
                          label: 'Hard',
                          color: AppColors.error,
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            context.read<FlashcardCubit>().rate(1);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _RatingButton(
                          label: 'Good',
                          color: AppColors.grey800,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            context.read<FlashcardCubit>().rate(3);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _RatingButton(
                          label: 'Easy',
                          color: AppColors.success,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            context.read<FlashcardCubit>().rate(5);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RatingButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _RatingButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(80)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
