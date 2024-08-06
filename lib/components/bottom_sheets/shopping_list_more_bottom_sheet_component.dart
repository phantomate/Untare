import 'package:flutter/material.dart';
import 'package:untare/components/widgets/bottom_sheets/shopping_list_more_component.dart';

Future shoppingListMoreBottomSheet(BuildContext context) {
  return showModalBottomSheet(
      showDragHandle: true,
      useRootNavigator: true,
      context: context,
      builder: (btsContext) => Wrap(
        spacing: 15,
        children: [
          buildShoppingListMore(context, btsContext)
        ],
      ),
  );
}