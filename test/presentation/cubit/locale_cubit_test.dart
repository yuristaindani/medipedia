import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medipedia/presentation/cubit/locale_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('starts in English and persists the selected Indonesian locale',
      () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final cubit = LocaleCubit(preferences);

    expect(cubit.state, const Locale('en'));

    await cubit.setLanguage('id');

    expect(cubit.state, const Locale('id'));
    expect(preferences.getString('app_language'), 'id');

    await cubit.close();
  });
}
