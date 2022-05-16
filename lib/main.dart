import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tare/blocs/meal_plan/meal_plan_bloc.dart';
import 'package:tare/blocs/meal_plan/meal_plan_state.dart';
import 'package:tare/blocs/recipe/recipe_bloc.dart';
import 'package:tare/blocs/recipe/recipe_state.dart';
import 'package:tare/blocs/shopping_list/shopping_list_bloc.dart';
import 'package:tare/blocs/shopping_list/shopping_list_state.dart';
import 'package:tare/constants/colors.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'package:tare/cubits/settings_cubit.dart';
import 'package:tare/cubits/shopping_list_entry_cubit.dart';
import 'package:tare/extensions/theme_extension.dart';
import 'package:tare/models/app_setting.dart';
import 'package:tare/models/user.dart';
import 'package:tare/models/user_setting.dart';
import 'package:tare/pages/meal_plan_page.dart';
import 'package:tare/pages/recipes_page.dart';
import 'package:tare/pages/settings_page.dart';
import 'package:tare/pages/shopping_list_page.dart';
import 'package:tare/pages/starting_page.dart';
import 'package:tare/services/api/api_meal_plan.dart';
import 'package:tare/services/api/api_meal_type.dart';
import 'package:tare/services/api/api_recipe.dart';
import 'package:tare/services/api/api_shopping_list.dart';
import 'package:tare/services/api/api_supermarket_category.dart';
import 'package:tare/services/api/api_user.dart';
import 'package:path_provider/path_provider.dart';


import 'blocs/authentication/authentication_bloc.dart';
import 'blocs/authentication/authentication_event.dart';
import 'blocs/authentication/authentication_state.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(AppSettingAdapter());
  Hive.registerAdapter(UserSettingAdapter());
  await Hive.openBox('hydrated_box');
  final storage = await HydratedStorage.build(storageDirectory: await getTemporaryDirectory());

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_){
    HydratedBlocOverrides.runZoned(
        () => runApp(
            Phoenix(
                child: Tare()
            )
        ),
        storage: storage
    );
  });
}

class Tare extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var box = Hive.box('hydrated_box');

    return MultiBlocProvider(
        providers: [
          BlocProvider<AuthenticationBloc>(
              create: (context) => AuthenticationBloc()..add(AppLoaded())
          ),
          BlocProvider<SettingsCubit>(
              create: (context) {
                SettingsCubit cubit = SettingsCubit(apiUser: ApiUser());
                AppSetting? storedAppSetting = box.get('settings');
                if (storedAppSetting != null) {
                  cubit.changeLayoutTo(storedAppSetting.layout);
                  cubit.changeThemeTo(storedAppSetting.theme);
                  cubit.changeDefaultPageTo(storedAppSetting.defaultPage);
                }
                return cubit;
              }
          ),
          BlocProvider<RecipeBloc>(
            create: (BuildContext context) => RecipeBloc(apiRecipe: ApiRecipe())
          ),
          BlocProvider<MealPlanBloc>(
            create: (BuildContext context) => MealPlanBloc(apiMealPlan: ApiMealPlan(), apiMealType: ApiMealType())
          ),
          BlocProvider<ShoppingListBloc>(
            create: (BuildContext context) => ShoppingListBloc(apiShoppingList: ApiShoppingList(), apiSupermarketCategory: ApiSupermarketCategory())
          ),
          BlocProvider<ShoppingListEntryCubit>(
            create: (BuildContext context) =>ShoppingListEntryCubit()
          )
        ],
        child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            if (state is AuthenticationAuthenticated) {
              return TarePage();
            }
            return StartingPage();
          },
        )
    );
  }
}

class TarePage extends StatefulWidget {
  @override
  _TarePageState createState() => _TarePageState();
}

class _TarePageState extends State<TarePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  int _selectedScreenIndex = 0;

  late List<Widget> _pages = <Widget>[
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
    SettingsPage()
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 200));
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
    SettingsCubit settingsCubit = context.watch<SettingsCubit>();

    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FormBuilderLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('de'),
        Locale('en'),
        Locale('es'),
        Locale('fr'),
        Locale('it'),
      ],
      debugShowCheckedModeBanner: false,
      title: 'Tare App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: (settingsCubit.state.theme == 'light') ? ThemeMode.light : ThemeMode.dark,
      home: MultiBlocListener(
          listeners: [
            BlocListener<MealPlanBloc, MealPlanState>(
                listener: (context, state) {
                  if (state is MealPlanError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.error),
                        duration: Duration(seconds: 8),
                      ),
                    );
                  } else if (state is MealPlanUnauthorized) {
                    Phoenix.rebirth(context);
                  } else if (state is MealPlanCreated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added to meal plan'),
                        duration: Duration(seconds: 3),
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
                      duration: Duration(seconds: 8),
                    ),
                  );
                } else if (state is RecipeUnauthorized) {
                  Phoenix.rebirth(context);
                } else if (state is RecipeDeleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Recipe deleted'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                } else if (state is RecipeAddedIngredientsToShoppingList) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Items added'),
                      duration: Duration(seconds: 3),
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
                        duration: Duration(seconds: 8),
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
              bottomNavigationBar: Container(
                decoration: BoxDecoration(
                  boxShadow:[
                    BoxShadow(
                        color: Colors.black12.withOpacity(0.4), //color of shadow
                        spreadRadius: 0.5, //spread radius
                        blurRadius: 1, // blur radius
                        offset: Offset(0, 0)
                    ),
                  ],
                ),
                child: SizeTransition(
                    sizeFactor: _animationController,
                    axisAlignment: -1.0,
                    child: BottomNavigationBar(
                      type: BottomNavigationBarType.fixed,
                      currentIndex: _selectedScreenIndex,
                      selectedItemColor: primaryColor,
                      unselectedItemColor: Colors.grey,
                      showSelectedLabels: true,
                      showUnselectedLabels: true,
                      onTap: _selectScreen,
                      items: [
                        BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu_outlined), label: 'Recipes'),
                        BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: "Plan"),
                        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'List'),
                        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
                      ],
                    )
                ),
              )
          )
      ),
    );
  }
}
