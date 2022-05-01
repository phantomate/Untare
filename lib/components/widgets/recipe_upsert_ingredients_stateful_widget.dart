import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:tare/constants/colors.dart';
import 'package:tare/models/food.dart';
import 'package:tare/models/ingredient.dart';
import 'package:tare/models/recipe.dart';
import 'package:tare/models/step.dart';
import 'package:tare/models/unit.dart';
import 'package:tare/services/api/api_food.dart';
import 'package:tare/services/api/api_unit.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class RecipeUpsertIngredientsWidget extends StatefulWidget {
  final Recipe? recipe;
  final GlobalKey<FormBuilderState> formKey;
  final Function() rebuildRecipe;

  RecipeUpsertIngredientsWidget({required this.recipe, required this.formKey, required this.rebuildRecipe});

  @override
  _RecipeUpsertIngredientsWidgetState createState() => _RecipeUpsertIngredientsWidgetState();
}

class _RecipeUpsertIngredientsWidgetState extends State<RecipeUpsertIngredientsWidget> {
  late Recipe? recipe;
  Map<String, GlobalKey<FormBuilderFieldState>> formFieldKeyMap = {};
  
  @override
  void initState() {
    super.initState();
    recipe = widget.recipe;
  }

  void removeIngredientOnDismiss(int dismissIndex) {
    List<Ingredient> ingredientList = [];
    for (int i = 0; i < recipe!.steps.first.ingredients.length; i++) {
      if (i != dismissIndex) {
        ingredientList.add(recipe!.steps.first.ingredients[i]);
      }
    }

    List<StepModel> stepList = [];
    stepList.add(recipe!.steps.first.copyWith(ingredients: ingredientList));

    setState(() {
      recipe = recipe!.copyWith(steps: stepList);
    });

    // Remove entries from form when dismissing
    widget.formKey.currentState!.removeInternalFieldValue('amount$dismissIndex', isSetState: true);
    widget.formKey.currentState!.removeInternalFieldValue('unit$dismissIndex', isSetState: true);
    widget.formKey.currentState!.removeInternalFieldValue('food$dismissIndex', isSetState: true);
    widget.formKey.currentState!.removeInternalFieldValue('note$dismissIndex', isSetState: true);
    widget.formKey.currentState!.save();

    // Remove dynamically created global keys
    formFieldKeyMap.remove('amount$dismissIndex');
    formFieldKeyMap.remove('unit$dismissIndex');
    formFieldKeyMap.remove('food$dismissIndex');
    formFieldKeyMap.remove('note$dismissIndex');
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> ingredientWidgetList = [];

    ingredientWidgetList.add(
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(top: 20),
          child: ListTile(
            leading: Text('Ingredients', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            trailing: IconButton(
              icon: Icon(
                Icons.add_circle_outline_outlined,
                color: primaryColor,
              ),
              onPressed: () {
                int index = 0;
                if (recipe != null) {
                  index = recipe!.steps.first.ingredients.length;
                }

                formFieldKeyMap['amount$index'] = GlobalKey<FormBuilderFieldState>();
                formFieldKeyMap['unit$index'] = GlobalKey<FormBuilderFieldState>();
                formFieldKeyMap['food$index'] = GlobalKey<FormBuilderFieldState>();
                formFieldKeyMap['note$index'] = GlobalKey<FormBuilderFieldState>();

                buildDialog(index);
              },
            ),
          ),
        )
    );

    if (recipe != null) {
      List<Ingredient> ingredients = recipe!.steps!.first.ingredients;

      for (int i = 0; i < ingredients.length; i++) {
        // Create global keys to provide the state of the dynamically created form fields to the formBuilder
        formFieldKeyMap['amount$i'] = GlobalKey<FormBuilderFieldState>();
        formFieldKeyMap['unit$i'] = GlobalKey<FormBuilderFieldState>();
        formFieldKeyMap['food$i'] = GlobalKey<FormBuilderFieldState>();
        formFieldKeyMap['note$i'] = GlobalKey<FormBuilderFieldState>();

        // Build ingredient text layout
        String amount = (ingredients[i].amount > 0) ? (ingredients[i].amount.toString() + ' ') : '';
        String unit = (ingredients[i].unit != null) ? (ingredients[i].unit!.name + ' ') : '';
        String food = (ingredients[i].food != null) ? (ingredients[i].food!.name + ' ') : '';
        String note = (ingredients[i].note != null && ingredients[i].note != '') ? ('(' + ingredients[i].note !+ ')') : '';

        ingredientWidgetList.add(
          Slidable(
            key: UniqueKey(),
            endActionPane: ActionPane(
              motion: ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) => {
                    buildDialog(i, ingredient: ingredients[i])
                  },
                  backgroundColor: Colors.grey[400]!,
                  foregroundColor: Colors.white,
                  icon: Icons.edit_outlined,
                ),
                SlidableAction(
                  autoClose: false,
                  flex: 1,
                  onPressed: (slideContext) {
                    Slidable.of(slideContext)!.dismiss(
                        ResizeRequest(
                          const Duration(milliseconds: 300),
                          () {
                            removeIngredientOnDismiss(i);
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
                  removeIngredientOnDismiss(i);
                }
              ),
            ),
            child: Container(
              margin: const EdgeInsets.only(left: 15, right: 15),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: Colors.grey[200]!,
                          width: 1.0
                      )
                  )
              ),
              child: ListTile(
                  dense: true,
                  visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                  contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                  title: Wrap(
                    children: [Text(amount, style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(unit, style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(food),
                      Text(note, style: TextStyle(color: Colors.black45, fontStyle: FontStyle.italic))],
                  )
              )
            )
          )
        );
      }
    }

    return Column(children: ingredientWidgetList);
  }

