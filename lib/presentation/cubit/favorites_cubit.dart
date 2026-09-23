import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/medication.dart';
import '../../domain/repositories/favorites_repository.dart';

class FavoritesState extends Equatable {
  const FavoritesState({
    this.medications = const [],
    this.isLoading = false,
  });

  final List<Medication> medications;
  final bool isLoading;

  @override
  List<Object?> get props => [
        medications,
        isLoading,
      ];
}

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit(this._repository)
      : super(const FavoritesState());

  final FavoritesRepository _repository;

  Future<void> load() async {
    emit(
      FavoritesState(
        medications: state.medications,
        isLoading: true,
      ),
    );

    final favorites =
        await _repository.getFavorites();

    emit(
      FavoritesState(
        medications: favorites,
      ),
    );
  }

  bool isFavorite(String id) {
    return state.medications
        .any((item) => item.id == id);
  }

  Future<void> toggle(Medication medication) async {
    if (isFavorite(medication.id)) {
      await _repository.removeFavorite(
        medication.id,
      );
    } else {
      await _repository.saveFavorite(
        medication,
      );
    }

    await load();
  }
}