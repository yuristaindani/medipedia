import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/error/app_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../cubit/medication_cubit.dart';
import '../widgets/app_empty_view.dart';
import '../widgets/app_error_view.dart';
import '../widgets/medication_card.dart';
import 'favorites_page.dart';
import 'filter_page.dart';
import '../cubit/locale_cubit.dart';

class MedicationListPage extends StatefulWidget {
  const MedicationListPage({super.key});

  @override
  State<MedicationListPage> createState() => _MedicationListPageState();
}

class _MedicationListPageState extends State<MedicationListPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(
      _onScroll,
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 300) {
      context.read<MedicationCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              searchController: _searchController,
              onSearchChanged: context.read<MedicationCubit>().search,
            ),
            Expanded(
              child: BlocBuilder<MedicationCubit, MedicationState>(
                builder: (context, state) {
                  if (state.status == MedicationStatus.loading &&
                      state.medications.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state.status == MedicationStatus.failure &&
                      state.medications.isEmpty) {
                    return AppErrorView(
                      message: _errorMessage(
                        context,
                        state.errorType,
                      ),
                      retryLabel: l10n.retry,
                      onRetry: () {
                        context.read<MedicationCubit>().loadInitial();
                      },
                    );
                  }

                  if (state.needsMoreCharacters) {
                    return AppEmptyView(
                      message: l10n.searchTooShort,
                    );
                  }

                  if (state.medications.isEmpty) {
                    return AppEmptyView(
                      message: l10n.emptyMedications,
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: context.read<MedicationCubit>().refresh,
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                      itemCount: state.medications.length +
                          (state.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= state.medications.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final medication = state.medications[index];

                        return MedicationCard(
                          medication: medication,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _errorMessage(
    BuildContext context,
    AppErrorType? type,
  ) {
    final l10n = AppLocalizations.of(context);

    switch (type) {
      case AppErrorType.network:
        return l10n.networkError;
      case AppErrorType.server:
        return l10n.serverError;
      case AppErrorType.rateLimit:
        return l10n.rateLimitError;
      case AppErrorType.invalidData:
        return l10n.invalidDataError;
      case AppErrorType.unknown:
      case null:
        return l10n.unknownError;
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.searchController,
    required this.onSearchChanged,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 18),
      child: Column(
        children: [
          const _BrandHeader(),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black87,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 12),
                      const Icon(Icons.search, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          onChanged: onSearchChanged,
                          textAlign: TextAlign.left,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            hintText: l10n.searchHint,
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: searchController,
                        builder: (context, value, child) {
                          if (value.text.isEmpty) {
                            return const SizedBox(width: 12);
                          }

                          return IconButton(
                            tooltip: l10n.clearSearch,
                            onPressed: () {
                              searchController.clear();
                              onSearchChanged('');
                            },
                            icon: const Icon(Icons.close, size: 18),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints.tightFor(
                              width: 32,
                              height: 32,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: l10n.filter,
                onPressed: () => showDialog<void>(
                  context: context,
                  useSafeArea: false,
                  barrierDismissible: false,
                  builder: (_) => const Dialog.fullscreen(
                    child: FilterPage(),
                  ),
                ),
                icon: const Icon(Icons.tune, color: Colors.black, size: 28),
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                tooltip: AppLocalizations.of(context).favorites,
                onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FavoritesPage())),
                icon: const Icon(Icons.favorite_border, color: Colors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
              color: Color(0xFFEAF8FC), shape: BoxShape.circle),
          child: Image.asset('assets/images/logo.png',
              width: 52, height: 52, fit: BoxFit.contain),
        ),
        const SizedBox(width: 10),
        const Text.rich(
            TextSpan(children: [
              TextSpan(
                  text: 'Medi', style: TextStyle(color: AppColors.brandMedi)),
              TextSpan(
                  text: 'Pedia', style: TextStyle(color: AppColors.brandPedia)),
            ]),
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500)),
        const Spacer(),
        BlocBuilder<LocaleCubit, Locale>(
          builder: (context, locale) {
            final selectedLanguage = locale.languageCode == 'id' ? 'id' : 'en';

            return DropdownButton<String>(
              value: selectedLanguage,
              underline: const SizedBox.shrink(),
              borderRadius: BorderRadius.circular(12),
              items: [
                DropdownMenuItem(
                  value: 'en',
                  child: Text(l10n.english),
                ),
                DropdownMenuItem(
                  value: 'id',
                  child: Text(l10n.indonesian),
                ),
              ],
              onChanged: (languageCode) {
                if (languageCode != null) {
                  context.read<LocaleCubit>().setLanguage(languageCode);
                }
              },
            );
          },
        ),
      ],
    );
  }
}
