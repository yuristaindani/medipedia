import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import 'medication_list_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _navigationTimer = Timer(
      const Duration(milliseconds: 1800),
      () {
        if (!mounted) {
          return;
        }

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const MedicationListPage(),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 164,
              height: 164,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFB7EFF8),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.15),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 52,
                    height: 52,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 1),
                  Text.rich(
                      TextSpan(children: [
                        TextSpan(
                            text: 'Medi',
                            style: TextStyle(
                                color: Color(0xFF008FC1),
                                fontWeight: FontWeight.w700)),
                        TextSpan(
                            text: 'Pedia',
                            style: TextStyle(
                                color: Color(0xFF171717),
                                fontWeight: FontWeight.w500)),
                      ]),
                      style: TextStyle(fontSize: 22)),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text(
              l10n.tagline,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
