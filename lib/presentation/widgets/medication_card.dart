import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/medication_text_formatter.dart';
import '../../domain/entities/medication.dart';
import '../../l10n/app_localizations.dart';
import '../cubit/favorites_cubit.dart';
import '../pages/medication_detail_page.dart';

class MedicationCard extends StatelessWidget {
  const MedicationCard({
    super.key,
    required this.medication,
  });

  final Medication medication;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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

    final isFavorite = context.select<FavoritesCubit, bool>(
      (cubit) => cubit.isFavorite(medication.id),
    );

    return Semantics(
      button: true,
      label: '${l10n.brandName}: $brand, '
          '${l10n.genericName}: $generic, '
          '${l10n.manufacturer}: $manufacturer',
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MedicationDetailPage(
                  medication: medication,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MedicationArtwork(seed: medication.id),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          brand,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _LabeledValue(
                          label: l10n.genericName,
                          value: generic,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 3),
                        _LabeledValue(
                          label: l10n.manufacturer,
                          value: manufacturer,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  tooltip: isFavorite
                      ? l10n.removeFromFavorites
                      : l10n.addToFavorites,
                  onPressed: () {
                    context.read<FavoritesCubit>().toggle(medication);
                  },
                  padding: const EdgeInsets.all(5),
                  constraints: const BoxConstraints(
                    minWidth: 42,
                    minHeight: 42,
                  ),
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? AppColors.brandMedi : Colors.black54,
                    size: 27,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LabeledValue extends StatelessWidget {
  const _LabeledValue({
    required this.label,
    required this.value,
    required this.maxLines,
  });

  final String label;
  final String value;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 13,
      ),
    );
  }
}

class _MedicationArtwork extends StatelessWidget {
  const _MedicationArtwork({required this.seed});

  final String seed;

  @override
  Widget build(BuildContext context) {
    final shade = seed.hashCode.abs() % 3;
    final icons = [
      Icons.medication_outlined,
      Icons.local_drink_outlined,
      Icons.medical_services_outlined,
    ];
    final backgroundColors = [
      const Color(0xFFDCEAF1),
      const Color(0xFFF1F4F6),
      const Color(0xFFE8F1F5),
    ];

    return Container(
      width: 116,
      height: 116,
      decoration: BoxDecoration(
        color: backgroundColors[shade],
        borderRadius: BorderRadius.circular(21),
      ),
      child: Icon(
        icons[shade],
        size: 62,
        color: const Color(0xFF7896A5),
      ),
    );
  }
}
