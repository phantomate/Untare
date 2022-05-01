import 'package:flutter/material.dart';
import 'package:tare/components/widgets/bottomSheets/sort_component.dart';

Future sortBottomSheet(BuildContext context, Function(String) sortButtonPressed) {
  return showModalBottomSheet(
    backgroundColor: Colors.transparent,
    useRootNavigator: true,
    context: context,
    builder: (context) => Container(
      decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(12))
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
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
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