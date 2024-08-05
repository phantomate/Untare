import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untare/cubits/settings_cubit.dart';

Future settingsDefaultPageBottomSheet(BuildContext context) {
  return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      context: context,
      builder: (btsContext) => Container(
        decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(10))
        ),
        child: Wrap(
          children: [
            Container(
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Text(
                AppLocalizations.of(context)!.settingsDefaultPage,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(left: 12, right: 12),
              child: Column(
                children: [
                  ListTile(
                    onTap: () {
                      context.read<SettingsCubit>().changeDefaultPageTo('plan');
                      Navigator.pop(btsContext);
                    },
                    title: Text(AppLocalizations.of(context)!.mealPlanTitle),
                  ),
                  ListTile(
                    onTap: () {
                      context.read<SettingsCubit>().changeDefaultPageTo('recipes');
                      Navigator.pop(btsContext);
                    },
                    title: Text(AppLocalizations.of(context)!.recipesTitle),
                  ),
                  ListTile(
                    onTap: () {
                      context.read<SettingsCubit>().changeDefaultPageTo('shopping');
                      Navigator.pop(btsContext);
                    },
                    title: Text(AppLocalizations.of(context)!.shoppingListTitle),
                  )
                ],
              ),
            )
          ],
        ),
      )
  );
}