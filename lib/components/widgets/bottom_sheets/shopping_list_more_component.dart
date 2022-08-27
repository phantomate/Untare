import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untare/blocs/shopping_list/shopping_list_bloc.dart';
import 'package:untare/blocs/shopping_list/shopping_list_event.dart';
import 'package:untare/components/dialogs/delete_supermarket_category_dialog.dart';
import 'package:untare/components/dialogs/edit_supermarket_category_dialog.dart';
import 'package:untare/cubits/shopping_list_entry_cubit.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';

Widget buildShoppingListMore(BuildContext context, BuildContext btsContext) {
  ShoppingListEntryCubit shoppingListEntryCubit = context.watch<ShoppingListEntryCubit>();
  ShoppingListBloc shoppingListBloc = BlocProvider.of<ShoppingListBloc>(context);

  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.only(left: 12, right: 12),
    child: Column(
      children: [
        ListTile(
          minLeadingWidth: 35,
          onTap: () {
            if (shoppingListEntryCubit.state == 'hide') {
              shoppingListEntryCubit.showCheckedShoppingListEntries();
            } else {
              shoppingListEntryCubit.hideCheckedShoppingListEntries();
            }
            Navigator.pop(btsContext);
          },
          leading: Icon(
            (shoppingListEntryCubit.state == 'hide') ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
          title: Text(
            (shoppingListEntryCubit.state == 'hide') ? AppLocalizations.of(context)!.showCompletedItems : AppLocalizations.of(context)!.hideCompletedItems,
          ),
        ),
        ListTile(
            minLeadingWidth: 35,
            onTap: () {
              shoppingListBloc.add(MarkAllAsCompleted());
              Navigator.pop(btsContext);
            },
            leading: const Icon(Icons.library_add_check_outlined),
            title: Text(AppLocalizations.of(context)!.markAllAsComplete)
        ),
        ListTile(
            minLeadingWidth: 35,
            onTap: () {
              editSupermarketCategoryDialog(context);
              Navigator.pop(btsContext);
            },
            leading: const Icon(Icons.edit_outlined),
            title: Text(AppLocalizations.of(context)!.editSupermarketCategories)
        ),
        ListTile(
            minLeadingWidth: 35,
            onTap: () {
              deleteSupermarketCategoryDialog(context);
              Navigator.pop(btsContext);
            },
            leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
            title: Text(
                AppLocalizations.of(context)!.removeSupermarketCategory,
                style: const TextStyle(
                  color: Colors.redAccent,
                )
            )
        )
      ],
    ),
  );
}