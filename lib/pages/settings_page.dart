import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:untare/blocs/authentication/authentication_bloc.dart';
import 'package:untare/blocs/authentication/authentication_event.dart';
import 'package:untare/components/bottom_sheets/settings_default_page_bottom_sheet_component.dart';
import 'package:untare/components/bottom_sheets/settings_layout_bottom_sheet_component.dart';
import 'package:untare/components/bottom_sheets/settings_theme_bottom_sheet_component.dart';
import 'package:untare/components/dialogs/edit_share_dialog.dart';
import 'package:untare/components/dialogs/edit_shopping_list_recent_days_dialog.dart';
import 'package:untare/components/dialogs/edit_shopping_list_refresh_dialog.dart';
import 'package:untare/cubits/settings_cubit.dart';
import 'package:untare/extensions/string_extension.dart';
import 'package:untare/models/app_setting.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:untare/models/user_setting.dart';
import 'package:untare/pages/spaces_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().initServerSetting();
  }

  @override
  Widget build(BuildContext context) {
    final AuthenticationBloc authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    SettingsCubit settingsCubit = context.read<SettingsCubit>();
    bool? useFraction = (settingsCubit.state.userServerSetting != null && settingsCubit.state.userServerSetting!.useFractions == true);

    return Scaffold(
      body:  NestedScrollView(
          headerSliverBuilder: (BuildContext hsbContext, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 90,
                leadingWidth: 0,
                titleSpacing: 0,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.fromLTRB(20, 0, 0, 16),
                  expandedTitleScale: 1.3,
                  title: Text(
                    AppLocalizations.of(context)!.settingsTitle,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: (Theme.of(context).appBarTheme.titleTextStyle != null) ? Theme.of(context).appBarTheme.titleTextStyle!.color : null
                    ),
                  ),
                ),
                elevation: 1.5,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                pinned: true,
              )
            ];
          },
          body: BlocBuilder<SettingsCubit, AppSetting>(
              builder: (context, setting) {
                String defaultPageLayout = setting.defaultPage.capitalize();
                if (setting.defaultPage == 'recipes') {
                  defaultPageLayout = AppLocalizations.of(context)!.recipesTitle;
                } else if (setting.defaultPage == 'plan') {
                  defaultPageLayout = AppLocalizations.of(context)!.mealPlanTitle;
                } else if (setting.defaultPage == 'shopping') {
                  defaultPageLayout = AppLocalizations.of(context)!.shoppingListTitle;
                }

                return SettingsList(
                  sections: [
                    SettingsSection(
                        title: Text(AppLocalizations.of(context)!.settingsCustomization),
                        tiles: [
                          SettingsTile.navigation(
                            onPressed: (context) => settingsDefaultPageBottomSheet(context),
                            leading: const Icon(Icons.pageview_outlined),
                            title: Text(AppLocalizations.of(context)!.settingsDefaultPage),
                            value: Text(defaultPageLayout),
                          ),
                          SettingsTile.navigation(
                            onPressed: (context) => settingsLayoutBottomSheet(context),
                            leading: const Icon(Icons.design_services_outlined),
                            title: Text(AppLocalizations.of(context)!.settingsRecipeLayout),
                            value: Text((setting.layout == 'card') ? AppLocalizations.of(context)!.settingRecipeLayoutCard : AppLocalizations.of(context)!.settingRecipeLayoutList),
                          ),
                          SettingsTile.navigation(
                            onPressed: (context) => settingsThemeBottomSheet(context),
                            leading: const Icon(Icons.format_paint),
                            title: Text(AppLocalizations.of(context)!.settingsThemeMode),
                            value: Text((setting.theme != 'system') ? ((setting.theme == 'light') ? AppLocalizations.of(context)!.settingsLightMode : AppLocalizations.of(context)!.settingsDarkMode) : AppLocalizations.of(context)!.settingsSystemMode),
                          ),
                          SettingsTile.navigation(
                              onPressed: (context) {
                                Color pickedColor = Color(setting.materialHexColor);
                                showDialog(context: context, builder: (BuildContext dContext) {
                                  return AlertDialog(
                                    title: Text(AppLocalizations.of(context)!.pickColor),
                                    content: SingleChildScrollView(
                                      child: BlockPicker(
                                        pickerColor: pickedColor,
                                        availableColors: const [
                                          Colors.redAccent, Colors.pink, Colors.purple,
                                          Colors.deepPurple, Colors.indigo, Colors.blueAccent,
                                          Colors.lightBlue, Colors.lightBlueAccent, Colors.teal,
                                          Colors.green, Colors.lightGreen, Colors.lime,
                                          Colors.amberAccent, Color(0xffceb27c), Colors.orange,
                                          Colors.deepOrange, Colors.brown, Colors.grey,
                                          Colors.blueGrey, Colors.black
                                        ],
                                        onColorChanged: (Color color) {
                                          pickedColor = color;
                                          settingsCubit.changeColorTo(int.parse('0x${pickedColor.value.toRadixString(16)}'));
                                          Navigator.of(context).pop();
                                        },
                                        itemBuilder: (Color color, bool isCurrentColor, void Function() changeColor) {
                                          return Container(
                                            margin: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(30),
                                              color: color,
                                            ),
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: changeColor,
                                                borderRadius: BorderRadius.circular(30),
                                                child: AnimatedOpacity(
                                                  duration: const Duration(milliseconds: 250),
                                                  opacity: isCurrentColor ? 1: 0,
                                                  child: Icon(Icons.done, size: 30, color: useWhiteForeground(color) ? Colors.white : Colors.black),
                                                ),
                                              ),
                                            )
                                          );
                                        },
                                      )
                                    )
                                  );
                                });
                              },
                              leading: const Icon(Icons.color_lens_outlined),
                              title: Text(AppLocalizations.of(context)!.accentColor),
                              trailing: Icon(Icons.circle, color: Color(setting.materialHexColor))
                          )
                        ]
                    ),
                    if (setting.userServerSetting != null)
                      SettingsSection(
                          title: Text(AppLocalizations.of(context)!.shoppingListTitle),
                          tiles: [
                            SettingsTile(
                              leading: const Icon(Icons.share_outlined),
                              title: Text(AppLocalizations.of(context)!.settingsSharedWith),
                              value: Text(setting.userServerSetting!.shoppingShare.isNotEmpty ? setting.userServerSetting!.shoppingShare.map((user) => user.username).toList().join(',') : '-'),
                              onPressed: (context) => editShareDialog(context, setting.userServerSetting!, 'shopping'),
                            ),
                            SettingsTile(
                              leading: const Icon(Icons.refresh_outlined),
                              title: Text(AppLocalizations.of(context)!.settingsRefreshInterval),
                              description: Text(AppLocalizations.of(context)!.settingsRefreshIntervalDescription.replaceFirst('%s', setting.userServerSetting!.shoppingAutoSync.toString())),
                              onPressed: (context) => editShoppingListRefreshDialog(context, setting.userServerSetting!),
                            ),
                            SettingsTile(
                              leading: const Icon(Icons.calendar_today_sharp),
                              title: Text(AppLocalizations.of(context)!.settingsRecentDays),
                              description: Text(AppLocalizations.of(context)!.settingsRecentDaysDescription.replaceFirst('%s', setting.userServerSetting!.shoppingRecentDays.toString())),
                              onPressed: (context) => editShoppingListRecentDaysDialog(context, setting.userServerSetting!),
                            ),
                           /* SettingsTile.switchTile(
                              enabled: false,
                              leading: Icon(Icons.add_shopping_cart_outlined),
                              onToggle: (bool value) {

                              },
                              activeSwitchColor: Theme.of(context).primaryColor,
                              initialValue: setting.userServerSetting!.mealPlanAutoAddShopping,
                              title: Text('Auto add meal plan'),
                              description: Text('Automatically add meal plan ingredients to shopping list'),
                            ),*/
                          ]
                      ),
                    if (setting.userServerSetting != null)
                      SettingsSection(
                          title: Text(AppLocalizations.of(context)!.mealPlanTitle),
                          tiles: [
                            SettingsTile(
                              leading: const Icon(Icons.share_outlined),
                              title: Text(AppLocalizations.of(context)!.settingsSharedWith),
                              value: Text(setting.userServerSetting!.planShare.isNotEmpty ? setting.userServerSetting!.planShare.map((user) => user.username).toList().join(',') : '-'),
                              onPressed: (context) => editShareDialog(context, setting.userServerSetting!, 'plan'),
                            ),
                          ]
                      ),
                    SettingsSection(
                        title: Text(AppLocalizations.of(context)!.settingsMiscellaneous),
                        tiles: [
                          SettingsTile.navigation(
                              onPressed: (context) => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SpacesPage()),
                              ),
                              leading: const Icon(Icons.workspaces_outline),
                              title: Text(AppLocalizations.of(context)!.spaces)
                          ),
                          /*SettingsTile(
                            enabled: false,
                            leading: Icon(Icons.scale_outlined),
                            title: Text('Default unit'),
                            value: Text(setting.userServerSetting!.defaultUnit),
                          ),*/
                          SettingsTile.switchTile(
                            leading: const Icon(Icons.numbers_outlined),
                            onToggle: (bool value) {
                              setState(() {
                                useFraction = value;
                              });

                              UserSetting newUserSetting;
                              newUserSetting = setting.userServerSetting!.copyWith(useFractions: value);
                              settingsCubit.updateServerSetting(newUserSetting);
                            },
                            activeSwitchColor: Theme.of(context).primaryColor,
                            initialValue: useFraction,
                            title: Text(AppLocalizations.of(context)!.useFractions),
                          ),
                          /*SettingsTile.switchTile(
                            enabled: false,
                            leading: Icon(Icons.settings),
                            onToggle: (bool value) {

                            },
                            initialValue: setting.userServerSetting!.useKj,
                            title: Text('Use KJ'),
                          ),
                          SettingsTile(
                            enabled: false,
                            leading: Icon(Icons.settings),
                            title: Text('Ingredient decimal places'),
                            value: Text(setting.userServerSetting!.ingredientDecimal.toString()),
                          ),
                          SettingsTile.switchTile(
                            enabled: false,
                            leading: Icon(Icons.comment_outlined),
                            onToggle: (bool value) {

                            },
                            initialValue: setting.userServerSetting!.comments,
                            title: Text('Comments'),
                            description: Text('If you want to be able to create and see comments underneath recipes'),
                          ),*/
                        ]
                    ),
                    SettingsSection(
                        title: Text(AppLocalizations.of(context)!.settingsLogout),
                        tiles: [
                          SettingsTile(
                              onPressed: (context) => authenticationBloc.add(UserLoggedOut()),
                              leading: const Icon(Icons.logout_outlined),
                              title: Text(AppLocalizations.of(context)!.settingsLogout)
                          )
                        ]
                    )
                  ],
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  lightTheme: SettingsThemeData(
                      tileHighlightColor: Theme.of(context).primaryColor,
                      titleTextColor: Theme.of(context).primaryColor,
                      settingsListBackground: Theme.of(context).scaffoldBackgroundColor
                  ),
                  darkTheme: SettingsThemeData(
                      tileHighlightColor: Theme.of(context).primaryColor,
                      titleTextColor: Theme.of(context).primaryColor,
                      settingsListBackground: Theme.of(context).scaffoldBackgroundColor
                  ),
                );
              }
          )
      )
    );
  }
}