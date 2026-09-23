import 'package:equatable/equatable.dart';

class Medication extends Equatable {
  const Medication({
    required this.id,
    this.brandName,
    this.genericName,
    this.manufacturerName,
    this.purpose,
    this.indicationsAndUsage,
    this.dosageAndAdministration,
    this.warnings,
    this.activeIngredient,
  });

  final String id;
  final String? brandName;
  final String? genericName;
  final String? manufacturerName;
  final String? purpose;
  final String? indicationsAndUsage;
  final String? dosageAndAdministration;
  final String? warnings;
  final String? activeIngredient;

  @override
  List<Object?> get props => [
        id,
        brandName,
        genericName,
        manufacturerName,
        purpose,
        indicationsAndUsage,
        dosageAndAdministration,
        warnings,
        activeIngredient,
      ];
}