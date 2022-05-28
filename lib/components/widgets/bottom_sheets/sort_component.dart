import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';

Widget buildSort(BuildContext context, Function(String) sortButtonPressed) {
  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.only(left: 12, right: 12),
    child: Table(
      children: [
        sortTableRow(context, sortButtonPressed, AppLocalizations.of(context)!.sortBySearchRank, 'score'),
        sortTableRow(context, sortButtonPressed, AppLocalizations.of(context)!.name, 'name'),
        sortTableRow(context, sortButtonPressed, AppLocalizations.of(context)!.lastCooked, 'lastcooked'),
        sortTableRow(context, sortButtonPressed, AppLocalizations.of(context)!.rating, 'rating'),
        sortTableRow(context, sortButtonPressed, AppLocalizations.of(context)!.sortByFavorite, 'favorite'),
        sortTableRow(context, sortButtonPressed, AppLocalizations.of(context)!.sortByCreated, 'created_at'),
      ],
    ),
  );
}

TableRow sortTableRow(BuildContext context, Function(String) sortButtonPressed, String label, String sortValue) {
  return TableRow(
      children: [
        sortTableCell(context, sortButtonPressed, label, sortValue, true),
        sortTableCell(context, sortButtonPressed, label, '-' + sortValue, false),
      ],
  );
}

TableCell sortTableCell(BuildContext context, Function(String) sortButtonPressed, String label, String sortValue, bool isAsc) {
  return TableCell(
      child: TextButton(
        onPressed: () {
          sortButtonPressed(sortValue);
          Navigator.pop(context);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                  fontWeight: FontWeight.w400
              ),
            ),
            Icon(
              isAsc ? Icons.arrow_drop_up_outlined : Icons.arrow_drop_down_outlined ,
            )
          ],
        ),
      ),
  );
}