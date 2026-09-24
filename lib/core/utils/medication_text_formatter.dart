class MedicationTextFormatter {
  const MedicationTextFormatter._();

  static String brandName(String? value, String fallback) {
    return _display(value, fallback).toUpperCase();
  }

  static String titleCase(String? value, String fallback) {
    final lowercaseValue = _display(value, fallback).toLowerCase();

    return lowercaseValue.replaceAllMapped(
      RegExp(r'(^|[\s\-/])([^\s\-/])'),
      (match) => '${match[1]}${match[2]!.toUpperCase()}',
    );
  }

  static String _display(String? value, String fallback) {
    if (value == null || value.trim().isEmpty) {
      return fallback;
    }

    return value.trim();
  }
}
