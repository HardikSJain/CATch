import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/concept_repository.dart';

class FlashcardState {
  final List<Map<String, dynamic>> concepts;
  final int currentIndex;
  final bool revealed;
  final bool loading;
  final bool completed;

  const FlashcardState({
    this.concepts = const [],
    this.currentIndex = 0,
    this.revealed = false,
    this.loading = true,
    this.completed = false,
  });

  Map<String, dynamic>? get currentConcept =>
      currentIndex < concepts.length ? concepts[currentIndex] : null;

  bool get isLastConcept => currentIndex >= concepts.length - 1;

  int get reviewed => currentIndex;
  int get total => concepts.length;

  FlashcardState copyWith({
    List<Map<String, dynamic>>? concepts,
    int? currentIndex,
    bool? revealed,
    bool? loading,
    bool? completed,
  }) {
    return FlashcardState(
      concepts: concepts ?? this.concepts,
      currentIndex: currentIndex ?? this.currentIndex,
      revealed: revealed ?? this.revealed,
      loading: loading ?? this.loading,
      completed: completed ?? this.completed,
    );
  }
}

class FlashcardCubit extends Cubit<FlashcardState> {
  final ConceptRepository _repo;

  FlashcardCubit(this._repo) : super(const FlashcardState());

  Future<void> load() async {
    emit(state.copyWith(loading: true));
    final concepts = await _repo.getDueForReview();
    emit(FlashcardState(
      concepts: concepts,
      loading: false,
      completed: concepts.isEmpty,
    ));
  }

  void reveal() {
    emit(state.copyWith(revealed: true));
  }

  /// Rate the concept recall and move to next.
  /// quality: 5 = Easy, 3 = Good, 1 = Hard
  Future<void> rate(int quality) async {
    final concept = state.currentConcept;
    if (concept == null) return;

    await _repo.rateReview(
      conceptId: concept['id'] as int,
      quality: quality,
    );

    if (state.isLastConcept) {
      emit(state.copyWith(completed: true));
    } else {
      emit(state.copyWith(
        currentIndex: state.currentIndex + 1,
        revealed: false,
      ));
    }
  }
}
