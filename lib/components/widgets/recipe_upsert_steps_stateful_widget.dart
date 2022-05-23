import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tare/components/dialogs/upsert_recipe_ingredient_dialog.dart';
import 'package:tare/constants/colors.dart';
import 'package:tare/extensions/double_extension.dart';
import 'package:tare/models/ingredient.dart';
import 'package:tare/models/recipe.dart';
import 'package:tare/models/step.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';

class RecipeUpsertStepsWidget extends StatefulWidget {
  final Recipe? recipe;
  final Function({List<StepModel>? steps}) rebuildRecipe;

  RecipeUpsertStepsWidget({required this.recipe, required this.rebuildRecipe});

  @override
  _RecipeUpsertStepsWidgetState createState() => _RecipeUpsertStepsWidgetState();
}

class _RecipeUpsertStepsWidgetState extends State<RecipeUpsertStepsWidget> {
  late Recipe? recipe;

  @override
  void initState() {
    super.initState();
    recipe = widget.recipe;
  }

  void _upsertIngredient(Map<String, dynamic> map) {
    List<StepModel> newStepList = (recipe != null && recipe!.steps.isNotEmpty) ? recipe!.steps : [];
    List<Ingredient> ingredientList = (recipe != null && recipe!.steps.isNotEmpty) ? recipe!.steps[map['stepIndex']].ingredients : [];

    // Here we can use the form builder data because we already hydrated the values in the form save methods
    if (['add', 'edit'].contains(map['method'])) {
      if (map['method'] == 'add') {
        Ingredient ingredient = Ingredient(food: map['food'], unit: map['unit'], amount: double.tryParse(map['quantity']) ?? 0, note: map['note'], order: 0);
        ingredientList.add(ingredient);
      }

      if (map['method'] == 'edit') {
        Ingredient ingredient = recipe!.steps[map['stepIndex']].ingredients[map['ingredientIndex']];
        ingredient = ingredient.copyWith(food: map['food'], unit: map['unit'], amount: double.tryParse(map['quantity']) ?? 0, note: map['note']);
        ingredientList[map['ingredientIndex']] = ingredient;
      }

      newStepList[map['stepIndex']] = recipe!.steps[map['stepIndex']].copyWith(ingredients: ingredientList);

      setState(() {
        recipe = widget.rebuildRecipe(steps: newStepList);
      });
    }
  }

  void _removeIngredientOnDismiss(int dismissIndex, int stepIndex) {
    List<StepModel> newStepList = (recipe != null && recipe!.steps.isNotEmpty) ? recipe!.steps : [];
    List<Ingredient> ingredientList = (recipe != null && recipe!.steps.isNotEmpty) ? recipe!.steps[stepIndex].ingredients : [];

    ingredientList.removeWhere((element) => element.id == ingredientList[dismissIndex].id);

    newStepList[stepIndex] = recipe!.steps[stepIndex].copyWith(ingredients: ingredientList);

    setState(() {
      recipe = widget.rebuildRecipe(steps: newStepList);
    });
  }

  void _addStep() {
    List<StepModel> newStepList = (recipe != null && recipe!.steps.isNotEmpty) ? recipe!.steps : [];
    newStepList.add(StepModel(ingredients: []));

    setState(() {
      recipe = widget.rebuildRecipe(steps: newStepList);
    });
  }

  void _editDirections(String? text, int stepIndex) {
    List<StepModel> newStepList = (recipe != null && recipe!.steps.isNotEmpty) ? recipe!.steps : [];

    newStepList[stepIndex] = recipe!.steps[stepIndex].copyWith(instruction: text);

    setState(() {
      recipe = widget.rebuildRecipe(steps: newStepList);
    });
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
      recipe = widget.rebuildRecipe(steps: newStepList);
    });
  }

  _onListReorder(int oldListIndex, int newListIndex) {
    // We don't use list reorder but it's required
  }

  @override
  Widget build(BuildContext context) {
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
              child: Text('No steps found - go and add one'),
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
                border: Border.all(color: primaryColor, width: 2),
              ),
              child: IconButton(
                padding: const EdgeInsets.all(0),
                splashRadius: 18,
                visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                icon: Icon(
                  Icons.add,
                  color: primaryColor,
                ),
                onPressed: () => _addStep(),
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
      contentsWhenEmpty: Text('No ingredients set', style: TextStyle(fontStyle: FontStyle.italic)),
      header: Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    border: Border.all(color: primaryColor, width: 2),
                  ),
                  child: Text((stepIndex+1).toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)),
                )
            ),
            Container(
              margin: const EdgeInsets.only(left: 30),
              decoration: BoxDecoration(
                  border: Border(
                      left: BorderSide(
                          color: primaryColor,
                          width: 1
                      )
                  )
              ),
              child: ListTile(
                visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                contentPadding: const EdgeInsets.fromLTRB(20, 0, 13, 0),
                title: Text('Ingredients', style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: IconButton(
                  splashRadius: 20,
                  icon: Icon(
                    Icons.add,
                    color: primaryColor,
                  ),
                  onPressed: () {
                    upsertRecipeIngredientDialog(context, stepIndex, ingredients.length, _upsertIngredient);
                  },
                ),
              ),
            )
          ],
        ),
      ),
      lastTarget: buildDirections(recipe!.steps[stepIndex].instruction, stepIndex),
      leftSide: Container(
        margin: const EdgeInsets.only(left: 30),
        decoration: BoxDecoration(
            border: Border(
                left: BorderSide(
                    color: primaryColor,
                    width: 1
                )
            )
        ),
      ),
    );
  }

  Widget buildIngredient(Ingredient ingredient, int stepIndex, int ingredientIndex) {
    // Build ingredient text layout
    String amount = (ingredient.amount > 0) ? (ingredient.amount.toFormattedString() + ' ') : '';
    String unit = (ingredient.unit != null) ? (ingredient.unit!.name + ' ') : '';
    String food = (ingredient.food != null) ? (ingredient.food!.name + ' ') : '';
    String note = (ingredient.note != null && ingredient.note != '') ? ('(' + ingredient.note !+ ')') : '';

    return Slidable(
        key: UniqueKey(),
        endActionPane: ActionPane(
          motion: ScrollMotion(),
          children: [
            SlidableAction(
              autoClose: false,
              flex: 1,
              onPressed: (slideContext) {
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
          dismissible: DismissiblePane(
              onDismissed: () {
                _removeIngredientOnDismiss(ingredientIndex, stepIndex);
              }
          ),
        ),
        child: Container(
            margin: const EdgeInsets.only(left: 15, right: 20),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: Colors.grey[200]!,
                        width: 1.0
                    )
                )
            ),
            child: ListTile(
                visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                contentPadding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                title: Wrap(
                  children: [
                    Text(amount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(unit, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(food, style: TextStyle(fontSize: 15)),
                    Text(note, style: TextStyle(color: Colors.black45, fontStyle: FontStyle.italic, fontSize: 15))
                  ],
                ),
              trailing: Icon(Icons.drag_handle_outlined),
            )
        )
    );
  }

  Widget buildDirections(String? directions, int stepIndex) {
    return Container(
      padding: const EdgeInsets.only(top: 25, right: 20, bottom: 10, left: 15),
      child: TextFormField(
        initialValue: directions,
        decoration: InputDecoration(
          labelText: 'Directions',
          isDense: true,
          contentPadding: const EdgeInsets.all(10),
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.multiline,
        maxLines: null,
        minLines: null,
        onChanged: (String? text) => _editDirections(text, stepIndex),
        style: TextStyle(
          fontSize: 15
        ),
      ),
    );
  }
}