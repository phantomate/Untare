import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:untare/blocs/meal_plan/meal_plan_bloc.dart';
import 'package:untare/blocs/meal_plan/meal_plan_event.dart';
import 'package:untare/components/form_fields/meal_type_type_ahead_form_field.dart';
import 'package:untare/components/form_fields/recipe_type_ahead_form_field.dart';
import 'package:untare/cubits/settings_cubit.dart';
import 'package:untare/futures/future_api_cache_users.dart';
import 'package:untare/models/meal_plan_entry.dart';
import 'package:untare/models/recipe.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';
import 'package:untare/models/user.dart';

Future upsertMealPlanEntryDialog(BuildContext context, {MealPlanEntry? mealPlan, DateTime? date, Recipe? recipe, String? referer}) async {
  final formBuilderKey = GlobalKey<FormBuilderState>();
  MealPlanBloc mealPlanBloc = BlocProvider.of<MealPlanBloc>(context);
  var box = Hive.box('unTaReBox');
  User? loggedInUser = box.get('user');
  List<FormBuilderChipOption> shareOptionList = [];
  List<User> userList = await getUsersFromApiCache();
  List<User> sharedUsers = [];
  final SettingsCubit settingsCubit = context.read<SettingsCubit>();

  for (var element in userList) {
    if (loggedInUser == null || loggedInUser.id != element.id) {
      shareOptionList.add(
          FormBuilderChipOption(
              value: element.id, child: Text(element.username)
          )
      );
    }
  }

  sharedUsers = settingsCubit.state.userServerSetting!.planShare;
  if (mealPlan != null) {
    sharedUsers.addAll(mealPlan.shared);
  }

  return showDialog(context: context, builder: (BuildContext dContext){
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        insetPadding: const EdgeInsets.all(20),
        child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: FormBuilder(
                key: formBuilderKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: StatefulBuilder(
                    builder: (context, setState) {
                      return Wrap(
                        spacing: 15,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Text((mealPlan != null) ? AppLocalizations.of(context)!.mealPlanEntryEdit : AppLocalizations.of(context)!.mealPlanEntryAdd, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                          ),
                          Row(
                            children: [
                              Flexible(
                                  child: FormBuilderDateTimePicker(
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
                                  )
                              ),
                              const SizedBox(width: 15),
                              Flexible(
                                  child: FormBuilderTextField(
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
                                  )
                              )
                            ],
                          ),
                          const SizedBox(height: 15),
                          mealTypeTypeAheadFieldForm((mealPlan != null) ? mealPlan.mealType : null, formBuilderKey, context),
                          const SizedBox(height: 15),
                          recipeTypeAheadFormField((mealPlan != null) ? mealPlan.recipe : recipe, formBuilderKey, context, referer: referer),
                          const SizedBox(height: 15),
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
                          const SizedBox(height: 15),
                          FormBuilderFilterChip (
                            name: 'share',
                            checkmarkColor: Theme.of(context).primaryColor,
                            initialValue: sharedUsers.map((user) => user.id).toList(),
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.shareWith,
                              isDense: true,
                              contentPadding: const EdgeInsets.fromLTRB(10, 10 ,10, 0),
                            ),
                            options: shareOptionList,
                          ),
                          const SizedBox(height: 15),
                          Container(
                              alignment: Alignment.bottomRight,
                              child: MaterialButton(
                                  color: Theme.of(context).primaryColor,
                                  onPressed: () {
                                    formBuilderKey.currentState!.save();
                                    if (formBuilderKey.currentState!.validate()) {
                                      String? title;
                                      if (formBuilderKey.currentState!.value.containsKey('title')) {
                                        title = formBuilderKey.currentState!.value['title'];
                                      }

                                      List<User> newUserList = [];
                                      formBuilderKey.currentState!.value['share'].forEach((id) {
                                        newUserList.add(userList.firstWhere((user) => user.id == id));
                                      });

                                      if (mealPlan != null) {
                                        Recipe? recipe;
                                        if (mealPlan.recipe != null && formBuilderKey.currentState!.value['recipe'].id != mealPlan.recipe!.id) {
                                          recipe = formBuilderKey.currentState!.value['recipe'];
                                        } else if (mealPlan.recipe == null) {
                                          recipe = formBuilderKey.currentState!.value['recipe'];
                                        }

                                        int? servings;
                                        if (int.parse(formBuilderKey.currentState!.value['servings']) != mealPlan.servings) {
                                          servings = int.parse(formBuilderKey.currentState!.value['servings']);
                                        }

                                        String? date;
                                        DateTime tmpDate = formBuilderKey.currentState!.value['date'];
                                        DateTime mealPlanDate = DateTime.parse(mealPlan.date);
                                        if (tmpDate.year != mealPlanDate.year || tmpDate.month != mealPlanDate.month || tmpDate.day != mealPlanDate.day) {
                                          date = DateFormat('yyyy-MM-dd').format(tmpDate);
                                        }

                                        MealPlanEntry newMealPlan = mealPlan.copyWith(
                                            title: (title != mealPlan.title) ? title : null,
                                            recipe: recipe,
                                            servings: servings,
                                            date: date,
                                            mealType: (formBuilderKey.currentState!.value['mealType'].id != mealPlan.mealType) ?  formBuilderKey.currentState!.value['mealType'] : null,
                                            shared: newUserList
                                        );

                                        mealPlanBloc.add(UpdateMealPlan(mealPlan: newMealPlan));
                                      } else {
                                        MealPlanEntry mealPlan = MealPlanEntry(
                                            title: title ?? '',
                                            recipe: formBuilderKey.currentState!.value['recipe'],
                                            servings: int.parse(formBuilderKey.currentState!.value['servings']),
                                            note: '',
                                            date: DateFormat('yyyy-MM-dd').format(formBuilderKey.currentState!.value['date']),
                                            mealType: formBuilderKey.currentState!.value['mealType'],
                                            shared: newUserList
                                        );

                                        mealPlanBloc.add(CreateMealPlan(mealPlan: mealPlan));
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