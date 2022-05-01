import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:tare/cubits/recipe_layout_cubit.dart';

Widget buildSettingsLayout(BuildContext context, BuildContext btsContext) {
  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.only(left: 12, right: 12),
    child: ListView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      children: [
        TextButton(
          onPressed: () {
            context.read<RecipeLayoutCubit>().changeLayoutToList();
            Navigator.pop(btsContext);
          },
          child: Text(
            'List',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            context.read<RecipeLayoutCubit>().changeLayoutToCard();
            Navigator.pop(btsContext);
          },
          child: Text(
            'Card',
            style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold
            ),
          ),
        )
      ],
    ),
  );
}