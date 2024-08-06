import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:untare/blocs/meal_plan/meal_plan_bloc.dart';
import 'package:untare/blocs/meal_plan/meal_plan_state.dart';
import 'package:untare/blocs/recipe/recipe_bloc.dart';
import 'package:untare/blocs/recipe/recipe_state.dart';
import 'package:untare/blocs/shopping_list/shopping_list_bloc.dart';
import 'package:untare/blocs/shopping_list/shopping_list_state.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';

import 'package:untare/cubits/settings_cubit.dart';
import 'package:untare/cubits/shopping_list_entry_cubit.dart';
import 'package:untare/extensions/theme_extension.dart';
import 'package:untare/models/app_setting.dart';
import 'package:untare/models/food.dart';
import 'package:untare/models/ingredient.dart';
import 'package:untare/models/keyword.dart';
import 'package:untare/models/meal_plan_entry.dart';
import 'package:untare/models/meal_type.dart';
import 'package:untare/models/nutritional_value.dart';
import 'package:untare/models/recipe.dart';
import 'package:untare/models/recipe_meal_plan.dart';
import 'package:untare/models/shopping_list_entry.dart';
import 'package:untare/models/space.dart';
import 'package:untare/models/step.dart';
import 'package:untare/models/supermarket_category.dart';
import 'package:untare/models/unit.dart';
import 'package:untare/models/user.dart';
import 'package:untare/models/user_setting.dart';
import 'package:untare/pages/meal_plan_page.dart';
import 'package:untare/pages/recipes_page.dart';
import 'package:untare/pages/settings_page.dart';
import 'package:untare/pages/shopping_list_page.dart';
import 'package:untare/pages/starting_page.dart';
import 'package:untare/services/api/api_meal_plan.dart';
import 'package:untare/services/api/api_meal_type.dart';
import 'package:untare/services/api/api_recipe.dart';
import 'package:untare/services/api/api_service.dart';
import 'package:untare/services/api/api_shopping_list.dart';
import 'package:untare/services/api/api_supermarket_category.dart';
import 'package:untare/services/api/api_user.dart';
import 'package:untare/services/cache/cache_meal_plan_service.dart';
import 'package:untare/services/cache/cache_recipe_service.dart';
import 'package:untare/services/cache/cache_shopping_list_service.dart';
import 'package:untare/services/cache/cache_user_service.dart';
import 'package:workmanager/workmanager.dart';


import 'blocs/authentication/authentication_bloc.dart';
import 'blocs/authentication/authentication_event.dart';
import 'blocs/authentication/authentication_state.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await _initHive();

  await Workmanager().initialize(_callbackDispatcher);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown, DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]).then((_){
    runApp(
        Phoenix(
            child: const Tare()
        )
    );
  });
}

Future _initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(RecipeAdapter());
  Hive.registerAdapter(StepModelAdapter());
  Hive.registerAdapter(IngredientAdapter());
  Hive.registerAdapter(FoodAdapter());
  Hive.registerAdapter(UnitAdapter());
  Hive.registerAdapter(SupermarketCategoryAdapter());
  Hive.registerAdapter(MealPlanEntryAdapter());
  Hive.registerAdapter(MealTypeAdapter());
  Hive.registerAdapter(ShoppingListEntryAdapter());
  Hive.registerAdapter(RecipeMealPlanAdapter());
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(AppSettingAdapter());
  Hive.registerAdapter(UserSettingAdapter());
  Hive.registerAdapter(KeywordAdapter());
  Hive.registerAdapter(SpaceAdapter());
  Hive.registerAdapter(NutritionalValueAdapter());
  await Hive.openBox('unTaReBox');
}

void _callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Retry failed request
    if (task == 'retryFailedRequestTask') {
      await _initHive();

      final ApiService apiService = ApiService();
      await apiService.retryRequest(inputData!);
    }

    return Future.value(true);
  });
}

class Tare extends StatelessWidget {
  const Tare({super.key});

