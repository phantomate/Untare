import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';
import 'package:untare/components/dialogs/delete_meal_type_dialog.dart';
import 'package:untare/components/dialogs/edit_meal_type_dialog.dart';

Future mealPlanMoreBottomSheet(BuildContext context) {
  return showModalBottomSheet(
      showDragHandle: true,
      useRootNavigator: true,
      context: context,
      builder: (btsContext) => Wrap(
        spacing: 15,
        children: [
          Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 6),
              child: Column(
                  children: [
                    ListTile(
                      minLeadingWidth: 35,
                      onTap: () {
                        Navigator.pop(btsContext);
                        editMealTypeDialog(context);
                      },
                      leading: const Icon(Icons.edit_outlined),
                      title: Text(AppLocalizations.of(context)!.editMealType),
                    ),
                    const Divider(),
                    ListTile(
                      minLeadingWidth: 35,
                      onTap: () {
                        Navigator.pop(btsContext);
                        deleteMealTypeDialog(context);
                      },
                      leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      title: Text(
                        AppLocalizations.of(context)!.removeMealType,
                        style: const TextStyle(color: Colors.redAccent),
                      )
                    )
                  ]
              )
          )
        ],
      ),
  );
}