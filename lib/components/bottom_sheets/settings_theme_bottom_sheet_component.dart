import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';
import 'package:untare/cubits/settings_cubit.dart';

Future settingsThemeBottomSheet(BuildContext context) {
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
                    context.read<SettingsCubit>().changeThemeTo('dark');
                    Navigator.pop(btsContext);
                  },
                  title: Text(AppLocalizations.of(context)!.settingsDarkMode),
                ),
                ListTile(
                  onTap: () {
                    context.read<SettingsCubit>().changeThemeTo('light');
                    Navigator.pop(btsContext);
                  },
                  title: Text(AppLocalizations.of(context)!.settingsLightMode),
                ),
                ListTile(
                  onTap: () {
                    context.read<SettingsCubit>().changeThemeTo('system');
                    Navigator.pop(btsContext);
                  },
                  title: Text(AppLocalizations.of(context)!.settingsSystemMode),
                )
              ],
            ),
          )
        ],
      ),
  );
}