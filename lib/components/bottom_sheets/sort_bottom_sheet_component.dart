import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:tare/components/widgets/bottom_sheets/sort_component.dart';

Future sortBottomSheet(BuildContext context, Function(String) sortButtonPressed) {
  return showMaterialModalBottomSheet(
    backgroundColor: Colors.transparent,
    useRootNavigator: true,
    duration: Duration(milliseconds: 300),
    context: context,
    builder: (context) => Container(
      decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(10))
      ),
      margin: const EdgeInsets.all(12),
      height: 350,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 45,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                color: Colors.grey[300]
            ),
            child: Text(
              'Sort by',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87
              ),
            ),
          ),
          Expanded(
              child: buildSort(context, sortButtonPressed)
          )
        ],
      ),
    )
  );
}