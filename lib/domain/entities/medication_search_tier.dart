/// Ordered API searches used to keep text-search results relevant across pages.
enum MedicationSearchTier {
  brandPrefix('openfda.brand_name', true),
  brandContains('openfda.brand_name', false),
  genericPrefix('openfda.generic_name', true),
  genericContains('openfda.generic_name', false),
  manufacturerPrefix('openfda.manufacturer_name', true),
  manufacturerContains('openfda.manufacturer_name', false),
  indicationsPrefix('indications_and_usage', true),
  indicationsContains('indications_and_usage', false);

  const MedicationSearchTier(this.field, this.isPrefix);

  final String field;
  final bool isPrefix;

  static const ordered = MedicationSearchTier.values;
}
