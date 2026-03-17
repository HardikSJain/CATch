import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/local/home_facade.dart';

class HomeState {
  final HomeData? data;
  final bool loading;
  final String? error;

  const HomeState({this.data, this.loading = true, this.error});

  HomeState copyWith({HomeData? data, bool? loading, String? error}) {
    return HomeState(
      data: data ?? this.data,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class HomeCubit extends Cubit<HomeState> {
  final HomeFacade _facade;

  HomeCubit(this._facade) : super(const HomeState());

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final data = await _facade.loadHomeData();
      emit(HomeState(data: data, loading: false));
    } catch (e) {
      emit(HomeState(loading: false, error: e.toString()));
    }
  }

  Future<void> refresh() => load();
}
