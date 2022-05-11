import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tare/blocs/shopping_list/shopping_list_bloc.dart';
import 'package:tare/blocs/shopping_list/shopping_list_event.dart';
import 'package:tare/cubits/shopping_list_entry_cubit.dart';

Widget buildShoppingListMore(BuildContext context, BuildContext btsContext) {
  ShoppingListEntryCubit shoppingListEntryCubit = context.watch<ShoppingListEntryCubit>();
  ShoppingListBloc shoppingListBloc = BlocProvider.of<ShoppingListBloc>(context);

  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.only(left: 12, right: 12),
    child: Column(
      children: [
        TextButton.icon(
          onPressed: () {
            if (shoppingListEntryCubit.state == 'hide') {
              shoppingListEntryCubit.showCheckedShoppingListEntries();
            } else {
              shoppingListEntryCubit.hideCheckedShoppingListEntries();
            }
            Navigator.pop(btsContext);
          },
          icon: Icon(
            (shoppingListEntryCubit.state == 'hide') ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: Colors.black87,
          ),
          label: Text(
            (shoppingListEntryCubit.state == 'hide') ? 'Show completed items' : 'Hide completed items',
            style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold
            ),
          ),
        ),
        TextButton.icon(
          onPressed: () {
            shoppingListBloc.add(MarkAllAsCompleted());
            Navigator.pop(btsContext);
          },
          icon: Icon(Icons.library_add_check_outlined, color: Colors.black87),
          label: Text(
            'Mark all as complete',
            style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold
            )
          )
        )
      ],
    ),
  );
}