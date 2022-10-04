import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';
import 'package:untare/pages/foods_page.dart';
import 'package:untare/pages/units_page.dart';

Future recipesBottomSheet(BuildContext context) {
  return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      context: context,
      builder: (btsContext) => Container(
        decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(10))
        ),
        margin: const EdgeInsets.all(12),
        child: Wrap(
          children: [
            Container(
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                  color: (Theme.of(context).brightness.name == 'light') ? Colors.grey[300] : Colors.grey[700]
              ),
              child: Text(
                AppLocalizations.of(context)!.recipesTitle,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                ),
              ),
            ),
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
      )
  );
}