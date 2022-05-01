import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:tare/cubits/recipe_layout_cubit.dart';
import 'package:tare/pages/recipes_page.dart';
import 'package:tare/pages/starting_page.dart';


import 'blocs/authentication/authentication_bloc.dart';
import 'blocs/authentication/authentication_event.dart';
import 'blocs/authentication/authentication_state.dart';

void main() async{
  await Hive.initFlutter();
  await Hive.openBox('appBox');

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_){
    runApp(
        Phoenix(
            child: Tare()
        )
    );
  });
}

class Tare extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var box = Hive.box('appBox');

    return MultiBlocProvider(
        providers: [
          BlocProvider<AuthenticationBloc>(
              create: (context) {
                return AuthenticationBloc()..add(AppLoaded());
              }
          ),
          BlocProvider<RecipeLayoutCubit>(
              create: (context) {
                RecipeLayoutCubit cubit = RecipeLayoutCubit();
                cubit.initLayout(box.get('layout'));
                return cubit;
              }
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
    )
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 200));
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
          body: IndexedStack(
              index: _selectedScreenIndex,
              children: _pages
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow:[
                BoxShadow(
                    color: Colors.black12.withOpacity(0.45), //color of shadow
                    spreadRadius: 0.5, //spread radius
                    blurRadius: 1.5, // blur radius
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
                  selectedItemColor: Colors.blue,
                  unselectedItemColor: Colors.grey,
                  showSelectedLabels: true,
                  showUnselectedLabels: true,
                  onTap: _selectScreen,
                  items: [
                    BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu_outlined), label: 'Recipes'),
                    BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: "Plan"),
                    BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'List'),
                  ],
                )
            ),
          )
      ),
    );
  }
}
