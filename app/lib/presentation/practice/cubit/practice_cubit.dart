import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants.dart';
import '../../../data/models/question.dart';
import '../../../domain/repositories/question_repository.dart';
import '../../../domain/repositories/attempt_repository.dart';
import '../../../domain/repositories/daily_target_repository.dart';

/// Practice session states:
///
/// ```
/// Loading → Answering → Submitted → (next Q) → Answering
///                                  → (last Q) → Completed
///          ← (back) ← ConfirmAbandon
/// Loading → Empty (no questions available)
/// Loading → Error
/// ```
class PracticeState {
  final PracticeStatus status;
  final List<Question> questions;
  final int currentIndex;
  final String? selectedOption;
  final bool isCorrect;
  final int correctCount;
  final int totalAnswered;
  final int elapsedSeconds; // informational timer
  final String? error;

  const PracticeState({
    this.status = PracticeStatus.loading,
    this.questions = const [],
    this.currentIndex = 0,
    this.selectedOption,
    this.isCorrect = false,
    this.correctCount = 0,
    this.totalAnswered = 0,
    this.elapsedSeconds = 0,
    this.error,
  });

  Question? get currentQuestion =>
      currentIndex < questions.length ? questions[currentIndex] : null;

  bool get isLastQuestion => currentIndex >= questions.length - 1;

  static const _sentinel = Object();

  PracticeState copyWith({
    PracticeStatus? status,
    List<Question>? questions,
    int? currentIndex,
    Object? selectedOption = _sentinel,
    bool? isCorrect,
    int? correctCount,
    int? totalAnswered,
    int? elapsedSeconds,
    Object? error = _sentinel,
  }) {
    return PracticeState(
      status: status ?? this.status,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedOption: identical(selectedOption, _sentinel)
          ? this.selectedOption
          : selectedOption as String?,
      isCorrect: isCorrect ?? this.isCorrect,
      correctCount: correctCount ?? this.correctCount,
      totalAnswered: totalAnswered ?? this.totalAnswered,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }
}

enum PracticeStatus { loading, answering, submitted, completed, empty, error }

class PracticeCubit extends Cubit<PracticeState> {
  final QuestionRepository _questionRepo;
  final AttemptRepository _attemptRepo;
  final DailyTargetRepository _dailyTargetRepo;
  final PracticeMode mode;
  final String? section;

  PracticeCubit({
    required QuestionRepository questionRepo,
    required AttemptRepository attemptRepo,
    required DailyTargetRepository dailyTargetRepo,
    required this.mode,
    this.section,
  })  : _questionRepo = questionRepo,
        _attemptRepo = attemptRepo,
        _dailyTargetRepo = dailyTargetRepo,
        super(const PracticeState());

  Future<void> loadQuestions() async {
    emit(state.copyWith(status: PracticeStatus.loading));
    try {
      final questions = await _fetchQuestions();
      if (questions.isEmpty) {
        emit(state.copyWith(status: PracticeStatus.empty));
      } else {
        emit(state.copyWith(
          status: PracticeStatus.answering,
          questions: questions,
          currentIndex: 0,
          correctCount: 0,
          totalAnswered: 0,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: PracticeStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<List<Question>> _fetchQuestions() async {
    return switch (mode) {
      PracticeMode.dailyMin => _fetchDailyMinQuestions(),
      PracticeMode.focused => _questionRepo.getUnattemptedQuestions(
          section: section,
          limit: 30,
        ),
      PracticeMode.adaptive => _questionRepo.getAdaptiveQuestions(limit: 30),
      PracticeMode.retryMissed => _questionRepo.getMissedQuestions(),
    };
  }

  Future<List<Question>> _fetchDailyMinQuestions() async {
    // 3 DILR + 5 QA + 3 VARC
    final dilr = await _questionRepo.getUnattemptedQuestions(
      section: Section.dilr.code,
      limit: 3,
    );
    final qa = await _questionRepo.getUnattemptedQuestions(
      section: Section.qa.code,
      limit: 5,
    );
    final varc = await _questionRepo.getUnattemptedQuestions(
      section: Section.varc.code,
      limit: 3,
    );
    return [...dilr, ...qa, ...varc];
  }

  void selectOption(String option) {
    if (state.status != PracticeStatus.answering) return;
    emit(state.copyWith(selectedOption: option));
  }

  Future<void> submitAnswer() async {
    final question = state.currentQuestion;
    final selected = state.selectedOption;
    if (question == null || selected == null) return;
    if (state.status != PracticeStatus.answering) return;

    final correct = selected == question.correctAnswer;

    await _attemptRepo.submitAnswer(
      questionId: question.id,
      userAnswer: selected,
      isCorrect: correct,
      mode: mode.value,
      timeTakenSeconds: state.elapsedSeconds,
    );

    // Increment daily progress
    if (mode == PracticeMode.dailyMin || mode == PracticeMode.focused) {
      await _dailyTargetRepo.incrementProgress(
        question.section,
        mode.value,
      );
    }

    emit(state.copyWith(
      status: PracticeStatus.submitted,
      isCorrect: correct,
      correctCount: correct ? state.correctCount + 1 : state.correctCount,
      totalAnswered: state.totalAnswered + 1,
      elapsedSeconds: 0,
    ));
  }

  void nextQuestion() {
    if (state.isLastQuestion) {
      emit(state.copyWith(status: PracticeStatus.completed));
    } else {
      emit(state.copyWith(
        status: PracticeStatus.answering,
        currentIndex: state.currentIndex + 1,
        selectedOption: null,
        isCorrect: false,
        elapsedSeconds: 0,
      ));
    }
  }

  void tickTimer() {
    if (state.status == PracticeStatus.answering) {
      emit(state.copyWith(elapsedSeconds: state.elapsedSeconds + 1));
    }
  }
}
