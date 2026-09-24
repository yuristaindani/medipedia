import '../../domain/entities/medication.dart';

class MedicationModel extends Medication {
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

    final id = _firstString(json['set_id']) ??
        _firstString(json['id']);

    if (id == null || id.isEmpty) {
      throw const FormatException('Medication ID is missing');
    }

    return MedicationModel(
      id: id,
      brandName: _firstString(openFda['brand_name']),
      genericName: _firstString(openFda['generic_name']),
      manufacturerName: _firstString(openFda['manufacturer_name']),
      purpose: _joinStrings(json['purpose']),
      indicationsAndUsage: _joinStrings(
        json['indications_and_usage'],
      ),
      dosageAndAdministration: _joinStrings(
        json['dosage_and_administration'],
      ),
      warnings: _joinStrings(json['warnings']),
      activeIngredient: _joinStrings(
        json['active_ingredient'],
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

  static String? _joinStrings(dynamic value) {
    if (value is String) {
      return _clean(value);
    }

    if (value is List) {
      final values = value
          .whereType<String>()
          .map(_clean)
          .whereType<String>()
          .where((item) => item.isNotEmpty)
          .toList();

      if (values.isEmpty) {
        return null;
      }

      return values.join('\n\n');
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
      purpose: json['purpose'] as String?,
      indicationsAndUsage:
          json['indicationsAndUsage'] as String?,
      dosageAndAdministration:
          json['dosageAndAdministration'] as String?,
      warnings: json['warnings'] as String?,
      activeIngredient:
          json['activeIngredient'] as String?,
    );
  }
}