  @override
  Widget build(BuildContext context) {
    var box = Hive.box('unTaReBox');

    return MultiBlocProvider(
        providers: [
          BlocProvider<AuthenticationBloc>(
              create: (context) => AuthenticationBloc()..add(AppLoaded())
          ),
          BlocProvider<SettingsCubit>(
              create: (context) {
                SettingsCubit cubit = SettingsCubit(apiUser: ApiUser(), cacheUserService: CacheUserService());
                AppSetting? storedAppSetting = box.get('settings');
                if (storedAppSetting != null) {
                  cubit.changeLayoutTo(storedAppSetting.layout);
                  cubit.changeThemeTo(storedAppSetting.theme);
                  cubit.changeDefaultPageTo(storedAppSetting.defaultPage);
                  cubit.changeColorTo(storedAppSetting.materialHexColor);
                }
                return cubit;
              }
          ),
          BlocProvider<RecipeBloc>(
            create: (BuildContext context) => RecipeBloc(apiRecipe: ApiRecipe(), cacheRecipeService: CacheRecipeService())
          ),
          BlocProvider<MealPlanBloc>(
            create: (BuildContext context) => MealPlanBloc(apiMealPlan: ApiMealPlan(), apiMealType: ApiMealType(), cacheMealPlanService: CacheMealPlanService())
          ),
          BlocProvider<ShoppingListBloc>(
            create: (BuildContext context) => ShoppingListBloc(apiShoppingList: ApiShoppingList(), apiSupermarketCategory: ApiSupermarketCategory(), cacheShoppingListService: CacheShoppingListService())
          ),
          BlocProvider<ShoppingListEntryCubit>(
            create: (BuildContext context) => ShoppingListEntryCubit()
          )
        ],
        child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {

            SettingsCubit settingsCubit = context.watch<SettingsCubit>();

            ThemeMode themeMode = ThemeMode.system;
            switch(settingsCubit.state.theme) {
              case 'light':
                themeMode = ThemeMode.light;
                break;
              case 'dark':
                themeMode = ThemeMode.dark;
                break;
              default:
                themeMode = ThemeMode.system;
            }

            return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
              return MaterialApp(
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  FormBuilderLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en'),
                  Locale('de'),
                  Locale('fr'),
                  Locale('nl'),
                  Locale('da'),
                  Locale('ru')
                ],
                debugShowCheckedModeBanner: false,
                title: 'UnTaRe App',
                theme: settingsCubit.state.dynamicColor && lightColorScheme != null ? AppTheme.fromScheme(lightColorScheme) : AppTheme.fromColor(Color(settingsCubit.state.materialHexColor), Brightness.light),
                darkTheme: settingsCubit.state.dynamicColor && darkColorScheme != null ? AppTheme.fromScheme(darkColorScheme) : AppTheme.fromColor(Color(settingsCubit.state.materialHexColor), Brightness.dark),
                themeMode: themeMode,
                home: (state is AuthenticationAuthenticated)
                    ? const TarePage()
                    : const StartingPage()
              );
            });
          },
        )
    );
  }
}

class TarePage extends StatefulWidget {
  const TarePage({super.key});

  @override
  TarePageState createState() => TarePageState();
}

class TarePageState extends State<TarePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  int _selectedScreenIndex = 0;

  late final List<Widget> _pages = <Widget>[
    RecipesPage(
      isHideBottomNavBar: (isHideBottomNavBar) {
        isHideBottomNavBar
            ? _animationController.forward()
            : _animationController.reverse();
      },
    ),
    MealPlanPage(
      isHideBottomNavBar: (isHideBottomNavBar) {
        isHideBottomNavBar
            ? _animationController.forward()
            : _animationController.reverse();
    }),
    ShoppingListPage(
      isHideBottomNavBar: (isHideBottomNavBar) {
        isHideBottomNavBar
            ? _animationController.forward()
            : _animationController.reverse();
    }),
    const SettingsPage()
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    if (context.read<SettingsCubit>().state.defaultPage == 'plan') {
      _selectedScreenIndex = 1;
    } else if (context.read<SettingsCubit>().state.defaultPage == 'shopping') {
      _selectedScreenIndex = 2;
    }
  }

  void _selectScreen(int index) {
    setState(() {
      _selectedScreenIndex = index;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return MultiBlocListener(
        listeners: [
          BlocListener<MealPlanBloc, MealPlanState>(
              listener: (context, state) {
                if (state is MealPlanError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error),
                      duration: const Duration(seconds: 5),
                    ),
                  );
                } else if (state is MealPlanUnauthorized) {
                  Phoenix.rebirth(context);
                } else if (state is MealPlanCreated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.addedToMealPlan),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              }
          ),
          BlocListener<RecipeBloc, RecipeState>(
              listener: (context, state) {
                if (state is RecipeError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error),
                      duration: const Duration(seconds: 5),
                    ),
                  );
                } else if (state is RecipeUnauthorized) {
                  Phoenix.rebirth(context);
                } else if (state is RecipeProcessing) {
                  String? snackBarText;

                  if (state.processingString == 'updatingRecipe') {
                    snackBarText = AppLocalizations.of(context)!.updatingRecipe;
                  } else if (state.processingString == 'addingIngredientsToShoppingList') {
                    snackBarText = AppLocalizations.of(context)!.addingIngredientsToShoppingList;
                  } else if (state.processingString == 'importingRecipe') {
                    snackBarText = AppLocalizations.of(context)!.importingRecipe;
                  } else if (state.processingString == 'sharingLink') {
                    snackBarText = AppLocalizations.of(context)!.share;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${snackBarText ?? ''} ...'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                } else if (state is RecipeDeleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.removedRecipe),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                } else if (state is RecipeAddedIngredientsToShoppingList) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.shoppingListItemsAdded),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              }
          ),
          BlocListener<ShoppingListBloc, ShoppingListState>(
              listener: (context, state) {
                if (state is ShoppingListError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error),
                      duration: const Duration(seconds: 5),
                    ),
                  );
                } else if (state is ShoppingListUnauthorized) {
                  Phoenix.rebirth(context);
                }
              }
          )
        ],
        child: Scaffold(
            body: IndexedStack(
                index: _selectedScreenIndex,
                children: _pages
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedScreenIndex,
              onDestinationSelected: _selectScreen,
              destinations: [
                NavigationDestination(icon: const Icon(Icons.restaurant_menu_outlined), label: AppLocalizations.of(context)!.recipesTitle),
                NavigationDestination(icon: const Icon(Icons.calendar_today_outlined), label: AppLocalizations.of(context)!.mealPlanTitle),
                NavigationDestination(icon: const Icon(Icons.shopping_cart_outlined), label: AppLocalizations.of(context)!.shoppingListTitle),
                NavigationDestination(icon: const Icon(Icons.settings), label: AppLocalizations.of(context)!.settingsTitle),
              ],
            )
        )
    );
  }
}
