import 'package:equatable/equatable.dart';

class MedicationFilters extends Equatable {
  const MedicationFilters({
    this.productTypes = const [],
    this.dosageForms = const [],
    this.routes = const [],
  });

  static const empty = MedicationFilters();

  /// OpenFDA values, for example `HUMAN OTC DRUG`.
  final List<String> productTypes;

  /// Search terms matched against `dosage_forms_and_strengths`.
  final List<String> dosageForms;

  /// OpenFDA route values, for example `ORAL` or `TOPICAL`.
  final List<String> routes;

  bool get isEmpty =>
      productTypes.isEmpty && dosageForms.isEmpty && routes.isEmpty;

  MedicationFilters copyWith({
    List<String>? productTypes,
    List<String>? dosageForms,
    List<String>? routes,
  }) {
    return MedicationFilters(
      productTypes: productTypes ?? this.productTypes,
      dosageForms: dosageForms ?? this.dosageForms,
      routes: routes ?? this.routes,
    );
  }

  @override
  List<Object?> get props => [productTypes, dosageForms, routes];
}
