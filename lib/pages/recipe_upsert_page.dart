import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:tare/blocs/recipe/recipe_bloc.dart';
import 'package:tare/blocs/recipe/recipe_event.dart';
import 'package:tare/blocs/recipe/recipe_state.dart';
import 'package:tare/components/loading_component.dart';
import 'package:tare/components/recipes/recipe_image_component.dart';
import 'package:tare/components/widgets/recipe_upsert_ingredients_stateful_widget.dart';
import 'package:tare/constants/colors.dart';
import 'package:tare/models/food.dart';
import 'package:tare/models/ingredient.dart';
import 'package:tare/models/recipe.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:tare/models/step.dart';
import 'package:tare/models/unit.dart';
import 'package:tare/pages/recipe_detail_page.dart';
import 'package:tare/services/api/api_recipe.dart';

class RecipeUpsertPage extends StatefulWidget {
  final Recipe? recipe;

  RecipeUpsertPage({this.recipe});

  @override
  _RecipeUpsertPageState createState() => _RecipeUpsertPageState();
}

class _RecipeUpsertPageState extends State<RecipeUpsertPage> {
  final formKey = GlobalKey<FormBuilderState>();
  Recipe? recipe;
  late RecipeBloc _recipeBloc;
  ApiRecipe _apiRecipe = ApiRecipe();

  @override
  void initState() {
    super.initState();
    _recipeBloc = BlocProvider.of<RecipeBloc>(context);
    if (widget.recipe != null && widget.recipe!.steps == null) {
      _recipeBloc.add(FetchRecipe(id: widget.recipe!.id!));
    }
    recipe = widget.recipe;
  }

  // Rebuild recipe for upsert
  Recipe rebuildRecipe() {
    formKey.currentState!.save();
    Map<String, dynamic> formBuilderData = formKey.currentState!.value;

    // @todo update image
    if (formBuilderData.containsKey('image')) {

    }

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
      // Here we can use the form builder data because we already hydrated the values in the form save methods
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

      // If the the form builder doesn't contain a dynamically generated field, it wasn't changed
      if (formBuilderData.containsKey('unit$i')) {
        unit = formBuilderData['unit$i'];
      }
      if (formBuilderData.containsKey('food$i')) {
        food = formBuilderData['food$i'];
      }
      if (formBuilderData.containsKey('quantity$i')) {
        amount = double.tryParse(formBuilderData['quantity$i']) ?? 0;
      }
      if (formBuilderData.containsKey('note$i')) {
        note = formBuilderData['note$i'];
      }

      // Create ingredient with updated values and pass it into the ingredient list
      if (ingredient != null) {
        ingredient = ingredient.copyWith(food: food, unit: unit, amount: amount, note: note);
      } else {
        ingredient = Ingredient(food: food, unit: unit, amount: amount ?? 0, note: note ?? '', order: 0);
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
      body: NestedScrollView(
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
                  IconButton(
                    onPressed: () {
                      formKey.currentState!.save();
                      if (formKey.currentState!.validate()) {
                        if (widget.recipe != null) {
                          _recipeBloc.add(UpdateRecipe(recipe: rebuildRecipe()));
                        } else {
                          _recipeBloc.add(CreateRecipe(recipe: rebuildRecipe()));
                        }
                      }
                    },
                    icon: Icon(Icons.save_outlined, color: primaryColor),
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
              child: ListView(
                padding: const EdgeInsets.only(top: 15, bottom: 10),
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                            padding: const EdgeInsets.only(left: 4),
                            child: FormBuilderImagePicker(
                              name: 'image',
                              initialValue: [
                                (recipe != null) ? buildRecipeImage(recipe!, BorderRadius.circular(12), 220) : null
                              ],
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none
                                  )
                              ),
                              maxImages: 1,
                              iconColor: Colors.grey[400],
                              previewWidth: 170,
                              previewHeight: 140,
                            )
                        ),
                      ),
                      Flexible(
                          child: Container(
                              padding: const EdgeInsets.only(right: 15),
                              child: Column(
                                children: [
                                  FormBuilderTextField(
                                    name: 'workingTime',
                                    initialValue: (recipe != null) ? recipe!.workingTime.toString() : null,
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
                                  ),
                                  SizedBox(height: 10),
                                  FormBuilderTextField(
                                    name: 'waitingTime',
                                    initialValue: (recipe != null) ? recipe!.waitingTime.toString() : null,
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
                                  ),
                                  SizedBox(height: 10),
                                  FormBuilderTextField(
                                    name: 'servings',
                                    initialValue: (recipe != null) ? recipe!.servings.toString() : null,
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
                                ],
                              )
                          )
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 15, right: 15, bottom: 10, left: 15),
                    child: FormBuilderTextField(
                      name: 'name',
                      initialValue: (recipe != null) ? recipe!.name : null,
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
                  BlocConsumer<RecipeBloc, RecipeState>(
                      listener: (context, state) {
                        if (state is RecipeUpdated) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Saved'),
                              duration: Duration(seconds: 3),
                            ),
                          );
                          recipe = state.recipe;

                          Navigator.pop(context);
                        } else if (state is RecipeCreated) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Saved'),
                              duration: Duration(seconds: 3),
                            ),
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RecipeDetailPage(recipe: state.recipe)),
                          );
                        }
                      },
                      builder: (context, state) {
                        if (state is RecipeLoading) {
                          return buildLoading();
                        } else if (state is RecipeFetched) {
                          recipe = state.recipe;
                        }
                        return Column(
                          children: [
                            RecipeUpsertIngredientsWidget(recipe: recipe, formKey: formKey, rebuildRecipe: rebuildRecipe),
                            Container(
                              padding: const EdgeInsets.only(top: 35, right: 15, bottom: 35, left: 15),
                              child: FormBuilderTextField(
                                name: 'instruction',
                                initialValue: (recipe != null && recipe!.steps != null) ? recipe!.steps.first.instruction : null,
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
                                minLines: (recipe == null || recipe!.steps == null || recipe!.steps.first.instruction == null || recipe!.steps.first.instruction == '') ? 1 : 10,
                                maxLines: 20,
                              ),
                            ),
                          ],
                        );
                      }
                  )
                ],
              )
          )
      )
    );
  }
}