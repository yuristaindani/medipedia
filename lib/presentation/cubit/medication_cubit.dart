import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_constants.dart';
import '../../core/error/app_exception.dart';
import '../../domain/entities/medication.dart';
import '../../domain/entities/medication_filters.dart';
import '../../domain/entities/medication_search_tier.dart';
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
    this.filters = MedicationFilters.empty,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
    this.errorType,
    this.needsMoreCharacters = false,
    this.searchTierIndex = 0,
    this.searchTierOffset = 0,
  });

  final MedicationStatus status;
  final List<Medication> medications;
  final String query;
  final MedicationFilters filters;
  final bool isLoadingMore;
  final bool hasReachedEnd;
  final AppErrorType? errorType;
  final bool needsMoreCharacters;
  final int searchTierIndex;
  final int searchTierOffset;

  MedicationState copyWith({
    MedicationStatus? status,
    List<Medication>? medications,
    String? query,
    MedicationFilters? filters,
    bool? isLoadingMore,
    bool? hasReachedEnd,
    AppErrorType? errorType,
    bool clearError = false,
    bool? needsMoreCharacters,
    int? searchTierIndex,
    int? searchTierOffset,
  }) {
    return MedicationState(
      status: status ?? this.status,
      medications: medications ?? this.medications,
      query: query ?? this.query,
      filters: filters ?? this.filters,
      isLoadingMore:
          isLoadingMore ?? this.isLoadingMore,
      hasReachedEnd:
          hasReachedEnd ?? this.hasReachedEnd,
      errorType:
          clearError ? null : errorType ?? this.errorType,
      needsMoreCharacters:
          needsMoreCharacters ?? this.needsMoreCharacters,
      searchTierIndex: searchTierIndex ?? this.searchTierIndex,
      searchTierOffset: searchTierOffset ?? this.searchTierOffset,
    );
  }

  @override
  List<Object?> get props => [
        status,
        medications,
        query,
        filters,
        isLoadingMore,
        hasReachedEnd,
        errorType,
        needsMoreCharacters,
        searchTierIndex,
        searchTierOffset,
      ];
}

class MedicationCubit extends Cubit<MedicationState> {
  MedicationCubit(this._repository)
      : super(const MedicationState());

  final MedicationRepository _repository;

  Timer? _searchTimer;
  Timer? _filterTimer;
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

  void setFilters(MedicationFilters filters) {
    if (filters == state.filters) {
      return;
    }

    _searchTimer?.cancel();
    _filterTimer?.cancel();
    final generation = ++_requestGeneration;
    emit(state.copyWith(filters: filters));

    if (state.query.length == 1) {
      return;
    }

    _filterTimer = Timer(
      const Duration(milliseconds: 300),
      () {
        if (generation != _requestGeneration) {
          return;
        }

        _loadFirstPage(
          query: state.query,
          showLoading: true,
          generation: generation,
        );
      },
    );
  }

  List<Medication> _putUnnamedAtEnd(List<Medication> items) {
    final named = <Medication>[];
    final unnamed = <Medication>[];

    for (final item in items) {
      final hasAnyName = [
        item.brandName,
        item.genericName,
        item.manufacturerName,
      ].any((value) => value != null && value.trim().isNotEmpty);

      if (hasAnyName) {
        named.add(item);
      } else {
        unnamed.add(item);
      }
    }

    return [...named, ...unnamed];
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
          filters: state.filters,
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
      if (state.query.trim().isNotEmpty) {
        final page = await _fetchSearchPage(
          query: state.query,
          filters: state.filters,
          tierIndex: state.searchTierIndex,
          tierOffset: state.searchTierOffset,
          existingIds: state.medications.map((item) => item.id).toSet(),
        );

        if (currentGeneration != _requestGeneration) {
          return;
        }

        emit(
          state.copyWith(
            medications: [
              ...state.medications,
              ..._putUnnamedAtEnd(page.items),
            ],
            isLoadingMore: false,
            hasReachedEnd: page.hasReachedEnd,
            searchTierIndex: page.tierIndex,
            searchTierOffset: page.tierOffset,
            clearError: true,
          ),
        );
        return;
      }

      final nextItems =
          await _repository.getMedications(
        query: state.query,
        skip: state.medications.length,
        limit: AppConstants.pageSize,
        filters: state.filters,
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
          // Sort only this API page. Keeping the already displayed items in
          // place prevents cards from moving when another page is loaded.
          medications: [
            ...state.medications,
            ..._putUnnamedAtEnd(uniqueItems),
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
    MedicationFilters? filters,
  }) async {
    if (generation != null &&
        generation != _requestGeneration) {
      return;
    }

    final requestGeneration =
        generation ?? ++_requestGeneration;
    final appliedFilters = filters ?? state.filters;

    if (showLoading) {
      emit(
        MedicationState(
          status: MedicationStatus.loading,
          query: query,
          filters: appliedFilters,
        ),
      );
    }

    try {
      final searchPage = query.trim().isEmpty
          ? null
          : await _fetchSearchPage(
              query: query,
              filters: appliedFilters,
              tierIndex: 0,
              tierOffset: 0,
              existingIds: const {},
            );
      final items = searchPage?.items ??
          await _repository.getMedications(
            query: query,
            skip: 0,
            limit: AppConstants.pageSize,
            filters: appliedFilters,
          );

      if (requestGeneration != _requestGeneration) {
        return;
      }

      emit(
        MedicationState(
          status: MedicationStatus.success,
          medications: _putUnnamedAtEnd(items),
          query: query,
          filters: appliedFilters,
          hasReachedEnd: searchPage?.hasReachedEnd ??
              items.length < AppConstants.pageSize,
          searchTierIndex: searchPage?.tierIndex ?? 0,
          searchTierOffset: searchPage?.tierOffset ?? 0,
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
          filters: appliedFilters,
          errorType: error.type,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _searchTimer?.cancel();
    _filterTimer?.cancel();
    return super.close();
  }

  Future<_SearchPage> _fetchSearchPage({
    required String query,
    required MedicationFilters filters,
    required int tierIndex,
    required int tierOffset,
    required Set<String> existingIds,
  }) async {
    var currentTierIndex = tierIndex;
    var currentTierOffset = tierOffset;
    final pageItems = <Medication>[];
    final seenIds = Set<String>.from(existingIds);

    while (pageItems.length < AppConstants.pageSize &&
        currentTierIndex < MedicationSearchTier.ordered.length) {
      final tier = MedicationSearchTier.ordered[currentTierIndex];
      final requestedCount = AppConstants.pageSize - pageItems.length;
      final batch = await _repository.getMedications(
        query: query,
        skip: currentTierOffset,
        limit: requestedCount,
        filters: filters,
        searchTier: tier,
      );

      currentTierOffset += batch.length;
      for (final medication in batch) {
        if (seenIds.add(medication.id)) {
          pageItems.add(medication);
        }
      }

      if (batch.length < requestedCount) {
        currentTierIndex++;
        currentTierOffset = 0;
      }
    }

    return _SearchPage(
      items: pageItems,
      tierIndex: currentTierIndex,
      tierOffset: currentTierOffset,
      hasReachedEnd:
          currentTierIndex >= MedicationSearchTier.ordered.length,
    );
  }
}

class _SearchPage {
  const _SearchPage({
    required this.items,
    required this.tierIndex,
    required this.tierOffset,
    required this.hasReachedEnd,
  });

  final List<Medication> items;
  final int tierIndex;
  final int tierOffset;
  final bool hasReachedEnd;
}
