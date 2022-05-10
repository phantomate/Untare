import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:tare/components/form_fields/food_type_ahead_form_field.dart';
import 'package:tare/components/form_fields/note_text_form_field.dart';
import 'package:tare/components/form_fields/quantity_text_form_field.dart';
import 'package:tare/components/form_fields/unit_type_ahead_form_field.dart';
import 'package:tare/constants/colors.dart';
import 'package:tare/models/ingredient.dart';
import 'package:tare/models/recipe.dart';
import 'package:tare/models/step.dart';
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
    widget.formKey.currentState!.removeInternalFieldValue('quantity$dismissIndex', isSetState: true);
    widget.formKey.currentState!.removeInternalFieldValue('unit$dismissIndex', isSetState: true);
    widget.formKey.currentState!.removeInternalFieldValue('food$dismissIndex', isSetState: true);
    widget.formKey.currentState!.removeInternalFieldValue('note$dismissIndex', isSetState: true);
    widget.formKey.currentState!.save();

    // Remove dynamically created global keys
    formFieldKeyMap.remove('quantity$dismissIndex');
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

                formFieldKeyMap['quantity$index'] = GlobalKey<FormBuilderFieldState>();
                formFieldKeyMap['unit$index'] = GlobalKey<FormBuilderFieldState>();
                formFieldKeyMap['food$index'] = GlobalKey<FormBuilderFieldState>();
                formFieldKeyMap['note$index'] = GlobalKey<FormBuilderFieldState>();

                buildDialog(index);
              },
            ),
          ),
        )
    );

    if (recipe != null && recipe!.steps != null) {
      List<Ingredient> ingredients = recipe!.steps!.first.ingredients;

      for (int i = 0; i < ingredients.length; i++) {
        // Create global keys to provide the state of the dynamically created form fields to the formBuilder
        formFieldKeyMap['quantity$i'] = GlobalKey<FormBuilderFieldState>();
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
                  visualDensity: VisualDensity(horizontal: 0, vertical: -3),
                  contentPadding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
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
              // Save dynamically generated form fields. On save code can be found in form field
              formFieldKeyMap['food$itemIndex']!.currentState!.save();
              formFieldKeyMap['unit$itemIndex']!.currentState!.save();
              formFieldKeyMap['quantity$itemIndex']!.currentState!.save();
              formFieldKeyMap['note$itemIndex']!.currentState!.save();

              widget.formKey.currentState!.save();
              
              // Set index to identify added fields
              widget.formKey.currentState!.setInternalFieldValue('index', itemIndex, isSetState: true);
              setState(() {
                recipe = widget.rebuildRecipe();
              });

              Navigator.pop(slideContext);
            },
          ),
        ],
      ),
    );
  }
}


Widget buildDialogFormFields(Ingredient? ingredient, int itemIndex, formKey, Map<String, GlobalKey> formFieldKeyMap) {
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
                  child: quantityTextFormField((ingredient != null) ? ingredient.amount : null, formKey, index: itemIndex, dynamicKey: formFieldKeyMap['quantity$itemIndex'])
              ),
              SizedBox(width: 10),
              Flexible(
                child: unitTypeAheadFormField((ingredient != null) ? ingredient.unit : null, formKey, index: itemIndex, dynamicKey: formFieldKeyMap['unit$itemIndex'])
              ),
            ],
          ),
          SizedBox(height: 10),
          Flexible(
              child: foodTypeAheadFormField((ingredient != null) ? ingredient.food : null, formKey, index: itemIndex, dynamicKey: formFieldKeyMap['food$itemIndex'])
          ),
          SizedBox(height: 10),
          Flexible(
              child: noteTextFormField((ingredient != null) ? ingredient.note : null, formKey, index: itemIndex, dynamicKey: formFieldKeyMap['note$itemIndex'])
          )
        ],
      )
  );
}