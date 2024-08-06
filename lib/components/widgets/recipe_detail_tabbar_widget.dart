import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untare/cubits/settings_cubit.dart';
import 'package:untare/models/ingredient.dart';
import 'package:untare/models/nutritional_value.dart';
import 'package:untare/models/recipe.dart';
import 'package:untare/extensions/double_extension.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';
import 'package:collapsible/collapsible.dart';
import 'package:fraction/fraction.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:untare/pages/recipe_detail_page.dart';

class RecipeDetailTabBarWidget extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailTabBarWidget({super.key, required this.recipe});

  @override
  RecipeDetailTabBarWidgetState createState() => RecipeDetailTabBarWidgetState();
}

class RecipeDetailTabBarWidgetState extends State<RecipeDetailTabBarWidget> {
  late int servings;
  late int newServings;

  @override
  void initState() {
    super.initState();
    servings = widget.recipe.servings ?? 1;
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

  @override
  Widget build(BuildContext context) {

    return TabBarView(
      children: [
        ingredientTabView(),
        directionsTabView(widget.recipe),
        if (widget.recipe.hasNutritionalValues())
          nutritionalValuesTabView(widget.recipe)
      ],
    );
  }

  Widget ingredientTabView() {
    List<Widget> ingredientsList = [];
    List<Ingredient> recipeIngredients = [];

    if (widget.recipe.steps.isNotEmpty) {
      for (var step in widget.recipe.steps) {
        if (step.ingredients.isNotEmpty) {
          for (var ingredient in step.ingredients) {
            recipeIngredients.add(ingredient);
          }
        }
      }
    }

    ingredientsList.addAll(recipeIngredients.map((item) => ingredientComponent(item, servings, newServings, false, context)).toList());

    if (ingredientsList.isNotEmpty) {
      return ListView(
        padding: const EdgeInsets.only(top: 165),
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        children: [
          Container(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              children: [
                Text('${AppLocalizations.of(context)!.servings}:', style: const TextStyle(fontSize: 15)),
                IconButton(
                  onPressed: () => {
                    decrement()
                  },
                  icon: const Icon(
                    Icons.remove_circle_outline,
                  ),
                ),
                Text(newServings.toString()),
                IconButton(
                    onPressed: () => {
                      increment()
                    },
                    icon: const Icon(
                      Icons.add_circle_outline_outlined,
                    )
                )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: ingredientsList,
            ),
          )
        ],
      );
    } else {
      return Center(child: Text(AppLocalizations.of(context)!.recipeNoIngredientsPresent));
    }
  }

  Widget directionsTabView(Recipe recipe) {
    List<Widget> directionsSteps = [];

    if (recipe.steps.isNotEmpty) {
      if (recipe.steps.length > 1) {
        for (int i = 0; i < recipe.steps.length; i++) {
          List<Widget> stepList = [];

          if (recipe.steps[i].ingredients.isNotEmpty) {
            stepList.addAll(recipe.steps[i].ingredients.map((item) => ingredientComponent(item, servings, newServings, true, context)).toList());
          }

          if (recipe.steps[i].instruction != null && recipe.steps[i].instruction!.isNotEmpty) {
            stepList.add(
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 15, 10),
                child: MarkdownBody(
                    data: recipe.steps[i].instruction ?? '',
                    styleSheet:
                    MarkdownStyleSheet(p: const TextStyle(fontSize: 15)))
              )
            );
          }

          if (recipe.steps[i].stepRecipe != null) {
            stepList.add(
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                child: ListTile(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RecipeDetailPage(recipe: (recipe.steps[i].stepRecipeData!)))
                  ),
                  title: Text(
                    recipe.steps[i].stepRecipeData!.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.arrow_forward_outlined),
                ),
              )
            );
          }

