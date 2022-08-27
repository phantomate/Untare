import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untare/blocs/recipe/recipe_bloc.dart';
import 'package:untare/blocs/recipe/recipe_event.dart';
import 'package:untare/blocs/recipe/recipe_state.dart';
import 'package:untare/blocs/shopping_list/shopping_list_bloc.dart';
import 'package:untare/components/loading_component.dart';
import 'package:untare/models/food.dart';
import 'package:untare/models/ingredient.dart';
import 'package:untare/models/recipe.dart';
import 'package:untare/models/shopping_list_entry.dart';
import 'package:untare/services/api/api_food.dart';
import 'package:untare/services/api/api_shopping_list.dart';

class RecipeShoppingListWidget extends StatefulWidget {
  final Recipe recipe;
  final BuildContext btsContext;

  const RecipeShoppingListWidget({Key? key, required this.recipe, required this.btsContext}) : super(key: key);

  @override
  RecipeShoppingListWidgetState createState() => RecipeShoppingListWidgetState();
}

class RecipeShoppingListWidgetState extends State<RecipeShoppingListWidget> {
  late int servings;
  late int newServings;
  late RecipeBloc recipeBloc;
  late ShoppingListBloc shoppingListBloc;
  late Recipe recipe;
  final ApiShoppingList _apiShoppingList = ApiShoppingList();
  final ApiFood _apiFood = ApiFood();
  List<ShoppingListEntry> shoppingListEntries = [];
  List<dynamic> recipeIngredients = [];
  String idShoppingListEntryString = '';
  List<int> ingredientIdsToAdd = [];


  @override
  void initState() {
    super.initState();
    recipe = widget.recipe;
    shoppingListBloc =  BlocProvider.of<ShoppingListBloc>(context);
    recipeBloc = BlocProvider.of<RecipeBloc>(context);
    recipeBloc.add(FetchRecipe(id: recipe.id!));
    servings = widget.recipe.servings ?? 0;
    newServings = servings;
  }

  void increment() {
    setState(() {
      newServings += 1;
    });
  }

  void decrement() {
    if (newServings > 1) {
      setState(() {
        newServings -= 1;
      });
    }
  }

  void getShoppingListEntries() async {
    List<ShoppingListEntry> entries = await _apiShoppingList.getShoppingListEntries('false', idShoppingListEntryString);
    setState(() {
      shoppingListEntries = entries;
    });
  }

  void updateRecipeIngredients(Ingredient  ingredient) {
    setState(() {
      recipeIngredients[recipeIngredients.indexWhere((element) => element.id == ingredient.id)] = ingredient;
    });
  }

