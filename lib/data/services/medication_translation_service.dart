import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import '../../domain/entities/medication.dart';

/// Translates only the four selected OpenFDA label sections on the device.
class MedicationTranslationService {
  final OnDeviceTranslatorModelManager _modelManager =
      OnDeviceTranslatorModelManager();

  final Map<String, Future<Map<String, String>>> _cache = {};

  Future<Map<String, String>> translateToIndonesian(
    Medication medication,
  ) async {
    final cacheKey = Object.hash(
      medication.id,
      medication.indicationsAndUsage,
      medication.dosageAndAdministration,
      medication.warnings,
      medication.purpose,
    ).toString();

    final cached = _cache[cacheKey];
    if (cached != null) {
      return cached;
    }

    final translation = _translate(medication);
    _cache[cacheKey] = translation;

    try {
      return await translation;
    } catch (_) {
      _cache.remove(cacheKey);
      rethrow;
    }
  }

  Future<Map<String, String>> _translate(
    Medication medication,
  ) async {
    await _ensureModelDownloaded(TranslateLanguage.english);
    await _ensureModelDownloaded(TranslateLanguage.indonesian);

    final translator = OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.english,
      targetLanguage: TranslateLanguage.indonesian,
    );

    try {
      final translations = <String, String>{};

      await _translateField(
        translator,
        translations,
        'indicationsAndUsage',
        medication.indicationsAndUsage,
      );
      await _translateField(
        translator,
        translations,
        'dosageAndAdministration',
        medication.dosageAndAdministration,
      );
      await _translateField(
        translator,
        translations,
        'warnings',
        medication.warnings,
      );
      await _translateField(
        translator,
        translations,
        'purpose',
        medication.purpose,
      );

      return translations;
    } finally {
      await translator.close();
    }
  }

  Future<void> _ensureModelDownloaded(
    TranslateLanguage language,
  ) async {
    final languageCode = language.bcpCode;
    final isDownloaded = await _modelManager.isModelDownloaded(languageCode);

    if (!isDownloaded) {
      await _modelManager.downloadModel(languageCode);
    }
  }

  Future<void> _translateField(
    OnDeviceTranslator translator,
    Map<String, String> translations,
    String key,
    String? sourceText,
  ) async {
    if (sourceText == null || sourceText.trim().isEmpty) {
      return;
    }

    translations[key] = await translator.translateText(sourceText);
  }
}
