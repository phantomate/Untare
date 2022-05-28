import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:tare/blocs/meal_plan/meal_plan_bloc.dart';
import 'package:tare/blocs/meal_plan/meal_plan_event.dart';
import 'package:tare/components/form_fields/meal_type_type_ahead_form_field.dart';
import 'package:tare/components/form_fields/recipe_type_ahead_form_field.dart';
import 'package:tare/models/meal_plan_entry.dart';
import 'package:tare/models/recipe.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';

Future upsertMealPlanEntryDialog(BuildContext context, {MealPlanEntry? mealPlan, DateTime? date, Recipe? recipe, String? referer}) {
  final _formBuilderKey = GlobalKey<FormBuilderState>();
  MealPlanBloc _mealPlanBloc = BlocProvider.of<MealPlanBloc>(context);

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
                        spacing: 15,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Text((mealPlan != null) ? AppLocalizations.of(context)!.mealPlanEntryEdit : AppLocalizations.of(context)!.mealPlanEntryAdd, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                          ),
                          FormBuilderDateTimePicker(
                            name: 'date',
                            initialValue: (mealPlan != null) ? DateTime.parse(mealPlan.date) : date,
                            enabled: (referer == 'recipe' || referer == 'edit'),
                            inputType: InputType.date,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.date
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required()
                            ]),
                          ),
                          SizedBox(height: 15),
                          mealTypeTypeAheadFieldForm((mealPlan != null) ? mealPlan.mealType : null, _formBuilderKey, context),
                          SizedBox(height: 15),
                          recipeTypeAheadFormField((mealPlan != null) ? mealPlan.recipe : recipe, _formBuilderKey, context, referer: referer),
                          SizedBox(height: 15),
                          FormBuilderTextField(
                            name: 'title',
                            initialValue: (mealPlan != null) ? mealPlan.title : null,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.alternativeTitle,
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.max(64),
                            ]),
                          ),
                          SizedBox(height: 15),
                          FormBuilderTextField(
                            name: 'servings',
                            initialValue: (mealPlan != null) ? mealPlan.servings.toString() : ((recipe != null) ? recipe.servings.toString() : '1'),
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.servings,
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.numeric(),
                              FormBuilderValidators.min(1),
                              FormBuilderValidators.required(),
                              FormBuilderValidators.integer()
                            ]),
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 15),
                          Container(
                              alignment: Alignment.bottomRight,
                              child: MaterialButton(
                                  color: Theme.of(context).primaryColor,
                                  onPressed: () {
                                    _formBuilderKey.currentState!.save();
                                    if (_formBuilderKey.currentState!.validate()) {
                                      String? title;
                                      if (_formBuilderKey.currentState!.value.containsKey('title')) {
                                        title = _formBuilderKey.currentState!.value['title'];
                                      }

                                      if (mealPlan != null) {
                                        Recipe? recipe;
                                        if (mealPlan.recipe != null && _formBuilderKey.currentState!.value['recipe'].id != mealPlan.recipe!.id) {
                                          recipe = _formBuilderKey.currentState!.value['recipe'];
                                        } else if (mealPlan.recipe == null) {
                                          recipe = _formBuilderKey.currentState!.value['recipe'];
                                        }

                                        int? servings;
                                        if (int.parse(_formBuilderKey.currentState!.value['servings']) != mealPlan.servings) {
                                          servings = int.parse(_formBuilderKey.currentState!.value['servings']);
                                        }

                                        String? date;
                                        DateTime tmpDate = _formBuilderKey.currentState!.value['date'];
                                        DateTime mealPlanDate = DateTime.parse(mealPlan.date);
                                        if (tmpDate.year != mealPlanDate.year || tmpDate.month != mealPlanDate.month || tmpDate.day != mealPlanDate.day) {
                                          date = DateFormat('yyyy-MM-dd').format(tmpDate);
                                        }

                                        MealPlanEntry _mealPlan = mealPlan.copyWith(
                                            title: (title != mealPlan.title) ? title : null,
                                            recipe: recipe,
                                            servings: servings,
                                            date: date,
                                            mealType: (_formBuilderKey.currentState!.value['mealType'].id != mealPlan.mealType) ?  _formBuilderKey.currentState!.value['mealType'] : null
                                        );

                                        _mealPlanBloc.add(UpdateMealPlan(mealPlan: _mealPlan));
                                      } else {
                                        MealPlanEntry mealPlan = MealPlanEntry(
                                            title: title ?? '',
                                            recipe: _formBuilderKey.currentState!.value['recipe'],
                                            servings: int.parse(_formBuilderKey.currentState!.value['servings']),
                                            note: '',
                                            date: DateFormat('yyyy-MM-dd').format(_formBuilderKey.currentState!.value['date']),
                                            mealType: _formBuilderKey.currentState!.value['mealType']
                                        );

                                        _mealPlanBloc.add(CreateMealPlan(mealPlan: mealPlan));
                                      }

                                      Navigator.pop(dContext);
                                    }
                                  },
                                  child: Text((mealPlan != null) ? AppLocalizations.of(context)!.edit : AppLocalizations.of(context)!.add)
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