import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';

Widget buildSort(BuildContext context, Function(String, bool) sortButtonPressed, Map<String, bool> sortMap) {
  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.only(left: 12, right: 12),
    child: Column(
      children: [
        buildListTile(context, sortButtonPressed, AppLocalizations.of(context)!.sortBySearchRank, 'score', sortMap['score']!),
        buildListTile(context, sortButtonPressed, AppLocalizations.of(context)!.name, 'name', sortMap['name']!),
        buildListTile(context, sortButtonPressed, AppLocalizations.of(context)!.lastCooked, 'lastcooked', sortMap['lastcooked']!),
        buildListTile(context, sortButtonPressed, AppLocalizations.of(context)!.rating, 'rating', sortMap['rating']!),
        buildListTile(context, sortButtonPressed, AppLocalizations.of(context)!.sortByFavorite, 'favorite', sortMap['favorite']!),
        buildListTile(context, sortButtonPressed, AppLocalizations.of(context)!.sortByCreated, 'created_at', sortMap['created_at']!),
      ],
    ),
  );
}

Widget buildListTile(BuildContext context, Function(String, bool) sortButtonPressed, String label, String sortValue, bool isAsc) {
  return ListTile(
    onTap: () {
      sortButtonPressed(sortValue, isAsc);
      Navigator.pop(context);
    },
    title: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontWeight: FontWeight.w400
          ),
        ),
        Icon(
          isAsc ? Icons.arrow_drop_up_outlined : Icons.arrow_drop_down_outlined ,
        )
      ],
    ),
  );
}