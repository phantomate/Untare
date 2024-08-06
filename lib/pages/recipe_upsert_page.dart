// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_chips_input/flutter_chips_input.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:http/http.dart';
import 'package:untare/blocs/recipe/recipe_bloc.dart';
import 'package:untare/blocs/recipe/recipe_event.dart';
import 'package:untare/blocs/recipe/recipe_state.dart';
import 'package:untare/components/dialogs/upsert_recipe_ingredient_dialog.dart';
import 'package:untare/components/form_fields/recipe_type_ahead_form_field.dart';
import 'package:untare/components/loading_component.dart';
import 'package:untare/components/recipes/recipe_image_component.dart';
import 'package:untare/extensions/double_extension.dart';
import 'package:untare/futures/future_api_cache_keywords.dart';
import 'package:untare/models/ingredient.dart';
import 'package:untare/models/keyword.dart';
import 'package:untare/models/recipe.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:untare/models/step.dart';
import 'package:untare/pages/recipe_detail_page.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';
import 'package:path_provider/path_provider.dart';

import '../components/dialogs/upsert_recipe_step_time_dialog.dart';

class RecipeUpsertPage extends StatefulWidget {
  final Recipe? recipe;
  final bool? splitDirections;

  const RecipeUpsertPage({super.key, this.recipe, this.splitDirections});

  @override
  RecipeUpsertPageState createState() => RecipeUpsertPageState();
}

class RecipeUpsertPageState extends State<RecipeUpsertPage> {
  final formKey = GlobalKey<FormBuilderState>();
  Recipe? recipe;
  late RecipeBloc _recipeBloc;
  List<Keyword> keywords = [];

  @override
  void initState() {
    super.initState();
    _recipeBloc = BlocProvider.of<RecipeBloc>(context);
    if (widget.recipe != null && widget.recipe!.id != null) {
      _recipeBloc.add(FetchRecipe(id: widget.recipe!.id!));
    }

    if (widget.splitDirections != null && widget.splitDirections!) {
      splitDirections();
    } else {
      recipe = widget.recipe;
    }

    keywords = (recipe != null) ? recipe!.keywords: [];
  }