  void prepareIngredientList() {
    recipeIngredients = (recipe.steps.isNotEmpty) ? recipe.steps.first.ingredients : [];

    // Get all food ids from this recipe to check if we have this already on our shopping list
    for (var element in recipeIngredients) {
      if (element.food != null) {
        idShoppingListEntryString += '&id=${element.food.id}';
      }

      // Add ingredient to add list, if its not in stock
      if (element.food == null || !element.food!.onHand) {
        ingredientIdsToAdd.add(element.id);
      }
    }

    getShoppingListEntries();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RecipeBloc, RecipeState>(
      listener: (context, state) {
        if (state is RecipeFetched) {
          if (widget.recipe.id == state.recipe.id) {
            recipe = state.recipe;
            prepareIngredientList();
          }
        } else if (state is RecipeFetchedFromCache) {
          recipe = state.recipe;
          prepareIngredientList();
        }
      },
      builder: (context, state) {
        if (state is RecipeLoading) {
          return buildLoading();
        }

        List<Widget> ingredientsList = [];
        ingredientsList.addAll(recipeIngredients.map((item) => ingredientComponent(item, servings, newServings)).toList());

        if (ingredientsList.isNotEmpty) {
          return Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 100),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 20),
                        child: Row(
                          children: [
                            Text('${AppLocalizations.of(context)!.servings}:'),
                            IconButton(
                              onPressed: () => {
                                decrement()
                              },
                              icon: Icon(
                                Icons.remove_circle_outline,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            Text(newServings.toString()),
                            IconButton(
                                onPressed: () => {
                                  increment()
                                },
                                icon: Icon(
                                  Icons.add_circle_outline_outlined,
                                  color: Theme.of(context).primaryColor,
                                )
                            )
                          ],
                        ),
                      ),
                      Container(
                          padding: const EdgeInsets.only(top: 0, right: 20, bottom: 15, left: 20),
                          child: Column(
                            children: ingredientsList,
                          )
                      ),
                    ],
                  ),
                )
              ),
              Positioned.fill(
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 100,
                      padding: const EdgeInsets.only(bottom: 10),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(10), top: Radius.zero),
                      ),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                        decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(
                                    color: (Theme.of(context).brightness.name == 'light') ? Colors.grey[300]! : Colors.grey[700]!,
                                    width: 1
                                )
                            )
                        ),
                        child: MaterialButton(
                          color: Theme.of(context).primaryColor,
                          minWidth: double.maxFinite,
                          child: Text(AppLocalizations.of(context)!.add),
                          onPressed: () {
                            recipeBloc.add(AddIngredientsToShoppingList(
                                recipeId: recipe.id!,
                                ingredientIds: ingredientIdsToAdd,
                                servings: newServings)
                            );
                            Navigator.pop(widget.btsContext);
                          },
                        ),
                      ),
                    )
                ),
              ),
            ],
          );
        } else {
          return Center(child: Text(AppLocalizations.of(context)!.recipeNoIngredientsPresent));
        }
      }
    );
  }

  Widget ingredientComponent(Ingredient ingredient, int initServing, int newServing) {
    String amount = (ingredient.amount > 0) ? ('${ingredient.amount * (((newServing/initServing))*100).ceil()/100} ') : '';
    String unit = (ingredient.unit != null) ? ('${ingredient.unit!.name} ') : '';
    String food = (ingredient.food != null) ? ('${ingredient.food!.name} ') : '';
    bool? checkBoxValue = !(ingredient.food != null && ingredient.food!.onHand!);
    bool isAlreadyOnShoppingList = false;
    for (var element in shoppingListEntries) {
      if(element.ingredient == ingredient.id) {
        isAlreadyOnShoppingList = true;
      }
    }

    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: (Theme.of(context).brightness.name == 'light') ? Colors.grey[300]! : Colors.grey[700]!,
                  width: 0.8
              )
          )
      ),
      child: StatefulBuilder(
        builder: (context, setState) {
          return ListTile(
            dense: true,
            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
            contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            leading: Checkbox(
                activeColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3)
                ),
                onChanged: (bool? value) {
                  setState(() {
                    checkBoxValue = value;

                    if (value == true) {
                      ingredientIdsToAdd.add(ingredient.id!);
                    } else {
                      ingredientIdsToAdd.removeWhere((element) => element == ingredient.id);
                    }
                  });
                },
                value: checkBoxValue
            ),
            title: Wrap(
              children: [
                Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(unit, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(food),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isAlreadyOnShoppingList)
                  Tooltip(
                    triggerMode: TooltipTriggerMode.tap,
                    message: AppLocalizations.of(context)!.addToShoppingListTooltipAlreadyOnShoppingList,
                    child: const Icon(
                      Icons.shopping_cart_outlined,
                      size: 18,
                    ),
                  ),
                if (ingredient.food != null)
                IconButton(
                  padding: const EdgeInsets.fromLTRB(0, 6, 0, 8),
                    tooltip: (ingredient.food!.onHand!) ? AppLocalizations.of(context)!.addToShoppingListTooltipIsInStock : AppLocalizations.of(context)!.addToShoppingListTooltipAddToStock,
                    onPressed: () {
                      Food newFood = ingredient.food!.copyWith(onHand: !(ingredient.food!.onHand!));

                      // Add to add list if we remove it from stock and vice versa
                      if ((ingredient.food!.onHand!)) {
                        ingredientIdsToAdd.add(ingredient.id!);
                      } else {
                        ingredientIdsToAdd.removeWhere((element) => element == ingredient.id);
                      }

                      _apiFood.patchFoodOnHand(newFood);
                      Ingredient newIngredient = ingredient.copyWith(food: newFood);
                      updateRecipeIngredients(newIngredient);
                    },
                    icon: Icon(
                      Icons.home_outlined,
                      size: 20,
                      color: (ingredient.food != null && ingredient.food!.onHand!) ? Theme.of(context).primaryColor : null,
                    )
                ),
              ],
            ),
          );
        }),
      );
  }
}