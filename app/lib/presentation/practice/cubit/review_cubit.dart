import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/answered_question.dart';
import '../../../domain/repositories/question_repository.dart';

class ReviewState {
  final List<AnsweredQuestion> questions;
  final int currentIndex;
  final bool loading;
  final bool wrongOnly;
  final int requestId;

  const ReviewState({
    this.questions = const [],
    this.currentIndex = 0,
    this.loading = true,
    this.wrongOnly = false,
    this.requestId = 0,
  });

  AnsweredQuestion? get current =>
      currentIndex < questions.length ? questions[currentIndex] : null;

  bool get isFirst => currentIndex == 0;
  bool get isLast => currentIndex >= questions.length - 1;

  ReviewState copyWith({
    List<AnsweredQuestion>? questions,
    int? currentIndex,
    bool? loading,
    bool? wrongOnly,
    int? requestId,
  }) {
    return ReviewState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      loading: loading ?? this.loading,
      wrongOnly: wrongOnly ?? this.wrongOnly,
      requestId: requestId ?? this.requestId,
    );
  }
}

class ReviewCubit extends Cubit<ReviewState> {
  final QuestionRepository _repo;

  ReviewCubit(this._repo) : super(const ReviewState());

  Future<void> load({bool wrongOnly = false}) async {
    final newRequestId = state.requestId + 1;
    emit(state.copyWith(
      loading: true,
      wrongOnly: wrongOnly,
      requestId: newRequestId,
    ));
    final questions = await _repo.getAnsweredQuestions(wrongOnly: wrongOnly);
    if (state.requestId != newRequestId) {
      // A newer load has been started; ignore this stale result.
      return;
    }
    emit(state.copyWith(
      questions: questions,
      currentIndex: 0,
      loading: false,
    ));
  }

  void next() {
    if (!state.isLast) {
      emit(state.copyWith(currentIndex: state.currentIndex + 1));
    }
  }

  void previous() {
    if (!state.isFirst) {
      emit(state.copyWith(currentIndex: state.currentIndex - 1));
    }
  }

  void toggleFilter() {
    load(wrongOnly: !state.wrongOnly);
  }
}
