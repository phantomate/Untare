import 'package:flutter/material.dart';
import 'package:untare/components/widgets/bottom_sheets/sort_component.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';

Future sortBottomSheet(BuildContext context, Function(String, bool) sortButtonPressed, Map<String, bool> sortMap) {
  return showModalBottomSheet(
      showDragHandle: true,
    useRootNavigator: true,
    context: context,
    builder: (context) => Wrap(
      spacing: 15,
      children: [
        Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
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
  );
}