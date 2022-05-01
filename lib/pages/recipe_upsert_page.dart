import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:tare/blocs/recipe/recipe_bloc.dart';
import 'package:tare/blocs/recipe/recipe_event.dart';
import 'package:tare/blocs/recipe/recipe_state.dart';
import 'package:tare/components/loading_component.dart';
import 'package:tare/components/recipes/recipe_image_component.dart';
import 'package:tare/components/widgets/recipe_upsert_ingredients_stateful_widget.dart';
import 'package:tare/models/food.dart';
import 'package:tare/models/ingredient.dart';
import 'package:tare/models/recipe.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:tare/models/step.dart';
import 'package:tare/models/unit.dart';
import 'package:tare/services/api/api_recipe.dart';

class RecipeUpsertPage extends StatelessWidget {
  final Recipe? recipe;
  RecipeUpsertPage({this.recipe});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RecipeBloc>(
        create: (BuildContext context) =>
            RecipeBloc(apiRecipe: ApiRecipe()),
        child: RecipeUpsert(recipe: this.recipe)
    );
  }
}

class RecipeUpsert extends StatefulWidget {
  final Recipe? recipe;

  RecipeUpsert({this.recipe});

  @override
  _RecipeUpsertState createState() => _RecipeUpsertState();
}

class _RecipeUpsertState extends State<RecipeUpsert> {
  final formKey = GlobalKey<FormBuilderState>();
  Recipe? recipe;
  late RecipeBloc _recipeBloc;

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      _recipeBloc = BlocProvider.of<RecipeBloc>(context);
      _recipeBloc.add(FetchRecipe(id: widget.recipe!.id!));
    }
  }

  // Rebuild recipe for upsert
  Recipe rebuildRecipe() {
    formKey.currentState!.save();
    Map<String, dynamic> formBuilderData = formKey.currentState!.value;
    // Build food list
    List<Ingredient> ingredientList = [];

    // If we have an index, we changed the ingredients and maybe added new ones
    int ingredientAmount = (recipe != null) ? recipe!.steps.first.ingredients.length : 0;
    if (formBuilderData.containsKey('index')) {
      if ((formBuilderData['index'] + 1) > ingredientAmount) {
        ingredientAmount = formBuilderData['index'] + 1;
      }
    }

    for (int i = 0; i < ingredientAmount; i++) {
      Ingredient? ingredient;
      Unit? unit;
      Food? food;
      double? amount;
      String? note;
      if (recipe != null && recipe!.steps.first.ingredients.asMap().containsKey(i)) {
        ingredient = recipe!.steps.first.ingredients[i];
        unit = recipe!.steps.first.ingredients[i].unit;
        food = recipe!.steps.first.ingredients[i].food;
        amount = recipe!.steps.first.ingredients[i].amount;
        note = recipe!.steps.first.ingredients[i].note;
      }

      // Overwrite unit, if changed in form
      if (unit != null && formBuilderData.containsKey('unit$i')) {
        if (formBuilderData['unit$i'] != null && unit.id != formBuilderData['unit$i'].id) {
          unit = Unit(id: formBuilderData['unit$i'].id, name: formBuilderData['unit$i'].name, description: formBuilderData['unit$i'].description);
        } else if (formBuilderData['unit$i'] == null) {
          unit = null;
        }
      } else if (unit == null && formBuilderData.containsKey('unit$i') && formBuilderData['unit$i'] != null) {
        unit = Unit(id: formBuilderData['unit$i'].id, name: formBuilderData['unit$i'].name, description: formBuilderData['unit$i'].description);
      }

      // Overwrite food, if changed in form
      if (food != null && formBuilderData.containsKey('food$i')) {
        if (formBuilderData['food$i'] != null && food.id != formBuilderData['food$i'].id) {
          food = Food(id: formBuilderData['food$i'].id, name: formBuilderData['food$i'].name, description: formBuilderData['food$i'].description);
        } else if (formBuilderData['food$i'] == null) {
          food = null;
        }
      } else if (food == null && formBuilderData.containsKey('food$i') && formBuilderData['food$i'] != null) {
        food = Food(id: formBuilderData['food$i'].id, name: formBuilderData['food$i'].name, description: formBuilderData['food$i'].description);
      }

      // Overwrite amount, if changed in form
      if (formBuilderData.containsKey('amount$i') && amount != formBuilderData['amount$i']) {
        amount = (!["", null].contains(formBuilderData['amount$i'])) ? double.parse(formBuilderData['amount$i']) : 0;
      }

      // Overwrite note, if changed in form
      if (formBuilderData.containsKey('note$i') && amount != formBuilderData['note$i']) {
        note = formBuilderData['note$i'] ?? '';
      }

      // Create ingredient with updated values and pass it into the ingredient list
      if (ingredient != null) {
        ingredient = ingredient.copyWith(food: food, unit: unit, amount: amount, note: note);
      } else {
        ingredient = Ingredient(food: food, unit: unit, amount: amount ?? 1, note: note ?? '', order: 0);
      }

      ingredientList.add(ingredient);
    }

    // Create step copy with updated/created ingredient list
    List<StepModel> stepList = [];
    String instruction = (recipe != null) ? recipe!.steps.first.instruction : '';
    if (formBuilderData.containsKey('instruction') && instruction != formBuilderData['instruction']) {
      instruction = formBuilderData['instruction'] ?? '';
    }
    if (recipe != null) {
      stepList.add(recipe!.steps.first.copyWith(ingredients: ingredientList, instruction: instruction));
    } else {
      stepList.add(StepModel(ingredients: ingredientList, instruction: instruction));
    }

    // Update recipe name, if changed in form
    String name = (recipe != null) ? recipe!.name : '';
    if (formBuilderData.containsKey('name') && name != formBuilderData['name']) {
      name = formBuilderData['name'] ?? '';
    }

    // Update working time, if changed in form
    int? workingTime = (recipe != null) ? recipe!.workingTime : 0;
    if (formBuilderData.containsKey('workingTime') && workingTime != formBuilderData['workingTime']) {
      workingTime = (!["", null].contains(formBuilderData['workingTime'])) ? int.parse(formBuilderData['workingTime']) : 0;
    }

    // Update waiting time, if changed in form
    int? waitingTime = (recipe != null) ? recipe!.waitingTime : 0;
    if (formBuilderData.containsKey('waitingTime') && waitingTime != formBuilderData['waitingTime']) {
      waitingTime = (!["", null].contains(formBuilderData['waitingTime'])) ? int.parse(formBuilderData['waitingTime']) : 0;
    }

    // Update servings, if changed in form
    int? servings = (recipe != null) ? recipe!.servings : 1;
    if (formBuilderData.containsKey('servings') && servings != formBuilderData['servings']) {
      servings = (!["", null].contains(formBuilderData['servings'])) ? int.parse(formBuilderData['servings']) : 1;
    }

    if (recipe != null) {
      return recipe!.copyWith(name: name, workingTime: workingTime, waitingTime: waitingTime, servings: servings , steps: stepList);
    }
    return Recipe(name: name, workingTime: workingTime, waitingTime: waitingTime, servings: servings , steps: stepList, keywords: [], internal: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<RecipeBloc, RecipeState>(
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
            } else if (state is RecipeUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Saved'),
                  duration: Duration(seconds: 5),
                ),
              );

              Navigator.pop(context);
            }
          },
          builder: (context, state) {
            if (state is RecipeLoading) {
              return buildLoading();
            } else if (state is RecipeFetched) {
              if (recipe == null) {
                recipe = state.recipe;
              }
            }

            return NestedScrollView(
                headerSliverBuilder: (BuildContext hsbContext, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      leadingWidth: 50,
                      titleSpacing: 0,
                      automaticallyImplyLeading: false,
                      iconTheme: const IconThemeData(color: Colors.black87),
                      leading: IconButton(
                        iconSize: 30,
                        padding: const EdgeInsets.all(0),
                        onPressed: () => Navigator.pop(hsbContext),
                        splashRadius: 20,
                        icon: Icon(
                          Icons.chevron_left,
                        ),
                      ),
                      actions: [
                        TextButton.icon(
                            onPressed: () {
                              formKey.currentState!.save();
                              if (formKey.currentState!.validate()) {
                                _recipeBloc.add(UpdateRecipe(recipe: rebuildRecipe()));
                              }
                            },
                            icon: Icon(Icons.save_outlined, color: Colors.green),
                            label: Text('Save', style: TextStyle(color: Colors.green))
                        )
                      ],
                      title: Text(
                        (widget.recipe != null) ? 'Edit recipe' : 'Create recipe',
                        style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      elevation: 1.5,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      pinned: true,
                    )
                  ];
                },
                body: FormBuilder(
                    key: formKey,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: buildFormWidgetList(recipe, formKey, rebuildRecipe)
                )
            );
          }
      )
    );
  }
}

