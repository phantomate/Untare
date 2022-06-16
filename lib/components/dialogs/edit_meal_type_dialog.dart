import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:tare/blocs/meal_plan/meal_plan_bloc.dart';
import 'package:tare/blocs/meal_plan/meal_plan_event.dart';
import 'package:tare/futures/future_api_cache_meal_types.dart';
import 'package:tare/models/meal_type.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';

Future editMealTypeDialog(BuildContext context) async {
  final _formBuilderKey = GlobalKey<FormBuilderState>();
  final MealPlanBloc _mealPlanBloc = BlocProvider.of<MealPlanBloc>(context);
  final List<MealType> mealTypeList = await getMealTypesFromApiCache();
  final List<DropdownMenuItem> mealTypeWidgetList =
  mealTypeList.map((type) => DropdownMenuItem(
    value: type,
    child: Text(type.name),
  )).toList();
  bool isVisible = false;

  return showDialog(context: context, builder: (BuildContext dContext){
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        insetPadding: EdgeInsets.all(20),
        child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: FormBuilder(
                key: _formBuilderKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: StatefulBuilder(
                    builder: (context, setState) {
                      return Wrap(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Text(AppLocalizations.of(context)!.editMealType, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                          ),
                          FormBuilderDropdown(
                            name: 'type',
                            allowClear: true,
                            items: mealTypeWidgetList,
                            decoration: InputDecoration(
                                label: Text(AppLocalizations.of(context)!.mealType)
                            ),
                            validator: FormBuilderValidators.compose(
                                [FormBuilderValidators.required()]
                            ),
                            onChanged: (dynamic value) {
                              if (!isVisible) {
                                setState(() {
                                  isVisible = true;
                                });
                              }
                            },
                          ),
                          Visibility(
                              visible: isVisible,
                              child: Column(
                                children: [
                                  SizedBox(height: 15),
                                  FormBuilderTextField(
                                    name: 'name',
                                    decoration: InputDecoration(
                                        label: Text(AppLocalizations.of(context)!.newCategoryName)
                                    ),
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(),
                                      FormBuilderValidators.max(128),
                                    ]),
                                  )
                                ],
                              )
                          ),
                          SizedBox(height: 15),
                          Container(
                              alignment: Alignment.bottomRight,
                              child: MaterialButton(
                                  color: Theme.of(context).primaryColor,
                                  onPressed: isVisible ? () {
                                    _formBuilderKey.currentState!.save();

                                    if (_formBuilderKey.currentState!.validate()) {
                                      MealType mealType = _formBuilderKey.currentState!.value['type'];
                                      String newName = _formBuilderKey.currentState!.value['name'];

                                      MealType newMealType = mealType.copyWith(name: newName);
                                      _mealPlanBloc.add(UpdateMealType(mealType: newMealType));
                                      Navigator.pop(dContext);
                                    }
                                  } : null,
                                  child: Text(AppLocalizations.of(context)!.edit)
                              )
                          )
                        ],
                      );
                    }
                )
            )
        )
    );
  });
}