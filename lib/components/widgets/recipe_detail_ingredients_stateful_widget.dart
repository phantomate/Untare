import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tare/models/ingredient.dart';
import 'package:tare/models/recipe.dart';
import 'package:tare/extensions/double_extension.dart';

class RecipeDetailIngredientsWidget extends StatefulWidget {
  final Recipe recipe;

  RecipeDetailIngredientsWidget({required this.recipe});

  @override
  _RecipeDetailIngredientsWidgetState createState() => _RecipeDetailIngredientsWidgetState();
}

class _RecipeDetailIngredientsWidgetState extends State<RecipeDetailIngredientsWidget> {
  late int servings;
  late int newServings;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    List<TableRow> ingredientsList = [];
    List<dynamic> recipeIngredients = (widget.recipe.steps != null) ? widget.recipe.steps!.first.ingredients : [];
    ingredientsList.addAll(recipeIngredients.map((item) => ingredientComponent(item, servings, newServings)).toList());

    if (ingredientsList.isNotEmpty) {
      return ListView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        children: [
          Container(
            padding: const EdgeInsets.only(left: 15),
            child: Row(
              children: [
                Text('Servings:'),
                IconButton(
                  onPressed: () => {
                    decrement()
                  },
                  icon: Icon(
                    Icons.do_not_disturb_on,
                    color: Colors.black45,
                  ),
                ),
                Text(newServings.toString()),
                IconButton(
                    onPressed: () => {
                      increment()
                    },
                    icon: Icon(
                      Icons.add_circle,
                      color: Colors.black45,
                    )
                )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 0, right: 15, bottom: 15, left: 15),
            child: Table(
              border: TableBorder(
                  horizontalInside: BorderSide(
                      width: 1,
                      color: Colors.grey[300] ?? Colors.grey,
                      style: BorderStyle.solid
                  )
              ),
              children: ingredientsList,
            ),
          )
        ],
      );
    } else {
      return Center(child: Text('No ingredients found'));
    }
  }
}

TableRow ingredientComponent(Ingredient ingredient, int initServing, int newServing) {
  String amount = (ingredient.amount > 0) ? ((ingredient.amount * (((newServing/initServing))*100).ceil()/100).toFormattedString() + ' ') : '';
  String unit = (ingredient.unit != null) ? (ingredient.unit!.name + ' ') : '';
  String food = (ingredient.food != null) ? (ingredient.food!.name + ' ') : '';
  String note = (ingredient.note != null && ingredient.note != '') ? ('(' + ingredient.note! + ')') : '';

  return TableRow(
    children: [
      Container(
        padding: const EdgeInsets.fromLTRB(5, 12, 5, 12),
        child: Wrap(
          children: [
            Text(amount, style: TextStyle(fontWeight: FontWeight.bold)),
            Text(unit, style: TextStyle(fontWeight: FontWeight.bold)),
            Text(food),
            Text(note, style: TextStyle(color: Colors.black45, fontStyle: FontStyle.italic))
          ],
        )
      )
    ],
  );
}