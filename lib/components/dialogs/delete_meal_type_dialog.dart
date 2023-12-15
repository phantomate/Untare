import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:untare/blocs/meal_plan/meal_plan_bloc.dart';
import 'package:untare/blocs/meal_plan/meal_plan_event.dart';
import 'package:untare/futures/future_api_cache_meal_types.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';

import '../../models/meal_type.dart';

Future deleteMealTypeDialog(BuildContext context) async {
  final formBuilderKey = GlobalKey<FormBuilderState>();
  final MealPlanBloc mealPlanBloc = BlocProvider.of<MealPlanBloc>(context);
  final List<MealType> mealTypeList = await getMealTypesFromApiCache();
  final List<DropdownMenuItem> mealTypeWidgetList =
  mealTypeList.map((type) => DropdownMenuItem(
    value: type,
    child: Text(type.name),
  )).toList();

  if (!context.mounted) return;

  return showDialog(context: context, builder: (BuildContext dContext){
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        insetPadding: const EdgeInsets.all(20),
        child: Padding(
            padding: const EdgeInsets.all(15),
            child: FormBuilder(
                key: formBuilderKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: Wrap(
                  spacing: 15,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(AppLocalizations.of(context)!.removeMealType, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                    ),
                    FormBuilderDropdown(
                      name: 'type',
                      items: mealTypeWidgetList,
                      decoration: InputDecoration(
                          label: Text(AppLocalizations.of(context)!.mealType)
                      ),
                      validator: FormBuilderValidators.compose(
                          [FormBuilderValidators.required()]
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                        alignment: Alignment.bottomRight,
                        child: MaterialButton(
                            color: Theme.of(context).primaryColor,
                            onPressed: () {
                              formBuilderKey.currentState!.save();

                              if (formBuilderKey.currentState!.validate()) {
                                mealPlanBloc.add(DeleteMealType(mealType: formBuilderKey.currentState!.value['type']));
                                Navigator.pop(dContext);
                              }
                            },
                            child: Text(AppLocalizations.of(context)!.remove)
                        )
                    )
                  ],
                )
            )
        )
    );
  });
}