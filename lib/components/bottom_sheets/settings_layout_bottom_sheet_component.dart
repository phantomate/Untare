import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untare/cubits/settings_cubit.dart';

Future settingsLayoutBottomSheet(BuildContext context) {
  return showModalBottomSheet(
      showDragHandle: true,
      useRootNavigator: true,
      context: context,
      builder: (btsContext) => Wrap(
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: Column(
              children: [
                ListTile(
                  onTap: () {
                    context.read<SettingsCubit>().changeLayoutTo('card');
                    Navigator.pop(btsContext);
                  },
                  title: Text(AppLocalizations.of(context)!.settingRecipeLayoutCard),
                ),
                ListTile(
                  onTap: () {
                    context.read<SettingsCubit>().changeLayoutTo('list');
                    Navigator.pop(btsContext);
                  },
                  title: Text(AppLocalizations.of(context)!.settingRecipeLayoutList),
                )
              ],
            ),
          )
        ],
      ),
  );
}