import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_constants.dart';
import '../../core/error/app_exception.dart';
import '../../domain/entities/medication.dart';
import '../../domain/repositories/medication_repository.dart';

enum MedicationStatus {
  initial,
  loading,
  success,
  failure,
}

class MedicationState extends Equatable {
  const MedicationState({
    this.status = MedicationStatus.initial,
    this.medications = const [],
    this.query = '',
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
    this.errorType,
    this.needsMoreCharacters = false,
  });

  final MedicationStatus status;
  final List<Medication> medications;
  final String query;
  final bool isLoadingMore;
  final bool hasReachedEnd;
  final AppErrorType? errorType;
  final bool needsMoreCharacters;

  MedicationState copyWith({
    MedicationStatus? status,
    List<Medication>? medications,
    String? query,
    bool? isLoadingMore,
    bool? hasReachedEnd,
    AppErrorType? errorType,
    bool clearError = false,
    bool? needsMoreCharacters,
  }) {
    return MedicationState(
      status: status ?? this.status,
      medications: medications ?? this.medications,
      query: query ?? this.query,
      isLoadingMore:
          isLoadingMore ?? this.isLoadingMore,
      hasReachedEnd:
          hasReachedEnd ?? this.hasReachedEnd,
      errorType:
          clearError ? null : errorType ?? this.errorType,
      needsMoreCharacters:
          needsMoreCharacters ?? this.needsMoreCharacters,
    );
  }

  @override
  List<Object?> get props => [
        status,
        medications,
        query,
        isLoadingMore,
        hasReachedEnd,
        errorType,
        needsMoreCharacters,
      ];
}

class MedicationCubit extends Cubit<MedicationState> {
  MedicationCubit(this._repository)
      : super(const MedicationState());

  final MedicationRepository _repository;

  Timer? _searchTimer;
  int _requestGeneration = 0;

  Future<void> loadInitial() async {
    await _loadFirstPage(
      query: state.query,
      showLoading: true,
    );
  }

  Future<void> refresh() async {
    _requestGeneration++;

    await _loadFirstPage(
      query: state.query,
      showLoading: false,
    );
  }

  void search(String value) {
    final query = value.trim();

    _searchTimer?.cancel();

    if (query == state.query) {
      return;
    }

    if (query.isEmpty) {
      emit(
        state.copyWith(
          query: '',
          needsMoreCharacters: false,
        ),
      );

      _searchTimer = Timer(
        const Duration(milliseconds: 150),
        () {
          _loadFirstPage(
            query: '',
            showLoading: true,
          );
        },
      );

      return;
    }

    if (query.length < 2) {
      _requestGeneration++;

      emit(
        MedicationState(
          status: MedicationStatus.success,
          query: query,
          needsMoreCharacters: true,
        ),
      );

      return;
    }

    _requestGeneration++;
    final generation = _requestGeneration;

    _searchTimer = Timer(
      const Duration(
        milliseconds:
            AppConstants.searchDebounceMilliseconds,
      ),
      () {
        if (generation != _requestGeneration) {
          return;
        }

        _loadFirstPage(
          query: query,
          showLoading: true,
          generation: generation,
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore ||
        state.hasReachedEnd ||
        state.status != MedicationStatus.success) {
      return;
    }

    emit(
      state.copyWith(
        isLoadingMore: true,
      ),
    );

    final currentGeneration = _requestGeneration;

    try {
      final nextItems =
          await _repository.getMedications(
        query: state.query,
        skip: state.medications.length,
        limit: AppConstants.pageSize,
      );

      if (currentGeneration != _requestGeneration) {
        return;
      }

      final existingIds =
          state.medications.map((item) => item.id).toSet();

      final uniqueItems = nextItems
          .where(
            (item) => !existingIds.contains(item.id),
          )
          .toList();

      emit(
        state.copyWith(
          medications: [
            ...state.medications,
            ...uniqueItems,
          ],
          isLoadingMore: false,
          hasReachedEnd:
              nextItems.length < AppConstants.pageSize,
          clearError: true,
        ),
      );
    } on AppException catch (error) {
      emit(
        state.copyWith(
          isLoadingMore: false,
          errorType: error.type,
        ),
      );
    }
  }

  Future<void> _loadFirstPage({
    required String query,
    required bool showLoading,
    int? generation,
  }) async {
    if (generation != null &&
        generation != _requestGeneration) {
      return;
    }

    final requestGeneration =
        generation ?? ++_requestGeneration;

    if (showLoading) {
      emit(
        MedicationState(
          status: MedicationStatus.loading,
          query: query,
        ),
      );
    }

    try {
      final items =
          await _repository.getMedications(
        query: query,
        skip: 0,
        limit: AppConstants.pageSize,
      );

      if (requestGeneration != _requestGeneration) {
        return;
      }

      emit(
        MedicationState(
          status: MedicationStatus.success,
          medications: items,
          query: query,
          hasReachedEnd:
              items.length < AppConstants.pageSize,
        ),
      );
    } on AppException catch (error) {
      if (requestGeneration != _requestGeneration) {
        return;
      }

      emit(
        MedicationState(
          status: MedicationStatus.failure,
          query: query,
          errorType: error.type,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _searchTimer?.cancel();
    return super.close();
  }
}