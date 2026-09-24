import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  String _sectionKey = 'drugType';
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDrugType = _sectionKey == 'drugType';
    final choices = isDrugType
        ? {
            'otc': l10n.overTheCounter,
            'prescription': l10n.prescription,
          }
        : {
            'tablet': l10n.tablet,
            'capsule': l10n.capsule,
            'cream': l10n.cream,
          };

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          l10n.filterTitle,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: l10n.close,
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.close,
              color: Colors.black,
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      body: Row(
        children: [
          SizedBox(
            width: 154,
            child: Column(
              children: [
                _sectionButton('drugType', l10n.drugType),
                _sectionButton('dosageForm', l10n.dosageForm),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(7, 9, 7, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isDrugType ? l10n.drugType : l10n.dosageForm,
                    style: const TextStyle(
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
                        selected: _selected.contains(entry.key),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selected.add(entry.key);
                            } else {
                              _selected.remove(entry.key);
                            }
                          });
                        },
                        showCheckmark: false,
                        backgroundColor: const Color(0xFFE4E4E4),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionButton(String key, String title) {
    final isSelected = _sectionKey == key;

    return InkWell(
      onTap: () => setState(() => _sectionKey = key),
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
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
