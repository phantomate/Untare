import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:untare/blocs/food/food_bloc.dart';
import 'package:untare/blocs/food/food_event.dart';
import 'package:untare/blocs/food/food_state.dart';
import 'package:untare/components/dialogs/edit_food_dialog.dart';
import 'package:untare/components/loading_component.dart';
import 'package:untare/models/food.dart';
import 'package:untare/services/api/api_food.dart';
import 'package:untare/services/cache/cache_food_service.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';

class FoodsPage extends StatefulWidget {
  const FoodsPage({super.key});

  @override
  FoodsPageState createState() => FoodsPageState();
}

class FoodsPageState extends State<FoodsPage> {
  late FoodBloc foodBloc;
  int page = 1;
  int pageSize = 100;
  String query = '';
  bool isLastPage = false;
  List<Food> foods = [];
  List<Food> fetchedFoods = [];
  List<Food> cachedFoods = [];
  bool isLoading = false;

  @override
  void initState(){
    super.initState();
  }

  void _fetchMoreFoods() {
    if((foodBloc.state is FoodsFetched || foodBloc.state is FoodsFetchedFromCache) && !isLastPage) {
      page++;
      isLoading = true;
      foodBloc.add(FetchFoods(query: query, page: page, pageSize: pageSize));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.foods),
        elevation: 1.5,
      ),
      body: BlocProvider<FoodBloc>(
          create: (context) {
            foodBloc = FoodBloc(apiFood: ApiFood(), cacheFoodService: CacheFoodService());
            foodBloc.add(FetchFoods(query: query, page: page, pageSize: pageSize));
            isLoading = true;
            return foodBloc;
          },
          child: BlocConsumer<FoodBloc, FoodState>(
            listener: (context, state) {
              if (state is FoodsError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error),
                    duration: const Duration(seconds: 5),
                  ),
                );
              } else if (state is FoodsUnauthorized) {
                Phoenix.rebirth(context);
              } else if (state is FoodsFetched) {
                isLastPage = false;
                fetchedFoods.addAll(state.foods);
                foods = fetchedFoods;

                if (state.foods.isEmpty || state.foods.length < pageSize) {
                  isLastPage = true;
                }
              } else if (state is FoodsFetchedFromCache) {
                if (state.foods.isEmpty || state.foods.length < pageSize) {
                  isLastPage = true;
                }
                isLoading = false;

                cachedFoods.addAll(state.foods);
                foods = cachedFoods;
              } else if (state is FoodDeleted) {
                foods.removeWhere((element) => element.id == state.food.id);
              } else if (state is FoodUpdated) {
                foods[foods.indexWhere((element) => element.id == state.food.id)] = state.food;
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
                            title: Text(foods[index].name),
                            subtitle: ((foods[index].recipeCount != null && foods[index].recipeCount! > 0) ? Text(('${foods[index].recipeCount} ${(foods[index].recipeCount! > 1) ? AppLocalizations.of(context)!.recipesTitle : AppLocalizations.of(context)!.recipe}')) : null),
                            trailing: Wrap(
                              spacing: 0,
                              children: [
                                IconButton(
                                    splashRadius: 20,
                                    onPressed: () {
                                      editFoodDialog(context, foods[index]);
                                    },
                                    icon: const Icon(Icons.edit_outlined, size: 20)
                                ),
                                IconButton(
                                    splashRadius: (foods[index].recipeCount != null && foods[index].recipeCount! == 0) ? 20 : 1,
                                    onPressed: () {
                                      if (foods[index].recipeCount != null && foods[index].recipeCount! == 0) {
                                        showDialog(context: context, builder: (context) {
                                          return AlertDialog(
                                            title: Text(AppLocalizations.of(context)!.removeFood),
                                            content: Text(AppLocalizations.of(context)!.confirmRemoveFood.replaceFirst('%s', foods[index].name)),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    foodBloc.add(DeleteFood(food: foods[index]));
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
                                      }
                                    },
                                    icon: Icon(
                                        Icons.delete_outline,
                                        size: 20,
                                        color: (foods[index].recipeCount != null && foods[index].recipeCount! == 0) ? Colors.redAccent : Theme.of(context).inputDecorationTheme.disabledBorder!.borderSide.color
                                    )
                                ),
                              ],
                            ),
                          ),
                          separatorBuilder: (context, index) => Divider(
                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                            height: 4,
                          ),
                          itemCount: foods.length
                        )
                    ),
                    if (state is FoodsLoading || isLoading)
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