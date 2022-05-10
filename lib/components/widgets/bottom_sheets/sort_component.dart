import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Widget buildSort(BuildContext context, Function(String) sortButtonPressed) {
  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.only(left: 12, right: 12),
    child: Table(
      children: [
        sortTableRow(context, sortButtonPressed, 'Search rank', 'score'),
        sortTableRow(context, sortButtonPressed, 'Name', 'name'),
        sortTableRow(context, sortButtonPressed, 'Last cooked', 'lastcooked'),
        sortTableRow(context, sortButtonPressed, 'Rating', 'rating'),
        sortTableRow(context, sortButtonPressed, 'Favorite', 'favorite'),
        sortTableRow(context, sortButtonPressed, 'Created', 'created_at'),
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
                  color: Colors.black87,
                  fontWeight: FontWeight.w400
              ),
            ),
            Icon(
              isAsc ? Icons.arrow_drop_up_outlined : Icons.arrow_drop_down_outlined ,
              color: Colors.black87,
            )
          ],
        ),
      ),
  );
}