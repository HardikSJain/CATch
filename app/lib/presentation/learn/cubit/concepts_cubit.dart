import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/concept_repository.dart';

class ConceptsState {
  final List<Map<String, dynamic>> concepts;
  final String selectedSection;
  final int reviewDue;
  final bool loading;

  const ConceptsState({
    this.concepts = const [],
    this.selectedSection = 'QA',
    this.reviewDue = 0,
    this.loading = true,
  });

  ConceptsState copyWith({
    List<Map<String, dynamic>>? concepts,
    String? selectedSection,
    int? reviewDue,
    bool? loading,
  }) {
    return ConceptsState(
      concepts: concepts ?? this.concepts,
      selectedSection: selectedSection ?? this.selectedSection,
      reviewDue: reviewDue ?? this.reviewDue,
      loading: loading ?? this.loading,
    );
  }
}

class ConceptsCubit extends Cubit<ConceptsState> {
  final ConceptRepository _repo;

  ConceptsCubit(this._repo) : super(const ConceptsState());

  Future<void> load() async {
    emit(state.copyWith(loading: true));
    final concepts = await _repo.getConcepts(section: state.selectedSection);
    final reviewCount = await _repo.getDueForReviewCount();
    emit(state.copyWith(
      concepts: concepts,
      reviewDue: reviewCount,
      loading: false,
    ));
  }

  Future<void> selectSection(String section) async {
    emit(state.copyWith(selectedSection: section, loading: true));
    final concepts = await _repo.getConcepts(section: section);
    emit(state.copyWith(concepts: concepts, loading: false));
  }
}
