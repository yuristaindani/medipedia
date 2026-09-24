import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/medication_text_formatter.dart';
import '../../domain/entities/medication.dart';
import '../../l10n/app_localizations.dart';
import '../cubit/favorites_cubit.dart';
import '../../data/services/medication_translation_service.dart';
import '../cubit/locale_cubit.dart';

class MedicationDetailPage extends StatelessWidget {
  const MedicationDetailPage({
    super.key,
    required this.medication,
  });

  final Medication medication;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final languageCode = context.select<LocaleCubit, String>(
      (cubit) => cubit.state.languageCode,
    );

    final translationFuture = languageCode == 'id'
        ? context
            .read<MedicationTranslationService>()
            .translateToIndonesian(medication)
        : Future<Map<String, String>>.value({});

    final isFavorite = context.select<FavoritesCubit, bool>(
      (cubit) => cubit.isFavorite(medication.id),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        leadingWidth: 40,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon:
                const Icon(Icons.chevron_left, color: Colors.black, size: 29)),
        title: const Text.rich(
            TextSpan(children: [
              TextSpan(
                  text: 'Medi', style: TextStyle(color: AppColors.brandMedi)),
              TextSpan(
                  text: 'Pedia', style: TextStyle(color: AppColors.brandPedia)),
            ]),
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500)),
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFFFFE879),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            child: Text(
              l10n.disclaimer,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderInfo(
                    medication: medication,
                    l10n: l10n,
                    isFavorite: isFavorite,
                  ),
                  const SizedBox(height: 20),
                  _Section(
                    title: l10n.indications,
                    content: medication.indicationsAndUsage,
                    fallback: l10n.unknown,
                  ),
                  _Section(
                    title: l10n.activeIngredients,
                    content: medication.activeIngredient,
                    fallback: l10n.unknown,
                  ),
                  _Section(
                    title: l10n.dosage,
                    content: medication.dosageAndAdministration,
                    fallback: l10n.unknown,
                  ),
                  _Section(
                    title: l10n.warnings,
                    content: medication.warnings,
                    fallback: l10n.unknown,
                  ),
                  _Section(
                    title: l10n.purpose,
                    content: medication.purpose,
                    fallback: l10n.unknown,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderInfo extends StatelessWidget {
  const _HeaderInfo({
    required this.medication,
    required this.l10n,
    required this.isFavorite,
  });

  final Medication medication;
  final AppLocalizations l10n;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    final brand = MedicationTextFormatter.brandName(
      medication.brandName,
      l10n.unknown,
    );
    final generic = MedicationTextFormatter.titleCase(
      medication.genericName,
      l10n.unknown,
    );
    final manufacturer = MedicationTextFormatter.titleCase(
      medication.manufacturerName,
      l10n.unknown,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF8FC),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.medication_outlined,
            size: 72,
            color: Color(0xFF7896A5),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                brand,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                generic,
              ),
              const SizedBox(height: 4),
              Text(
                manufacturer,
              ),
              const SizedBox(height: 5),
              TextButton.icon(
                style: TextButton.styleFrom(
                    backgroundColor: AppColors.detailFavorite,
                    foregroundColor: Colors.black,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                onPressed: () =>
                    context.read<FavoritesCubit>().toggle(medication),
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? AppColors.brandMedi : Colors.black54,
                  size: 23,
                ),
                label: Text(l10n.favorites),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.content,
    required this.fallback,
  });

  final String title;
  final String? content;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content == null || content!.trim().isEmpty ? fallback : content!,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
