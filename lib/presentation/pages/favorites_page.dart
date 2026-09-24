import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../cubit/favorites_cubit.dart';
import '../widgets/app_empty_view.dart';
import '../widgets/medication_card.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        leadingWidth: 40,
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.chevron_left, color: Colors.black, size: 29)),
        title: const Text.rich(TextSpan(children: [
          TextSpan(text: 'Medi', style: TextStyle(color: AppColors.brandMedi)),
          TextSpan(text: 'Pedia', style: TextStyle(color: AppColors.brandPedia)),
        ]), style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500)),
        titleSpacing: 0,
      ),
      body: BlocBuilder<
          FavoritesCubit,
          FavoritesState>(
        builder: (context, state) {
          if (state.isLoading &&
              state.medications.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.medications.isEmpty) {
            return AppEmptyView(
              message: l10n.emptyFavorites,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
            itemCount: state.medications.length,
            itemBuilder: (context, index) {
              return MedicationCard(
                medication:
                    state.medications[index],
              );
            },
          );
        },
      ),
    );
  }
}
