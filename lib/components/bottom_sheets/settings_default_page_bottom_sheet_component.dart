import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tare/cubits/settings_cubit.dart';

Future settingsDefaultPageBottomSheet(BuildContext context) {
  return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      context: context,
      builder: (btsContext) => Container(
        decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(10))
        ),
        margin: const EdgeInsets.all(12),
        child: Wrap(
          children: [
            Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  color: Colors.grey[300]
              ),
              child: Text(
                'Default page',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(left: 12, right: 12),
              child: Column(
                children: [
                  TextButton(
                    onPressed: () {
                      context.read<SettingsCubit>().changeDefaultPageTo('plan');
                      Navigator.pop(btsContext);
                    },
                    child: Text('Meal plan'),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<SettingsCubit>().changeDefaultPageTo('recipes');
                      Navigator.pop(btsContext);
                    },
                    child: Text('Recipes'),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<SettingsCubit>().changeDefaultPageTo('shopping');
                      Navigator.pop(btsContext);
                    },
                    child: Text('Shopping list'),
                  ),
                ],
              ),
            )
          ],
        ),
      )
  );
}