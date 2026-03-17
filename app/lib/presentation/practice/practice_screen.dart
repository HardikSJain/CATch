import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../data/models/question.dart';
import 'cubit/practice_cubit.dart';

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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
            const Icon(Icons.chevron_right, size: 20, color: AppColors.grey400),
          ],
        ),
      ),
    );
  }
}

/// Full-screen practice session with question flow and timer.
class PracticeScreen extends StatefulWidget {
  final String mode;
  final String? section;

  const PracticeScreen({super.key, required this.mode, this.section});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen>
    with WidgetsBindingObserver {
  Timer? _timer;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _timer?.cancel();
      setState(() => _paused = true);
    } else if (state == AppLifecycleState.resumed) {
      setState(() => _paused = false);
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      context.read<PracticeCubit>().tickTimer();
    });
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<bool> _onWillPop() async {
    final cubit = context.read<PracticeCubit>();
    final state = cubit.state;

    if (state.status == PracticeStatus.completed ||
        state.status == PracticeStatus.empty ||
        state.status == PracticeStatus.error ||
        state.status == PracticeStatus.loading) {
      return true;
    }

    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('End session?'),
        content: Text(
          'You\'ve answered ${state.totalAnswered} of ${state.questions.length} questions.\n'
          'Score: ${state.correctCount}/${state.totalAnswered}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Continue', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('End', style: TextStyle(color: AppColors.grey500)),
          ),
        ],
      ),
    );

    return shouldLeave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final practiceMode = PracticeMode.fromValue(widget.mode);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          context.pop();
        }
      },
      child: BlocBuilder<PracticeCubit, PracticeState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              leading: const BackButton(),
              title: Text(
                _modeLabel(practiceMode, widget.section),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              centerTitle: true,
              actions: [
                if (state.status == PracticeStatus.answering ||
                    state.status == PracticeStatus.submitted)
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Center(
                      child: Text(
                        _paused ? 'Paused' : _formatTime(state.elapsedSeconds),
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'monospace',
                          color: _paused ? AppColors.error : AppColors.grey500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, PracticeState state) {
    return switch (state.status) {
      PracticeStatus.loading => const Center(
          child: CircularProgressIndicator(
            color: Colors.black,
            strokeWidth: 1.5,
          ),
        ),
      PracticeStatus.empty => const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'No questions available.\nTry a different mode or check back later.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.grey500,
                height: 1.5,
              ),
            ),
          ),
        ),
      PracticeStatus.error => Center(
          child: Text(
            state.error ?? 'Something went wrong',
            style: const TextStyle(color: AppColors.grey500),
          ),
        ),
      PracticeStatus.answering || PracticeStatus.submitted =>
        _QuestionView(state: state),
      PracticeStatus.completed => _CompletionView(state: state),
    };
  }

  String _modeLabel(PracticeMode mode, String? section) {
    return switch (mode) {
      PracticeMode.dailyMin => 'Daily Minimum',
      PracticeMode.focused => 'Focused: ${section ?? ""}',
      PracticeMode.adaptive => 'Smart Practice',
      PracticeMode.retryMissed => 'Retry Missed',
    };
  }
}

class _QuestionView extends StatelessWidget {
  final PracticeState state;

  const _QuestionView({required this.state});

  @override
  Widget build(BuildContext context) {
    final question = state.currentQuestion!;
    final isSubmitted = state.status == PracticeStatus.submitted;

    return Column(
      children: [
        // Progress bar
        LinearProgressIndicator(
          value: (state.currentIndex + 1) / state.questions.length,
          backgroundColor: AppColors.grey100,
          valueColor: const AlwaysStoppedAnimation(AppColors.grey800),
          minHeight: 2,
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Question counter + section tag
              Row(
                children: [
                  Text(
                    'Q${state.currentIndex + 1} of ${state.questions.length}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.grey500,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 8),
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
                      question.topic,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.grey600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Question text
              Text(
                question.questionText,
                style: const TextStyle(fontSize: 16, height: 1.6),
              ),

              // Question image
              if (question.imagePath != null) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    question.imagePath!,
                    errorBuilder: (_, e, s) => const SizedBox.shrink(),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Options
              ..._buildOptions(context, question, isSubmitted),

              // Explanation (after submit)
              if (isSubmitted && question.explanation != null) ...[
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
          ),
        ),

        // Bottom action button
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: isSubmitted
                ? _buildActionButton(
                    state.isLastQuestion ? 'Done' : 'Next',
                    onTap: () {
                      context.read<PracticeCubit>().nextQuestion();
                    },
                  )
                : _buildActionButton(
                    'Check',
                    enabled: state.selectedOption != null,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.read<PracticeCubit>().submitAnswer();
                    },
                  ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildOptions(
    BuildContext context,
    Question question,
    bool isSubmitted,
  ) {
    final options = <MapEntry<String, String?>>[];
    if (question.optionA != null) options.add(MapEntry('A', question.optionA));
    if (question.optionB != null) options.add(MapEntry('B', question.optionB));
    if (question.optionC != null) options.add(MapEntry('C', question.optionC));
    if (question.optionD != null) options.add(MapEntry('D', question.optionD));
    if (question.optionE != null) options.add(MapEntry('E', question.optionE));

    return options.map((entry) {
      final letter = entry.key;
      final text = entry.value ?? '';
      final isSelected = state.selectedOption == letter;
      final isCorrect = question.correctAnswer == letter;

      Color bgColor = Colors.white;
      Color borderColor = AppColors.grey200;
      Color textColor = AppColors.grey900;

      if (isSubmitted) {
        if (isCorrect) {
          bgColor = AppColors.success.withAlpha(20);
          borderColor = AppColors.success;
        } else if (isSelected && !isCorrect) {
          bgColor = AppColors.error.withAlpha(20);
          borderColor = AppColors.error;
        }
      } else if (isSelected) {
        bgColor = AppColors.grey100;
        borderColor = AppColors.grey900;
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GestureDetector(
          onTap: isSubmitted
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  context.read<PracticeCubit>().selectOption(letter);
                },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(fontSize: 15, color: textColor),
                  ),
                ),
                if (isSubmitted && isCorrect)
                  const Icon(Icons.check, size: 18, color: AppColors.success),
                if (isSubmitted && isSelected && !isCorrect)
                  const Icon(Icons.close, size: 18, color: AppColors.error),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildActionButton(
    String label, {
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: enabled ? AppColors.grey900 : AppColors.grey200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: enabled ? Colors.white : AppColors.grey400,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CompletionView extends StatelessWidget {
  final PracticeState state;

  const _CompletionView({required this.state});

  @override
  Widget build(BuildContext context) {
    final accuracy = state.totalAnswered > 0
        ? (state.correctCount / state.totalAnswered * 100).round()
        : 0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, size: 64, color: AppColors.grey800),
            const SizedBox(height: 24),
            const Text(
              'Session Complete',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CompletionStat(
                  label: 'Score',
                  value: '${state.correctCount}/${state.totalAnswered}',
                ),
                const SizedBox(width: 40),
                _CompletionStat(label: 'Accuracy', value: '$accuracy%'),
              ],
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () => context.pop(),
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
}

class _CompletionStat extends StatelessWidget {
  final String label;
  final String value;

  const _CompletionStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.grey500),
        ),
      ],
    );
  }
}
