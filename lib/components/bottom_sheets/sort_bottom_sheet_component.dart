import 'package:flutter/material.dart';
import 'package:untare/components/widgets/bottom_sheets/sort_component.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';

Future sortBottomSheet(BuildContext context, Function(String, bool) sortButtonPressed, Map<String, bool> sortMap) {
  return showModalBottomSheet(
    backgroundColor: Colors.transparent,
    useRootNavigator: true,
    context: context,
    builder: (context) => Container(
      decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(10))
      ),
      margin: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 15,
        children: [
          Container(
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                color: (Theme.of(context).brightness.name == 'light') ? Colors.grey[300] : Colors.grey[700]
            ),
            child: Text(
              AppLocalizations.of(context)!.sortBy,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18
              ),
            ),
          ),
          buildSort(context, sortButtonPressed, sortMap)
        ],
      ),
    )
  );
}