          directionsSteps.add(directionStepLayout(context, Column(crossAxisAlignment: CrossAxisAlignment.start, children: stepList), i+1, recipe.steps[i].time, recipe.steps[i].name));
        }

      } else if (recipe.steps.length == 1) {
        List<String> splitDirectionsStrings = (recipe.steps.first.instruction != null && recipe.steps.first.instruction != '')
            ? recipe.steps.first.instruction!.split("\n\n")
            : [];

        if (splitDirectionsStrings.length <= 2) {
          List<String> tmpSplitInstructions = splitDirectionsStrings;
          splitDirectionsStrings = [];
          for(int i = 0; i < tmpSplitInstructions.length; i++) {
            splitDirectionsStrings.addAll(tmpSplitInstructions[i].split("\n"));
          }
        }

        for(int i = 0; i < splitDirectionsStrings.length; i++) {
          final splitInstruction = splitDirectionsStrings[i].replaceAll("\r", "");

          if (!splitInstruction.toLowerCase().contains('imported from: http')) {
            directionsSteps.add(
              directionStepLayout(
                context,
                Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 15, 10),
                    child: MarkdownBody(
                        data: splitInstruction,
                        styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(fontSize: 15)))),
                i+1,
                recipe.steps.first.time,
                recipe.steps.first.name
              )
            );
          }
        }
      }

      return ListView(
        padding: const EdgeInsets.only(top: 175, right: 5, bottom: 0),
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        children: directionsSteps,
      );

    } else {
      return Center(child: Text(AppLocalizations.of(context)!.recipeNoDirectionsPresent));
    }
  }

  Widget directionStepLayout(BuildContext context, Widget widget, int stepNumber, int? stepTime, String? stepName) {
    bool collapsed = false;
    return StatefulBuilder(builder: (context, setState) {
      return Container(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                        width: 48,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.fromLTRB(6, 0, 0, 5),
                        child: Container(
                          height: 30,
                          width: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Theme.of(context).colorScheme.secondary, width: 2),
                          ),
                          child: Text((stepNumber).toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        )
                    ),
                    if (stepName != null && stepName != '')
                      Text(
                          '$stepName ',
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: (Theme.of(context).brightness.name == 'light') ? Colors.black45 : Colors.grey[600]!,
                              fontSize: 15.5
                          )
                      ),
                    if (stepTime != null && stepTime != 0)
                      Row(
                        children: [
                          Icon(Icons.timer_outlined, size: 15.5, color: (Theme.of(context).brightness.name == 'light') ? Colors.black45 : Colors.grey[600]!),
                          Text(
                              ' $stepTime min',
                              style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 15.5)
                          )
                        ],
                      )
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.check),
                  color: (collapsed) ? Theme.of(context).colorScheme.secondary.withOpacity(0.5) : Theme.of(context).colorScheme.secondary,
                  onPressed: () {
                    setState(() {
                      collapsed = !collapsed;
                    });
                  },
                )
              ],
            ),
            Container(
              margin: const EdgeInsets.only(left: 30, bottom: 15),
              decoration: BoxDecoration(
                  border: Border(
                      left: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                          width: 1
                      )
                  )
              ),
              child: Collapsible(
                collapsed: collapsed,
                axis: CollapsibleAxis.vertical,
                alignment: Alignment.topCenter,
                child: widget,
              ),
            )
          ],
        ),
      );
    }
    );
  }

  Widget ingredientComponent(Ingredient ingredient, int initServing, int newServing, bool isDense, BuildContext context) {
    SettingsCubit settingsCubit = context.read<SettingsCubit>();
    bool? useFractions = (settingsCubit.state.userServerSetting!.useFractions == true);

    double rawAmount = ingredient.amount * newServing / initServing;
    String amount = (ingredient.amount > 0) ? ('${rawAmount.toFormattedString()} ') : '';
    if (amount != '' && useFractions == true && (rawAmount % 1) != 0) {
      // If we have a complex decimal we build a "simple" fraction. Otherwise we do the normal one
      if ((((rawAmount - rawAmount.toInt()) * 100) % 5) != 0) {
        // Use this crap because we can't change precision programmatically
        if (rawAmount.toInt() < 1) {
          amount = '${MixedFraction.fromDouble(rawAmount, precision: 1.0e-1).reduce()} ';
        } else if (rawAmount.toInt() < 10) {
          amount = '${MixedFraction.fromDouble(rawAmount, precision: 1.0e-2).reduce()} ';
        } else if (rawAmount.toInt() < 100) {
          amount = '${MixedFraction.fromDouble(rawAmount, precision: 1.0e-3).reduce()} ';
        } else if(rawAmount.toInt() < 1000) {
          amount = '${MixedFraction.fromDouble(rawAmount, precision: 1.0e-4).reduce()} ';
        } else {
          amount = '${MixedFraction.fromDouble(rawAmount, precision: 1.0e-5).reduce()} ';
        }
      } else {
        amount = '${MixedFraction.fromDouble(rawAmount)} ';
      }
    }

    String unit = (ingredient.amount > 0 && ingredient.unit != null) ? ('${ingredient.unit!.getUnitName(rawAmount)} ') : '';
    String food = (ingredient.food != null) ? ('${ingredient.food!.getFoodName(rawAmount)} ') : '';
    String note = (ingredient.note != null && ingredient.note != '') ? ('(${ingredient.note!})') : '';
    Recipe? recipe = (ingredient.food != null && ingredient.food!.recipe != null) ? ingredient.food!.recipe : null;

    return Container(
        margin: const EdgeInsets.only(left: 20, right: 20),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: (Theme.of(context).brightness.name == 'light') ? Colors.grey[300]! : Colors.grey[700]!,
                    width: 0.8
                )
            )
        ),
        child: ListTile(
            dense: isDense,
            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
            contentPadding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
            title: Wrap(
              children: [
                Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(unit, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                if (recipe != null)
                  InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RecipeDetailPage(recipe: recipe)),
                    ),
                    child: Text(
                      food,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                if (recipe == null)
                  Text(food, style: const TextStyle(fontSize: 15)),
                Text(
                    note,
                    style: TextStyle(
                        color: (Theme.of(context).brightness.name == 'light') ? Colors.black45 : Colors.grey[600]!,
                        fontStyle: FontStyle.italic,
                        fontSize: 15
                    )
                )
              ],
            )
        )
    );
  }

  Widget nutritionalValuesTabView(Recipe recipe) {
    List<Widget> nutritionalValuesList = [];

    nutritionalValuesList.add(
        Container(
            margin: const EdgeInsets.only(left: 0, right: 20),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: (Theme.of(context).brightness.name == 'light') ? Colors.grey[300]! : Colors.grey[700]!,
                        width: 0.8
                    )
                )
            ),
            child: ListTile(
                dense: false,
                visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                contentPadding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                title: Text(AppLocalizations.of(context)!.nutritionalValuesPerServing,textAlign: TextAlign.right, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),),
                trailing: SizedBox(
                  width: 100,
                  child: Text(AppLocalizations.of(context)!.nutritionalValuesTotal, textAlign: TextAlign.right, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                )
            )
        )
    );

    nutritionalValuesList.addAll(recipe.nutritionalValues!.map((item) => nutritionalValueComponent(item)).toList());

    return ListView(
        padding: const EdgeInsets.only(top: 165),
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        children: [
          Container(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              children: nutritionalValuesList,
            ),
          )
        ]
    );
  }

  Widget nutritionalValueComponent(NutritionalValue nutritionalValue) {
    double nutritionalPortionValue = (nutritionalValue.totalValue ?? 1)/servings;
    double nutritionalTotalValue = (nutritionalValue.totalValue ?? 1) * newServings / servings ;

    return Container(
        margin: const EdgeInsets.only(left: 0, right: 20),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: (Theme.of(context).brightness.name == 'light') ? Colors.grey[300]! : Colors.grey[700]!,
                    width: 0.8
                )
            )
        ),
        child: ListTile(
            dense: false,
            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
            contentPadding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
            leading: SizedBox(
              width: 120,
              child: Text(nutritionalValue.name ?? '', style: const TextStyle(fontSize: 15)),
            ),
            title: Text(nutritionalPortionValue.toFormattedString(precision: 1), textAlign: TextAlign.right, style: const TextStyle(fontSize: 15),),
            trailing: SizedBox(
              width: 100,
              child: Text('${nutritionalTotalValue.toFormattedString(precision: 1)} ${nutritionalValue.unit ?? ''}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 15)),
            )
        )
    );
  }
}