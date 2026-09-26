import '../../domain/entities/medication.dart';

class MedicationModel extends Medication {
  static const _purposeHeadings = [
    'PURPOSE',
  ];

  static const _indicationHeadings = [
    'INDICATIONS AND USAGE',
    'INDICATIONS & USAGE',
    'INDICATIONS',
  ];

  static const _dosageHeadings = [
    'DOSAGE AND ADMINISTRATION',
    'DIRECTIONS',
  ];

  static const _warningHeadings = [
    'BOXED WARNINGS',
    'BOXED WARNING',
    'WARNINGS',
    'WARNING',
  ];

  static const _activeIngredientHeadings = [
    'ACTIVE INGREDIENTS',
    'ACTIVE INGREDIENT',
  ];

  const MedicationModel({
    required super.id,
    super.brandName,
    super.genericName,
    super.manufacturerName,
    super.purpose,
    super.indicationsAndUsage,
    super.dosageAndAdministration,
    super.warnings,
    super.activeIngredient,
  });

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    final openFda = json['openfda'] is Map
        ? Map<String, dynamic>.from(json['openfda'] as Map)
        : <String, dynamic>{};

    final id = _firstString(json['set_id']) ?? _firstString(json['id']);

    if (id == null || id.isEmpty) {
      throw const FormatException('Medication ID is missing');
    }

    return MedicationModel(
      id: id,
      brandName: _firstString(openFda['brand_name']),
      genericName: _firstString(openFda['generic_name']),
      manufacturerName: _firstString(openFda['manufacturer_name']),
      purpose: _joinSectionStrings(
        json['purpose'],
        _purposeHeadings,
      ),
      indicationsAndUsage: _joinSectionStrings(
        json['indications_and_usage'],
        _indicationHeadings,
      ),
      dosageAndAdministration: _joinSectionStrings(
        json['dosage_and_administration'],
        _dosageHeadings,
      ),
      warnings: _joinSectionStrings(
        json['warnings'],
        _warningHeadings,
      ),
      activeIngredient: _joinSectionStrings(
        json['active_ingredient'],
        _activeIngredientHeadings,
      ),
    );
  }

  static String? _firstString(dynamic value) {
    if (value is String) {
      return _clean(value);
    }

    if (value is List) {
      for (final item in value) {
        if (item is String) {
          final cleaned = _clean(item);
          if (cleaned != null) {
            return cleaned;
          }
        }
      }
    }

    return null;
  }

  static String? _clean(String value) {
    final cleaned = value
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return cleaned.isEmpty ? null : cleaned;
  }

  static String? _joinSectionStrings(
    dynamic value,
    List<String> headings,
  ) {
    final List<String> entries;

    if (value is String) {
      entries = [value];
    } else if (value is List) {
      entries = value.whereType<String>().toList();
    } else {
      return null;
    }

    final cleanedEntries = entries
        .map((entry) => _cleanSection(entry, headings))
        .whereType<String>()
        .where((entry) => entry.isNotEmpty)
        .toList();

    if (cleanedEntries.isEmpty) {
      return null;
    }

    return cleanedEntries.join('\n\n');
  }

  static String? _cleanSection(
    String value,
    List<String> headings,
  ) {
    var text = value
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();

    if (text.isEmpty) {
      return null;
    }

    final alternatives = headings.map(RegExp.escape).join('|');

    final headingAtStart = RegExp(
      '^\\s*(?:\\(?\\d+\\)?[.)]?\\s+)?'
      '(?:$alternatives)'
      '(?:\\s*[:.;\\-–—]\\s*|\\s+)',
      caseSensitive: false,
    );

    while (headingAtStart.hasMatch(text)) {
      text = text.replaceFirst(headingAtStart, '').trimLeft();
    }

    text = text.replaceAll(
      RegExp(r'\s+\*\s+'),
      '\n• ',
    );

    text = text.replaceAll(
      RegExp(
        r'\b(Uses|Directions|Warnings|Indications)\s+[-–—]\s+',
        caseSensitive: false,
      ),
      r'$1: ',
    );

    text = text
        .replaceAll(RegExp(r' *\n *'), '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();

    return text.isEmpty ? null : text;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brandName': brandName,
      'genericName': genericName,
      'manufacturerName': manufacturerName,
      'purpose': purpose,
      'indicationsAndUsage': indicationsAndUsage,
      'dosageAndAdministration': dosageAndAdministration,
      'warnings': warnings,
      'activeIngredient': activeIngredient,
    };
  }

  factory MedicationModel.fromEntity(Medication medication) {
    return MedicationModel(
      id: medication.id,
      brandName: medication.brandName,
      genericName: medication.genericName,
      manufacturerName: medication.manufacturerName,
      purpose: medication.purpose,
      indicationsAndUsage: medication.indicationsAndUsage,
      dosageAndAdministration: medication.dosageAndAdministration,
      warnings: medication.warnings,
      activeIngredient: medication.activeIngredient,
    );
  }

  factory MedicationModel.fromStoredJson(
    Map<String, dynamic> json,
  ) {
    return MedicationModel(
      id: json['id'] as String,
      brandName: json['brandName'] as String?,
      genericName: json['genericName'] as String?,
      manufacturerName: json['manufacturerName'] as String?,
      purpose: _cleanSection(
        json['purpose'] as String? ?? '',
        _purposeHeadings,
      ),
      indicationsAndUsage: _cleanSection(
        json['indicationsAndUsage'] as String? ?? '',
        _indicationHeadings,
      ),
      dosageAndAdministration: _cleanSection(
        json['dosageAndAdministration'] as String? ?? '',
        _dosageHeadings,
      ),
      warnings: _cleanSection(
        json['warnings'] as String? ?? '',
        _warningHeadings,
      ),
      activeIngredient: _cleanSection(
        json['activeIngredient'] as String? ?? '',
        _activeIngredientHeadings,
      ),
    );
  }
}
