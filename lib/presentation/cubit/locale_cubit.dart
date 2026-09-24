import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(this._preferences)
      : super(
          Locale(
            _preferences.getString(_key) ?? 'en',
          ),
        );

  static const String _key = 'app_language';

  final SharedPreferences _preferences;

  Future<void> setLanguage(String languageCode) async {
    if (languageCode != 'en' && languageCode != 'id') {
      return;
    }

    await _preferences.setString(_key, languageCode);
    emit(Locale(languageCode));
  }
}
