import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/medication_filters.dart';
import '../../l10n/app_localizations.dart';
import '../cubit/medication_cubit.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  String _sectionKey = 'drugType';
  late MedicationFilters _filters;
  final _scrollController = ScrollController();
  final _sectionKeys = <String, GlobalKey>{
    'drugType': GlobalKey(),
    'dosageForm': GlobalKey(),
    'route': GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    _filters = context.read<MedicationCubit>().state.filters;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = <String, String>{
      'drugType': l10n.drugType,
      'dosageForm': l10n.dosageForm,
      'route': l10n.routeOfUse,
    };
    final sidebarWidth = (MediaQuery.of(context).size.width * 0.4)
        .clamp(130.0, 154.0)
        .toDouble();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const _FilterBrandHeader(),
            Container(
              height: 40,
              color: const Color(0xFFF3F3F3),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    l10n.filterTitle,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: _clearFilters,
                      child: Text(l10n.clearFilters),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      tooltip: l10n.close,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.black),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: sidebarWidth,
                    child: Column(
                      children: categories.entries
                          .map(
                            (entry) => _sectionButton(
                              entry.key,
                              entry.value,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: Color(0xFFD5D5D5),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(8, 10, 8, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: categories.entries
                            .map((entry) => _filterSection(
                                  context,
                                  entry.key,
                                  entry.value,
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionButton(String key, String title) {
    final isSelected = _sectionKey == key;

    return InkWell(
      onTap: () {
        setState(() => _sectionKey = key);
        final targetContext = _sectionKeys[key]?.currentContext;
        if (targetContext != null) {
          Scrollable.ensureVisible(
            targetContext,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            alignment: 0.03,
          );
        }
      },
      child: Container(
        height: 72,
        width: double.infinity,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF5F5F5) : Colors.white,
          border: const Border(
            bottom: BorderSide(color: Color(0xFFD5D5D5)),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _filterSection(BuildContext context, String section, String title) {
    final choices = _choicesFor(context, section);
    final selected = _selectedValues(section);

    return Padding(
      key: _sectionKeys[section],
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: choices.entries.map((entry) {
              return FilterChip(
                label: Text(entry.value),
                selected: selected.contains(entry.key),
                onSelected: (isSelected) =>
                    _toggleFilter(section, entry.key, isSelected),
                showCheckmark: false,
                backgroundColor: const Color(0xFFE0E0E0),
                selectedColor: AppColors.softBlue,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                labelStyle: const TextStyle(
                  color: AppColors.darkText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Map<String, String> _choicesFor(BuildContext context, String section) {
    final l10n = AppLocalizations.of(context)!;

    switch (section) {
      case 'drugType':
        return {
          'HUMAN OTC DRUG': l10n.overTheCounter,
          'HUMAN PRESCRIPTION DRUG': l10n.prescription,
        };
      case 'dosageForm':
        return {
          'tablet': l10n.tablet,
          'capsule': l10n.capsule,
          'cream': l10n.cream,
        };
      default:
        return {
          'ORAL': l10n.routeOral,
          'TOPICAL': l10n.routeTopical,
          'CUTANEOUS': l10n.routeCutaneous,
          'TRANSDERMAL': l10n.routeTransdermal,
          'RESPIRATORY (INHALATION)': l10n.routeInhalation,
          'OPHTHALMIC': l10n.routeOphthalmic,
          'NASAL': l10n.routeNasal,
          'INTRAVENOUS': l10n.routeIntravenous,
          'INTRAMUSCULAR': l10n.routeIntramuscular,
          'SUBCUTANEOUS': l10n.routeSubcutaneous,
          'RECTAL': l10n.routeRectal,
        };
    }
  }

  List<String> _selectedValues(String section) {
    switch (section) {
      case 'drugType':
        return _filters.productTypes;
      case 'dosageForm':
        return _filters.dosageForms;
      default:
        return _filters.routes;
    }
  }

  void _toggleFilter(String section, String value, bool isSelected) {
    final values = _selectedValues(section).toSet();
    if (isSelected) {
      values.add(value);
    } else {
      values.remove(value);
    }

    final updatedValues = values.toList()..sort();
    setState(() {
      switch (section) {
        case 'drugType':
          _filters = _filters.copyWith(productTypes: updatedValues);
          break;
        case 'dosageForm':
          _filters = _filters.copyWith(dosageForms: updatedValues);
          break;
        default:
          _filters = _filters.copyWith(routes: updatedValues);
          break;
      }
    });

    context.read<MedicationCubit>().setFilters(_filters);
  }

  void _clearFilters() {
    setState(() => _filters = MedicationFilters.empty);
    context.read<MedicationCubit>().setFilters(_filters);
  }
}

class _FilterBrandHeader extends StatelessWidget {
  const _FilterBrandHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 12, 4),
      child: SizedBox(
        height: 52,
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF8FC),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/images/logo.png',
                width: 52,
                height: 52,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Medi',
                    style: TextStyle(color: AppColors.brandMedi),
                  ),
                  TextSpan(
                    text: 'Pedia',
                    style: TextStyle(color: AppColors.brandPedia),
                  ),
                ],
              ),
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