Widget buildFormWidgetList(Recipe? recipe, formKey, Function() rebuildRecipe) {
  return ListView(
    children: [
      Container(
        padding: const EdgeInsets.only(top: 15, right: 15, bottom: 10, left: 15),
        child: buildRecipeImage(recipe, BorderRadius.circular(12), 220),
      ),
      Container(
        padding: const EdgeInsets.only(top: 10, right: 15, bottom: 10, left: 15),
        child: FormBuilderTextField(
          name: 'name',
          initialValue: (recipe != null) ? recipe.name : null,
          decoration: InputDecoration(
            labelText: 'Name',
            labelStyle: TextStyle(
              color: Colors.black26,
            ),
            isDense: true,
            contentPadding: const EdgeInsets.all(10),
            border: OutlineInputBorder(),
          ),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
            FormBuilderValidators.max(128),
          ]),
        ),
      ),
      Container(
        padding: const EdgeInsets.only(top: 10, right: 15, bottom: 10, left: 15),
        child: Row(
          children: [
            Flexible(
                child: FormBuilderTextField(
                  name: 'workingTime',
                  initialValue: (recipe != null) ? recipe.workingTime.toString() : null,
                  decoration: InputDecoration(
                    labelText: 'Prep Time',
                    labelStyle: TextStyle(
                      color: Colors.black26,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.all(10),
                    border: OutlineInputBorder(),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.numeric(),
                    FormBuilderValidators.min(0)
                  ]),
                  keyboardType: TextInputType.number,
                )
            ),
            SizedBox(width: 10),
            Flexible(
                child: FormBuilderTextField(
                  name: 'waitingTime',
                  initialValue: (recipe != null) ? recipe.waitingTime.toString() : null,
                  decoration: InputDecoration(
                    labelText: 'Waiting time',
                    labelStyle: TextStyle(
                      color: Colors.black26,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.all(10),
                    border: OutlineInputBorder(),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.numeric(),
                    FormBuilderValidators.min(0)
                  ]),
                  keyboardType: TextInputType.number,
                )
            ),
            SizedBox(width: 10),
            Flexible(
                child: FormBuilderTextField(
                  name: 'servings',
                  initialValue: (recipe != null) ? recipe.servings.toString() : null,
                  decoration: InputDecoration(
                    labelText: 'Servings',
                    labelStyle: TextStyle(
                      color: Colors.black26,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.all(10),
                    border: OutlineInputBorder(),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.numeric(),
                    FormBuilderValidators.min(1)
                  ]),
                  keyboardType: TextInputType.number,
                )
            ),
          ],
        ),
      ),
      RecipeUpsertIngredientsWidget(recipe: recipe, formKey: formKey, rebuildRecipe: rebuildRecipe),
      Container(
        padding: const EdgeInsets.only(top: 35, right: 15, bottom: 35, left: 15),
        child: FormBuilderTextField(
          name: 'instruction',
          initialValue: (recipe != null) ? recipe.steps.first.instruction : null,
          decoration: InputDecoration(
            labelText: 'Directions',
            labelStyle: TextStyle(
              color: Colors.black26,
            ),
            isDense: true,
            contentPadding: const EdgeInsets.all(10),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.multiline,
          minLines: (recipe == null || recipe.steps.first.instruction == null || recipe.steps.first.instruction == '') ? 1 : 10,
          maxLines: 20,
        ),
      ),
    ],
  );
}