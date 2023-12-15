import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:untare/blocs/unit/unit_bloc.dart';
import 'package:untare/blocs/unit/unit_event.dart';
import 'package:untare/blocs/unit/unit_state.dart';
import 'package:untare/components/dialogs/edit_unit_dialog.dart';
import 'package:untare/components/loading_component.dart';
import 'package:untare/models/unit.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';
import 'package:untare/services/api/api_unit.dart';
import 'package:untare/services/cache/cache_unit_service.dart';

class UnitsPage extends StatefulWidget {
  const UnitsPage({super.key});

  @override
  UnitsPageState createState() => UnitsPageState();
}

class UnitsPageState extends State<UnitsPage> {
  late UnitBloc unitBloc;
  int page = 1;
  int pageSize = 25;
  String query = '';
  bool isLastPage = false;
  List<Unit> units = [];
  List<Unit> fetchedUnits = [];
  List<Unit> cachedUnits = [];

  @override
  void initState(){
    super.initState();
  }

  void _fetchMoreFoods() {
    if((unitBloc.state is UnitsFetched || unitBloc.state is UnitsFetchedFromCache) && !isLastPage) {
      page++;
      unitBloc.add(FetchUnits(query: query, page: page, pageSize: pageSize));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.units),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1.5,
      ),
      body: BlocProvider<UnitBloc>(
          create: (context) {
            unitBloc = UnitBloc(apiUnit: ApiUnit(), cacheUnitService: CacheUnitService());
            unitBloc.add(FetchUnits(query: query, page: page, pageSize: pageSize));
            return unitBloc;
          },
          child: BlocConsumer<UnitBloc, UnitState>(
              listener: (context, state) {
                if (state is UnitsError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error),
                      duration: const Duration(seconds: 5),
                    ),
                  );
                } else if (state is UnitsUnauthorized) {
                  Phoenix.rebirth(context);
                } else if (state is UnitsFetched) {
                  isLastPage = false;
                  fetchedUnits.addAll(state.units);
                  units = fetchedUnits;

                  if (state.units.isEmpty || state.units.length < pageSize) {
                    isLastPage = true;
                  }
                } else if (state is UnitsFetchedFromCache) {
                  if (state.units.isEmpty || state.units.length < pageSize) {
                    isLastPage = true;
                  }

                  cachedUnits.addAll(state.units);
                  units = cachedUnits;
                } else if (state is UnitDeleted) {
                  units.removeWhere((element) => element.id == state.unit.id);
                } else if (state is UnitUpdated) {
                  units[units.indexWhere((element) => element.id == state.unit.id)] = state.unit;
                }
              },
              builder: (context, state) {
                return LazyLoadScrollView(
                  onEndOfPage: () => _fetchMoreFoods(),
                  scrollOffset: 80,
                  child: Column(
                    children: [
                      Flexible(
                          child: ListView.separated(
                              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                              itemBuilder: (context, index) => ListTile(
                                visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                                title: Text(units[index].name),
                                subtitle: ((units[index].recipeCount != null && units[index].recipeCount! > 0) ? Text(('${units[index].recipeCount} ${(units[index].recipeCount! > 1) ? AppLocalizations.of(context)!.recipesTitle : AppLocalizations.of(context)!.recipe}')) : null),
                                trailing: Wrap(
                                  spacing: 0,
                                  children: [
                                    IconButton(
                                        splashRadius: 20,
                                        onPressed: () {
                                          editUnitDialog(context, units[index]);
                                        },
                                        icon: const Icon(Icons.edit_outlined, size: 20)
                                    ),
                                    IconButton(
                                        splashRadius: 20,
                                        onPressed: () {
                                          showDialog(context: context, builder: (context) {
                                            return AlertDialog(
                                              title: Text(AppLocalizations.of(context)!.removeUnit),
                                              content: Text(AppLocalizations.of(context)!.confirmRemoveUnit.replaceFirst('%s', units[index].name)),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {
                                                      unitBloc.add(DeleteUnit(unit: units[index]));
                                                      Navigator.of(context).pop();
                                                    },
                                                    child: Text(AppLocalizations.of(context)!.remove)
                                                ),
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                    child: Text(AppLocalizations.of(context)!.cancel)
                                                )
                                              ],
                                            );
                                          });
                                        },
                                        icon: const Icon(
                                            Icons.delete_outline,
                                            size: 20,
                                            color: Colors.redAccent
                                        )
                                    ),
                                  ],
                                ),
                              ),
                              separatorBuilder: (context, index) => Divider(
                                color: (Theme.of(context).brightness.name == 'light') ? Colors.grey[300]! : Colors.grey[700]!,
                                height: 4,
                              ),
                              itemCount: units.length
                          )
                      ),
                      if (state is UnitsLoading)
                        buildLoading()
                    ],
                  ),
                );
              }
          )
      ),
    );
  }
}