import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:tare/components/bottom_sheets/settings_layout_bottom_sheet_component.dart';
import 'package:tare/constants/colors.dart';
import 'package:tare/cubits/recipe_layout_cubit.dart';
import 'package:tare/cubits/theme_mode_cubit.dart';
import 'package:tare/extensions/string_extension.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool? themeModeSwitch;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeModeCubit themeModeCubit = context.read<ThemeModeCubit>();
    themeModeSwitch = (themeModeCubit.state == 'dark');

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 1.5,
        iconTheme: IconThemeData(
          color: Colors.black87,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87
          ),
        ),
      ),
      body: BlocBuilder<RecipeLayoutCubit, String>(
        builder: (context, layout) {
          return SettingsList(
            sections: [
              SettingsSection(
                  title: Text('App'),
                  tiles: [
                    SettingsTile.navigation(
                      leading: Icon(Icons.language),
                      title: Text('Language'),
                      value: Text('English'),
                    ),
                    SettingsTile.navigation(
                      leading: Icon(Icons.pageview_outlined),
                      title: Text('Default page'),
                      value: Text('Search'),
                    ),
                    SettingsTile.navigation(
                      onPressed: (context) => {
                        settingsLayoutBottomSheet(context)
                      },
                      leading: Icon(Icons.design_services_outlined),
                      title: Text('Recipe layout'),
                      value: Text(layout.capitalize()),
                    ),
                    SettingsTile.switchTile(
                      onToggle: (bool value) {
                        setState(() {
                          themeModeSwitch = value;
                        });
                        if (value) {
                          themeModeCubit.changeToDarkTheme();
                        } else {
                          themeModeCubit.changeToLightTheme();
                        }
                      },
                      initialValue: themeModeSwitch,
                      leading: Icon(Icons.format_paint),
                      title: Text('Dark mode'),
                    ),
                  ]
              ),
              SettingsSection(
                  title: Text('Server'),
                  tiles: [
                    SettingsTile(
                        title: Text('Test')
                    )
                  ]
              )
            ],
            platform: DevicePlatform.android,
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            lightTheme: SettingsThemeData(
              tileHighlightColor: primaryColor,
              titleTextColor: primaryColor
            ),
          );
        }
      )
    );
  }
}