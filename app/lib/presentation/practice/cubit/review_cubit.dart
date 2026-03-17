import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/answered_question.dart';
import '../../../domain/repositories/question_repository.dart';

class ReviewState {
  final List<AnsweredQuestion> questions;
  final int currentIndex;
  final bool loading;
  final bool wrongOnly;

  const ReviewState({
    this.questions = const [],
    this.currentIndex = 0,
    this.loading = true,
    this.wrongOnly = false,
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
  }) {
    return ReviewState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      loading: loading ?? this.loading,
      wrongOnly: wrongOnly ?? this.wrongOnly,
    );
  }
}

class ReviewCubit extends Cubit<ReviewState> {
  final QuestionRepository _repo;

  ReviewCubit(this._repo) : super(const ReviewState());

  Future<void> load({bool wrongOnly = false}) async {
    emit(state.copyWith(loading: true, wrongOnly: wrongOnly));
    final questions = await _repo.getAnsweredQuestions(wrongOnly: wrongOnly);
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