  Future buildDialog(int itemIndex, {Ingredient? ingredient}) {
    return showPlatformDialog(
      context: context,
      builder: (slideContext) => BasicDialogAlert(
        title: (ingredient != null) ? Text('Edit ingredient') : Text('Create ingredient'),
        content: buildDialogFormFields(ingredient, itemIndex, widget.formKey, formFieldKeyMap),
        actions: <Widget>[
          BasicDialogAction(
            title: Text("Cancel"),
            onPressed: () {
              Navigator.pop(slideContext);
            },
          ),
          BasicDialogAction(
            title: Text("OK"),
            onPressed: () {
              // Set form field values from dynamically added form field (this is stupid but it works)
              widget.formKey.currentState!.setInternalFieldValue('amount$itemIndex', formFieldKeyMap['amount$itemIndex']!.currentState!.value, isSetState: true);
              widget.formKey.currentState!.setInternalFieldValue('unit$itemIndex', formFieldKeyMap['unit$itemIndex']!.currentState!.value, isSetState: true);
              widget.formKey.currentState!.setInternalFieldValue('food$itemIndex', formFieldKeyMap['food$itemIndex']!.currentState!.value, isSetState: true);
              widget.formKey.currentState!.setInternalFieldValue('note$itemIndex', formFieldKeyMap['note$itemIndex']!.currentState!.value, isSetState: true);

              widget.formKey.currentState!.save();
              // Do own validation, because the package validation doesn't work on dynamically generated fields
              if (formFieldKeyMap['food$itemIndex']!.currentState!.value == null) {
                formFieldKeyMap['food$itemIndex']!.currentState!.invalidate('');
              } else if (formFieldKeyMap['amount$itemIndex']!.currentState!.value != null &&
                  double.tryParse(formFieldKeyMap['amount$itemIndex']!.currentState!.value) == null) {
                formFieldKeyMap['amount$itemIndex']!.currentState!.invalidate('');
              } else {
                // Set index to identify added fields
                widget.formKey.currentState!.setInternalFieldValue('index', itemIndex, isSetState: true);
                setState(() {
                  recipe = widget.rebuildRecipe();
                });

                Navigator.pop(slideContext);
              }
            },
          ),
        ],
      ),
    );
  }
}


Widget buildDialogFormFields(Ingredient? ingredient, int itemIndex, formKey, Map<String, GlobalKey> formFieldKeyMap) {
  final ApiUnit _apiUnit = ApiUnit();
  final ApiFood _apiFood = ApiFood();

  return Container(
      width: 350,
      constraints: BoxConstraints(
        maxHeight: 180,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                  width: 90,
                  child: FormBuilderTextField(
                    key: formFieldKeyMap['amount$itemIndex'],
                    name: 'amount$itemIndex',
                    initialValue: ingredient?.amount.toString(),
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      labelStyle: TextStyle(
                        color: Colors.black26,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.all(10),
                      border: OutlineInputBorder(),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.numeric()
                    ]),
                    keyboardType: TextInputType.number,
                  )
              ),
              SizedBox(width: 10),
              Flexible(
                child: FormBuilderTypeAhead<Unit>(
                  name: 'unit$itemIndex',
                  key: formFieldKeyMap['unit$itemIndex'],
                  initialValue: ingredient?.unit,
                  selectionToTextTransformer: (unit) => unit.name,
                  decoration: const InputDecoration(
                    labelText: 'Unit',
                    labelStyle: TextStyle(
                      color: Colors.black26,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.all(10),
                    border: OutlineInputBorder(),
                  ),
                  itemBuilder: (context, unit) {
                    return ListTile(title: Text(unit.name));
                  },
                  suggestionsCallback: (query) async {
                    List<Unit> units = await _apiUnit.getUnits(query, 1, 25);
                    if (units.isEmpty) {
                      units.add(Unit(id: null, name: query, description: ''));
                    }
                    return units;
                  },
                  hideOnEmpty: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Flexible(
              child: FormBuilderTypeAhead<Food>(
                name: 'food$itemIndex',
                key: formFieldKeyMap['food$itemIndex'],
                initialValue: ingredient?.food,
                selectionToTextTransformer: (food) => food.name,
                decoration: const InputDecoration(
                  labelText: 'Food',
                  labelStyle: TextStyle(
                    color: Colors.black26,
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.all(10),
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required()
                ]),
                itemBuilder: (context, food) {
                  return ListTile(title: Text(food.name));
                },
                suggestionsCallback: (query) async {
                  List<Food> foods = await _apiFood.getFoods(query, 1, 25);
                  if (foods.isEmpty) {
                    foods.add(Food(id: null, name: query, description: ''));
                  }
                  return foods;
                },
                hideOnEmpty: true,
              )
          ),
          SizedBox(height: 10),
          Flexible(
              child: FormBuilderTextField(
                name: 'note$itemIndex',
                key: formFieldKeyMap['note$itemIndex'],
                initialValue: ingredient?.note,
                decoration: InputDecoration(
                    labelText: 'Note',
                    labelStyle: TextStyle(
                      color: Colors.black26,
                    ),
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: const EdgeInsets.all(10)
                ),
              )
          )
        ],
      )
  );
}