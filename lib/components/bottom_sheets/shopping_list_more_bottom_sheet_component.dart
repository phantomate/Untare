import 'package:flutter/material.dart';
import 'package:untare/components/widgets/bottom_sheets/shopping_list_more_component.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';

Future shoppingListMoreBottomSheet(BuildContext context) {
  return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      context: context,
      builder: (btsContext) => Container(
        decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(10))
        ),
        child: Wrap(
          spacing: 15,
          children: [
            Container(
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Text(
                AppLocalizations.of(context)!.shoppingListTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                ),
              ),
            ),
            buildShoppingListMore(context, btsContext)
          ],
        ),
      )
  );
}