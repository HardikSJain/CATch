import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/stats_repository.dart';

class StatsState {
  final Map<String, dynamic> overall;
  final List<Map<String, dynamic>> byTopic;
  final List<Map<String, dynamic>> dailyAccuracy;
  final bool loading;

  const StatsState({
    this.overall = const {},
    this.byTopic = const [],
    this.dailyAccuracy = const [],
    this.loading = true,
  });

  StatsState copyWith({
    Map<String, dynamic>? overall,
    List<Map<String, dynamic>>? byTopic,
    List<Map<String, dynamic>>? dailyAccuracy,
    bool? loading,
  }) {
    return StatsState(
      overall: overall ?? this.overall,
      byTopic: byTopic ?? this.byTopic,
      dailyAccuracy: dailyAccuracy ?? this.dailyAccuracy,
      loading: loading ?? this.loading,
    );
  }
}

class StatsCubit extends Cubit<StatsState> {
  final StatsRepository _repo;

  StatsCubit(this._repo) : super(const StatsState());

  Future<void> load() async {
    emit(state.copyWith(loading: true));
    final overall = await _repo.getOverallStats();
    final byTopic = await _repo.getStatsByTopic();
    final dailyAccuracy = await _repo.getDailyAccuracy();
    emit(StatsState(
      overall: overall,
      byTopic: byTopic,
      dailyAccuracy: dailyAccuracy,
      loading: false,
    ));
  }
}
