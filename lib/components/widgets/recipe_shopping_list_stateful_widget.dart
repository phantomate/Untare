import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tare/blocs/recipe/recipe_bloc.dart';
import 'package:tare/blocs/recipe/recipe_event.dart';
import 'package:tare/blocs/recipe/recipe_state.dart';
import 'package:tare/blocs/shopping_list/shopping_list_bloc.dart';
import 'package:tare/components/loading_component.dart';
import 'package:tare/constants/colors.dart';
import 'package:tare/models/food.dart';
import 'package:tare/models/ingredient.dart';
import 'package:tare/models/recipe.dart';
import 'package:tare/models/shopping_list_entry.dart';
import 'package:tare/services/api/api_food.dart';
import 'package:tare/services/api/api_shopping_list.dart';

class RecipeShoppingListWidget extends StatefulWidget {
  final Recipe recipe;
  final BuildContext btsContext;

  RecipeShoppingListWidget({required this.recipe, required this.btsContext});

  @override
  _RecipeShoppingListWidgetState createState() => _RecipeShoppingListWidgetState();
}

class _RecipeShoppingListWidgetState extends State<RecipeShoppingListWidget> {
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RecipeBloc, RecipeState>(
      listener: (context, state) {
        if (state is RecipeFetched) {
          if (widget.recipe.id == state.recipe.id) {
            recipe = state.recipe;

            recipeIngredients = (recipe.steps != null) ? recipe.steps!.first.ingredients : [];

            // Get all food ids from this recipe to check if we have this already on our shopping list
            recipeIngredients.forEach((element) {
              if (element.food != null) {
                idShoppingListEntryString += '&id=' + element.food.id.toString();
              }

              // Add ingredient to add list, if its not in stock
              if (element.food == null || !element.food!.onHand) {
                ingredientIdsToAdd.add(element.id);
              }
            });

            getShoppingListEntries();
          }
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
                            Text('Servings:'),
                            IconButton(
                              onPressed: () => {
                                decrement()
                              },
                              icon: Icon(
                                Icons.remove_circle_outline,
                                color: primaryColor,
                              ),
                            ),
                            Text(newServings.toString()),
                            IconButton(
                                onPressed: () => {
                                  increment()
                                },
                                icon: Icon(
                                  Icons.add_circle_outline_outlined,
                                  color: primaryColor,
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
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(10), top: Radius.zero),
                      ),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                        decoration: BoxDecoration(
                            color: Colors.grey[50],
                            border: Border(
                                top: BorderSide(
                                    color: Colors.grey[300]!,
                                    width: 1
                                )
                            )
                        ),
                        child: MaterialButton(
                          color: primaryColor,
                          minWidth: double.maxFinite,
                          child: Text(
                            'Add',
                            style: TextStyle(color: Colors.white),
                          ),
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
          return Center(child: Text('No ingredients found'));
        }
      }
    );
  }

  Widget ingredientComponent(Ingredient ingredient, int initServing, int newServing) {
    String amount = (ingredient.amount > 0) ? ((ingredient.amount * (((newServing/initServing))*100).ceil()/100).toString() + ' ') : '';
    String unit = (ingredient.unit != null) ? (ingredient.unit!.name + ' ') : '';
    String food = (ingredient.food != null) ? (ingredient.food!.name + ' ') : '';
    bool? checkBoxValue = !(ingredient.food != null && ingredient.food!.onHand);
    bool isAlreadyOnShoppingList = false;
    shoppingListEntries.forEach((element) {
      if(element.ingredient == ingredient.id) {
        isAlreadyOnShoppingList = true;
      }
    });

    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1.0
              )
          )
      ),
      child: StatefulBuilder(
        builder: (context, setState) {
          return ListTile(
            dense: true,
            visualDensity: VisualDensity(horizontal: 0, vertical: -4),
            contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            leading: Checkbox(
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
                Text(amount, style: TextStyle(fontWeight: FontWeight.bold)),
                Text(unit, style: TextStyle(fontWeight: FontWeight.bold)),
                Text(food),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isAlreadyOnShoppingList)
                  Tooltip(
                    triggerMode: TooltipTriggerMode.tap,
                    message: 'Is already on your shopping list',
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      size: 18,
                    ),
                  ),
                if (ingredient.food != null)
                IconButton(
                  padding: const EdgeInsets.fromLTRB(0, 6, 0, 8),
                    tooltip: (ingredient.food!.onHand) ? 'Is in stock' : 'Add to stock',
                    onPressed: () {
                      Food newFood = ingredient.food!.copyWith(onHand: !(ingredient.food!.onHand));

                      // Add to add list if we remove it from stock and vice versa
                      if ((ingredient.food!.onHand)) {
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
                      color: (ingredient.food != null && ingredient.food!.onHand) ? primaryColor : null,
                    )
                ),
              ],
            ),
          );
        }),
      );
  }
}