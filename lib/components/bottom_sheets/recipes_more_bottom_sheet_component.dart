import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';
import 'package:untare/pages/foods_page.dart';
import 'package:untare/pages/units_page.dart';

Future recipesBottomSheet(BuildContext context) {
  return showModalBottomSheet(
      showDragHandle: true,
      useRootNavigator: true,
      context: context,
      builder: (btsContext) => Wrap(
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: Column(
              children: [
                ListTile(
                  minLeadingWidth: 35,
                  onTap: () {
                    Navigator.pop(btsContext);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FoodsPage()),
                    );
                  },
                  leading: const Icon(Icons.edit_note_outlined),
                  title: Text(AppLocalizations.of(context)!.manageFoods),
                ),
                ListTile(
                    minLeadingWidth: 35,
                    onTap: () {
                      Navigator.pop(btsContext);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const UnitsPage()),
                      );
                    },
                    leading: const Icon(Icons.edit_note_outlined),
                    title: Text(AppLocalizations.of(context)!.manageUnits)
                )
              ],
            ),
          )
        ],
      ),
  );
}