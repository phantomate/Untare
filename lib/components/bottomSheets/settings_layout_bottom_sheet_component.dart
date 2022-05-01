import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tare/components/widgets/bottomSheets/settings_layout_component.dart';

Future settingsLayoutBottomSheet(BuildContext context) {
  return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      context: context,
      builder: (btsContext) => Container(
        decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(12))
        ),
        margin: const EdgeInsets.all(12),
        height: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 45,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  color: Colors.grey[300]
              ),
              child: Text(
                'Layout recipes',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87
                ),
              ),
            ),
            Expanded(
                child: buildSettingsLayout(context, btsContext)
            )
          ],
        ),
      )
  );
}