  void splitDirections() {
    if (widget.recipe != null && widget.recipe!.steps.isNotEmpty && widget.recipe!.steps.length == 1) {
      List<StepModel> newSteps = [];

      List<String> splitDirectionsStrings = (widget.recipe!.steps.first.instruction != null && widget.recipe!.steps.first.instruction != '')
          ? widget.recipe!.steps.first.instruction!.split("\n\n")
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

        if (i == 0) {
          newSteps.add(widget.recipe!.steps.first.copyWith(instruction: splitInstruction));
        } else {
          newSteps.add(StepModel(ingredients: [], instruction: splitInstruction));
        }
      }

      recipe = widget.recipe!.copyWith(steps: newSteps);
    }
  }

  // Rebuild recipe for upsert
  Recipe rebuildRecipe({List<StepModel>? steps}) {
    formKey.currentState!.save();
    Map<String, dynamic> formBuilderData = formKey.currentState!.value;

    // Create step copy with updated/created ingredient list
    List<StepModel> stepList = [];
    if (recipe != null) {
      stepList = steps ?? recipe!.steps;
    } else {
      stepList = steps ?? [];
    }

    // Reset order, if step order or ingredient order have changed
    for(int i = 0; i < stepList.length; i++) {
      if (stepList[i].order == null) {
        stepList[i] = stepList[i].copyWith(order: i);
      }

      for(int j = 0; j < stepList[i].ingredients.length; j++) {
        stepList[i].ingredients[j] = stepList[i].ingredients[j].copyWith(order: j);
      }
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
      recipe = recipe!.copyWith(name: name, workingTime: workingTime, waitingTime: waitingTime, servings: servings, keywords: keywords, steps: stepList);
    } else {
      recipe = Recipe(name: name, workingTime: workingTime, waitingTime: waitingTime, servings: servings , steps: stepList, keywords: keywords, internal: true);
    }

    return recipe!;
  }

  void _upsertIngredient(Map<String, dynamic> map) {
    List<StepModel> newStepList = (recipe != null && recipe!.steps.isNotEmpty) ? recipe!.steps : [];
    List<Ingredient> ingredientList = (recipe != null && recipe!.steps.isNotEmpty) ? recipe!.steps[map['stepIndex']].ingredients : [];

    // Here we can use the form builder data because we already hydrated the values in the form save methods
    if (['add', 'edit'].contains(map['method'])) {
      if (map['method'] == 'add') {
        Ingredient ingredient = Ingredient(food: map['food'], unit: map['unit'], amount: double.tryParse(map['quantity']) ?? 0, note: map['note']);
        ingredientList.add(ingredient);
      }

      if (map['method'] == 'edit') {
        Ingredient ingredient = recipe!.steps[map['stepIndex']].ingredients[map['ingredientIndex']];
        ingredient = ingredient.copyWith(food: map['food'], unit: map['unit'], amount: double.tryParse(map['quantity']) ?? 0, note: map['note']);
        ingredientList[map['ingredientIndex']] = ingredient;
      }

      newStepList[map['stepIndex']] = recipe!.steps[map['stepIndex']].copyWith(ingredients: ingredientList);

      setState(() {
        recipe = rebuildRecipe(steps: newStepList);
      });
    }
  }

  void _removeIngredientOnDismiss(int dismissIndex, int stepIndex) {
    List<StepModel> newStepList = (recipe != null && recipe!.steps.isNotEmpty) ? recipe!.steps : [];
    List<Ingredient> ingredientList = (recipe != null && recipe!.steps.isNotEmpty) ? recipe!.steps[stepIndex].ingredients : [];

    if (ingredientList[dismissIndex].id != null) {
      ingredientList.removeWhere((element) => element.id == ingredientList[dismissIndex].id);
    } else {
      ingredientList.removeWhere((el){
        Ingredient ing = ingredientList[dismissIndex];
        return (el.amount == ing.amount && el.unit == ing.unit && el.food == ing.food && el.note == ing.note);
      });
    }

    newStepList[stepIndex] = recipe!.steps[stepIndex].copyWith(ingredients: ingredientList);

    setState(() {
      recipe = rebuildRecipe(steps: newStepList);
    });
  }

  void _addStep() {
    List<StepModel> newStepList = (recipe != null && recipe!.steps.isNotEmpty) ? recipe!.steps : [];
    newStepList.add(StepModel(ingredients: []));

    setState(() {
      recipe = rebuildRecipe(steps: newStepList);
    });
  }

  void _removeStep(int stepIndex) {
    List<StepModel> newStepList = (recipe != null && recipe!.steps.isNotEmpty) ? recipe!.steps : [];
    newStepList.removeAt(stepIndex);

    setState(() {
      recipe = rebuildRecipe(steps: newStepList);
    });
  }

  void _upsertTimeToStep(Map<String, dynamic> map) {
    List<StepModel> newStepList = (recipe != null && recipe!.steps.isNotEmpty) ? recipe!.steps : [];
    newStepList[map['stepIndex']] = recipe!.steps[map['stepIndex']].copyWith(time: int.parse(map['stepTime']));

    setState(() {
      recipe = rebuildRecipe(steps: newStepList);
    });
  }

  void _upsertRecipeToStep(int stepIndex, Recipe? stepRecipe) {
    List<StepModel> newStepList = (recipe != null && recipe!.steps.isNotEmpty) ? recipe!.steps : [];
    newStepList[stepIndex] = recipe!.steps[stepIndex].copyWith(stepRecipe: stepRecipe?.id, stepRecipeData: stepRecipe);

    setState(() {
      recipe = rebuildRecipe(steps: newStepList);
    });
  }

  void _editDirections(String? text, int stepIndex) {
    List<StepModel> newStepList = (recipe != null && recipe!.steps.isNotEmpty) ? recipe!.steps : [];

    newStepList[stepIndex] = recipe!.steps[stepIndex].copyWith(instruction: text);

    recipe = rebuildRecipe(steps: newStepList);
  }

  _onItemReorder(int oldIngredientIndex, int oldStepIndex, int newIngredientIndex, int newStepIndex) {
    List<StepModel> newStepList = (recipe != null && recipe!.steps.isNotEmpty) ? recipe!.steps : [];

    // Remove ingredient from old ingredient list and old step
    List<Ingredient> oldIngredientList = (recipe != null && recipe!.steps.isNotEmpty) ? recipe!.steps[oldStepIndex].ingredients : [];
    Ingredient movedIngredient = oldIngredientList.removeAt(oldIngredientIndex);
    newStepList[oldStepIndex] = recipe!.steps[oldStepIndex].copyWith(ingredients: oldIngredientList);

    // Add ingredient to new ingredient list and new step
    List<Ingredient> newIngredientList = (recipe != null && recipe!.steps.isNotEmpty) ? recipe!.steps[newStepIndex].ingredients : [];
    newIngredientList.insert(newIngredientIndex, movedIngredient);
    newStepList[newStepIndex] = recipe!.steps[newStepIndex].copyWith(ingredients: newIngredientList);

    setState(() {
      recipe = rebuildRecipe(steps: newStepList);
    });
  }

  _onListReorder(int oldListIndex, int newListIndex) {
    // We don't use list reorder but it's required
  }

  Future<File?> _downloadImageAsFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName.png';
    final Response response = await get(Uri.parse(url));
    File? file;

    if ([200, 201].contains(response.statusCode)) {
      file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
    }

    return file;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
          body: NestedScrollView(
              headerSliverBuilder: (BuildContext hsbContext, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    leadingWidth: 50,
                    titleSpacing: 0,
                    automaticallyImplyLeading: false,
                    leading: IconButton(
                      iconSize: 30,
                      padding: const EdgeInsets.all(0),
                      onPressed: () => Navigator.pop(hsbContext),
                      splashRadius: 20,
                      icon: const Icon(
                        Icons.chevron_left,
                      ),
                    ),
                    actions: [
                      IconButton(
                        onPressed: () async {
                          formKey.currentState!.save();
                          if (formKey.currentState!.validate()) {
                            Recipe newRecipe = rebuildRecipe();

                            File? image;
                            if (formKey.currentState!.value['image'].first is XFile) {
                              image = File(formKey.currentState!.value['image'].first.path);
                            } else if (newRecipe.image != null) {
                              image = await _downloadImageAsFile(newRecipe.image!, newRecipe.name);
                            }

                            if (widget.recipe != null && widget.recipe!.id != null) {
                              _recipeBloc.add(UpdateRecipe(recipe: newRecipe, image: image));
                            } else {
                              _recipeBloc.add(CreateRecipe(recipe: newRecipe, image: image));
                            }
                          }
                        },
                        icon: const Icon(Icons.save_outlined),
                        splashRadius: 20,
                      )
                    ],
                    title: Text(
                      (widget.recipe != null) ? AppLocalizations.of(context)!.recipeEdit : AppLocalizations.of(context)!.recipeCreate,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18
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
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  padding: const EdgeInsets.only(top: 15, bottom: 10),
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                              padding: const EdgeInsets.only(left: 10),
                              child: FormBuilderImagePicker(
                                name: 'image',
                                initialValue: [
                                  (recipe != null && recipe!.image != null && recipe!.image != '') ? buildRecipeImage(recipe!, BorderRadius.circular(12), 220) : null
                                ],
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide.none
                                    )
                                ),
                                maxImages: 1,
                                iconColor: Colors.grey[400],
                                previewWidth: 166,
                                previewHeight: 140,
                              )
                          ),
                        ),
                        Flexible(
                            child: Container(
                                padding: const EdgeInsets.only(right: 20),
                                child: Column(
                                  children: [
                                    FormBuilderTextField(
                                      name: 'workingTime',
                                      initialValue: (recipe != null) ? recipe!.workingTime.toString() : null,
                                      decoration: InputDecoration(
                                        labelText: AppLocalizations.of(context)!.prepTime,
                                        isDense: true,
                                        contentPadding: const EdgeInsets.all(10),
                                        border: const OutlineInputBorder(),
                                      ),
                                      validator: FormBuilderValidators.compose([
                                        FormBuilderValidators.numeric(),
                                        FormBuilderValidators.min(0)
                                      ]),
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(
                                          fontSize: 15
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    FormBuilderTextField(
                                      name: 'waitingTime',
                                      initialValue: (recipe != null) ? recipe!.waitingTime.toString() : null,
                                      decoration: InputDecoration(
                                        labelText: AppLocalizations.of(context)!.waitingTime,
                                        isDense: true,
                                        contentPadding: const EdgeInsets.all(10),
                                        border: const OutlineInputBorder(),
                                      ),
                                      validator: FormBuilderValidators.compose([
                                        FormBuilderValidators.numeric(),
                                        FormBuilderValidators.min(0)
                                      ]),
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(
                                          fontSize: 15
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    FormBuilderTextField(
                                      name: 'servings',
                                      initialValue: (recipe != null) ? recipe!.servings.toString() : null,
                                      decoration: InputDecoration(
                                        labelText: AppLocalizations.of(context)!.servings,
                                        isDense: true,
                                        contentPadding: const EdgeInsets.all(10),
                                        border: const OutlineInputBorder(),
                                      ),
                                      validator: FormBuilderValidators.compose([
                                        FormBuilderValidators.numeric(),
                                        FormBuilderValidators.min(1)
                                      ]),
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(
                                          fontSize: 15
                                      ),
                                    )
                                  ],
                                )
                            )
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 15, right: 20, bottom: 10, left: 20),
                      child: FormBuilderTextField(
                        name: 'name',
                        initialValue: (recipe != null) ? recipe!.name : null,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.name,
                          isDense: true,
                          contentPadding: const EdgeInsets.all(10),
                          border: const OutlineInputBorder(),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.maxLength(128),
                        ]),
                        style: const TextStyle(
                            fontSize: 15
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 15, right: 20, bottom: 10, left: 20),
                      child: ChipsInput<Keyword>(
                        onChanged: (data) {
                          keywords = data;
                        },
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.keywords,
                          isDense: true,
                          contentPadding: const EdgeInsets.all(10),
                          border: const OutlineInputBorder(),
                        ),
                        initialValue: (recipe != null) ? recipe!.keywords: [],
                        chipBuilder: (context, state, keyword) {
                          return InputChip(
                            key: ObjectKey(keyword),
                            label: Text(keyword.name ?? keyword.label!),
                            onDeleted: () => state.deleteChip(keyword),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          );
                        },
                        suggestionsBoxMaxHeight: 250,
                        suggestionBuilder: (context, state, keyword) {
                          return Card(
                            margin: const EdgeInsets.all(3),
                            elevation: 1.5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                              key: ObjectKey(keyword),
                              title: Text(keyword.name ?? keyword.label!),
                              onTap: () => state.selectSuggestion(keyword),
                            ),
                          );
                        },
                        findSuggestions: (String query) async {
                          List<Keyword> keywords = await getKeywordsFromApiCache(query);
                          bool hideOnEqual = false;
                          for (var keyword in keywords) {
                            String text = keyword.name ?? keyword.label!;
                            if (text.toLowerCase() == query.toLowerCase()) {
                              hideOnEqual = true;
                            }
                          }
                          if (keywords.isEmpty || !hideOnEqual) {
                            keywords.add(Keyword(id: null, name: query, description: ''));
                          }
                          return keywords;
                        },
                      ),
                    ),
                    BlocConsumer<RecipeBloc, RecipeState>(
                        listener: (context, state) {
                          if (state is RecipeUpdated) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context)!.saved),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                            recipe = state.recipe;

                            Navigator.pop(context);
                          } else if (state is RecipeCreated) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context)!.saved),
                                duration: const Duration(seconds: 3),
                              ),
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RecipeDetailPage(recipe: state.recipe)),
                            );
                          }
                        },
                        builder: (context, state) {
                          if (state is RecipeFetched) {
                            if (recipe != null && recipe!.id == state.recipe.id) {
                              recipe = state.recipe;
                              return buildUpsertStepsWidget();
                            }
                          } else if (state is RecipeFetchedFromCache && state.recipe.steps.isNotEmpty) {
                            if (recipe != null && recipe!.id == state.recipe.id) {
                              recipe = state.recipe;
                              return buildUpsertStepsWidget();
                            }
                          } else if (state is RecipeFetchedFromCache && state.recipe.steps.isEmpty) {
                            // If loading from cache but we don't have steps, show loading
                            return buildLoading();
                          } else if (state is RecipeLoading) {
                            return buildLoading();
                          }

                          return buildUpsertStepsWidget();
                        }
                    )
                  ],
                ),
              )
          )
      ),
    );
  }

  Widget buildUpsertStepsWidget() {
    List<Widget> stepWidgetList = [];
    List<StepModel> steps = (recipe != null && recipe!.steps.isNotEmpty) ? recipe!.steps : [];

    List<DragAndDropList> dragAndDropLists = [];
    for (int i = 0; i < steps.length; i++) {
      dragAndDropLists.add(buildStep(steps[i], i));
    }

    stepWidgetList.add(
        DragAndDropLists(
            listPadding: const EdgeInsets.all(0),
            contentsWhenEmpty: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.fromLTRB(20, 15, 10, 0),
              child: Text(AppLocalizations.of(context)!.recipeNoStepsFound),
            ),
            disableScrolling: true,
            lastListTargetSize: 0,
            lastItemTargetHeight: 0,
            children: dragAndDropLists,
            onItemReorder: _onItemReorder,
            onListReorder: _onListReorder
        )
    );

    stepWidgetList.add(
        Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(bottom: 20, top: 20),
            child: Container(
                width: 60,
                alignment: Alignment.center,
                child: Container(
                  height: 30,
                  width: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                  ),
                  child: IconButton(
                    padding: const EdgeInsets.all(0),
                    splashRadius: 18,
                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                    icon: Icon(
                      Icons.add,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      _addStep();
                    },
                  ),
                )
            )
        )
    );

    return Column(children: stepWidgetList);
  }

  DragAndDropList buildStep(StepModel step, int stepIndex) {
    List<Ingredient> ingredients = recipe!.steps[stepIndex].ingredients;

    List<DragAndDropItem> ingredientWidgetList = [];
    for (int j = 0; j < ingredients.length; j++) {
      ingredientWidgetList.add(
          DragAndDropItem(
              child: GestureDetector(
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  upsertRecipeIngredientDialog(context, stepIndex, j, _upsertIngredient, ingredient: ingredients[j]);
                },
                child: buildIngredient(ingredients[j], stepIndex, j),
              )
          )
      );
    }

    return DragAndDropList(
      canDrag: false,
      children: ingredientWidgetList,
      contentsWhenEmpty: Text(AppLocalizations.of(context)!.recipeNoIngredientsPresent, style: const TextStyle(fontStyle: FontStyle.italic)),
      header: Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                        width: 60,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(bottom: 5),
                        child: Container(
                          height: 30,
                          width: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                          ),
                          child: Text((stepIndex+1).toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                        )
                    ),
                    if (step.name != null && step.name != '')
                      Text(
                          '${step.name} ',
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                              fontSize: 15.5
                          )
                      ),
                    if (step.time != null && step.time != 0)
                    Row(
                      children: [
                        Icon(Icons.timer_outlined, size: 15.5, color: Theme.of(context).colorScheme.secondary.withOpacity(0.5)),
                        Text(
                            ' ${step.time} min',
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                                fontSize: 15.5
                            )
                        )
                      ],
                    )
                  ],
                ),
                PopupMenuButton(
                  padding: const EdgeInsets.only(right: 25),
                  icon: const Icon(Icons.more_vert_outlined),
                  splashRadius: 20,
                  elevation: 3,
                  shape: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(8)
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      padding: const EdgeInsets.fromLTRB(15, 5 ,15, 10),
                      height: 18,
                      value: 1,
                      child: Row(
                          children: [
                            const Icon(Icons.timer_outlined),
                            Text(' ${(step.time == null || step.time == 0) ? AppLocalizations.of(context)!.addTime : AppLocalizations.of(context)!.editTime}')
                          ]),
                    ),
                    if (step.stepRecipeData == null)
                      PopupMenuItem(
                        padding: const EdgeInsets.fromLTRB(15, 5 ,15, 10),
                        height: 18,
                        value: 2,
                        child: Row(
                            children: [
                              const Icon(Icons.restaurant_menu_outlined),
                              Text(' ${AppLocalizations.of(context)!.recipesTooltipAddRecipe}')
                            ]),
                      ),
                    PopupMenuItem(
                      padding: const EdgeInsets.fromLTRB(15, 5 ,15, 5),
                      height: 18,
                      value: 3,
                      child: Row(
                        children: [
                          const Icon(Icons.delete_outline, color: Colors.redAccent),
                          Text(
                            AppLocalizations.of(context)!.remove,
                            style: const TextStyle(color: Colors.redAccent),
                          )
                      ]),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 1) {
                      upsertRecipeStepTimeDialog(context, stepIndex, _upsertTimeToStep, stepTime: step.time);
                    } else if (value == 2) {
                      _upsertRecipeToStep(stepIndex, Recipe(name: '', keywords: [], steps: []));
                    } else if (value == 3) {
                      _removeStep(stepIndex);
                    }
                  },
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(left: 30),
              decoration: BoxDecoration(
                  border: Border(
                      left: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 1
                      )
                  )
              ),
              child: ListTile(
                visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                contentPadding: const EdgeInsets.fromLTRB(20, 0, 13, 0),
                title: Text(AppLocalizations.of(context)!.ingredients, style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: IconButton(
                  splashRadius: 20,
                  icon: Icon(
                    Icons.add,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    upsertRecipeIngredientDialog(context, stepIndex, ingredients.length, _upsertIngredient);
                  },
                ),
              ),
            )
          ],
        ),
      ),
      lastTarget: buildDirectionsAndStepRecipe(recipe!.steps[stepIndex], stepIndex),
      leftSide: Container(
        margin: const EdgeInsets.only(left: 30),
        decoration: BoxDecoration(
            border: Border(
                left: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 1
                )
            )
        ),
      ),
    );
  }

  Widget buildIngredient(Ingredient ingredient, int stepIndex, int ingredientIndex) {
    // Build ingredient text layout
    String amount = (ingredient.amount > 0) ? ('${ingredient.amount.toFormattedString()} ') : '';
    String unit = (ingredient.amount > 0 && ingredient.unit != null) ? ('${ingredient.unit!.getUnitName(ingredient.amount)} ') : '';
    String food = (ingredient.food != null) ? ('${ingredient.food!.getFoodName(ingredient.amount)} ') : '';
    String note = (ingredient.note != null && ingredient.note != '') ? ('(${ingredient.note !})') : '';

    return Slidable(
        key: UniqueKey(),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          dismissible: DismissiblePane(
              onDismissed: () {
                _removeIngredientOnDismiss(ingredientIndex, stepIndex);
              }
          ),
          children: [
            SlidableAction(
              autoClose: false,
              flex: 1,
              onPressed: (slideContext) {
                FocusManager.instance.primaryFocus?.unfocus();
                Slidable.of(slideContext)!.dismiss(
                    ResizeRequest(
                        const Duration(milliseconds: 300),
                            () {
                          _removeIngredientOnDismiss(ingredientIndex, stepIndex);
                        }
                    ),
                    duration: const Duration(milliseconds: 300)
                );
              },
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              icon: Icons.delete_outline,
            ),
          ],
        ),
        child: Container(
            margin: const EdgeInsets.only(left: 15, right: 20),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                        width: 0.8
                    )
                )
            ),
            child: ListTile(
              visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
              contentPadding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              title: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: TextStyle(fontSize: 15, color: Theme.of(context).textTheme.bodyMedium!.color),
                  children: [
                    TextSpan(text: amount, style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: unit, style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: food, style: TextStyle(fontWeight: (ingredient.food != null && ingredient.food!.recipe != null) ? FontWeight.bold : FontWeight.w400)),
                    TextSpan(
                      text: note,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                          fontStyle: FontStyle.italic
                      )
                    )
                  ]
                )
              ),
              trailing: const Icon(Icons.drag_handle_outlined),
            )
        )
    );
  }

  Widget buildDirectionsAndStepRecipe(StepModel step, int stepIndex) {
    final formBuilderKey = GlobalKey<FormBuilderState>();

    return Column(
      children: [
        Container(
          constraints: BoxConstraints(maxHeight: 250),
          padding: const EdgeInsets.only(top: 25, right: 20, bottom: 10, left: 15),
          child: TextFormField(
            key: ObjectKey(step.id ?? UniqueKey()),
            initialValue: step.instruction,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.directions,
              contentPadding: const EdgeInsets.all(10),
              border: const OutlineInputBorder(),
            ),
            maxLines: null,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (String? text) => _editDirections(text, stepIndex),
            style: const TextStyle(
                fontSize: 15
            ),
          ),
        ),
        if (step.stepRecipeData != null)
          Builder(
            builder: (BuildContext context) {
              return FormBuilder(
                key: formBuilderKey,
                onChanged: () {
                  formBuilderKey.currentState!.save;
                  if (formBuilderKey.currentState!.validate()) {
                    _upsertRecipeToStep(stepIndex, formBuilderKey.currentState!.fields['recipe${context.hashCode}']!.value);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.only(top: 15, right: 20, bottom: 10, left: 15),
                  child: recipeTypeAheadFormField(step.stepRecipeData, formBuilderKey, context, referer: 'edit'),
                )
              );
            },
          )
      ],
    );
  }
}