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
  final locale = AppLocalizations.supportedLocales.where((element) =>
  element.toLanguageTag() == AppLocalizations.of(context)!.localeName
  );

  for (var element in userList) {
    if (loggedInUser == null || loggedInUser.id != element.id) {
      shareOptionList.add(
          FormBuilderChipOption(
              value: element.id, child: Text(element.username)
          )
      );
    }
  }

  if (!context.mounted) return;

  final SettingsCubit settingsCubit = context.read<SettingsCubit>();
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
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: FormBuilderDateRangePicker(
                              name: 'date',
                              initialValue: DateTimeRange(
                                  start: (date != null) ? date : ((mealPlan != null && mealPlan.fromDate != null) ? DateTime.parse(mealPlan.fromDate!) : DateTime.now()),
                                  end: (date != null) ? date : ((mealPlan != null && mealPlan.toDate != null) ? DateTime.parse(mealPlan.toDate!) : DateTime.now())
                              ),
                              firstDate: DateTime(2015),
                              lastDate: DateTime(2040),
                              format: DateFormat('dd.MM.yy'),
                              enabled: (referer == 'recipe' || referer == 'edit' || referer == 'meal-plan'),
                              locale: locale.isNotEmpty ? locale.first : const Locale('en'),
                              decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!.date
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required()
                              ]),
                            ),
                          ),
                          Row(
                            children: [
                              Flexible(
                                  child:  FormBuilderTextField(
                                    name: 'title',
                                    initialValue: (mealPlan != null) ? mealPlan.title : null,
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)!.alternativeTitle,
                                    ),
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.max(64),
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
                                        if (mealPlan.recipe != null && formBuilderKey.currentState!.value['recipe${context.hashCode}'].id != mealPlan.recipe!.id) {
                                          recipe = formBuilderKey.currentState!.value['recipe${context.hashCode}'];
                                        } else if (mealPlan.recipe == null) {
                                          recipe = formBuilderKey.currentState!.value['recipe${context.hashCode}'];
                                        }

                                        int? servings;
                                        if (int.parse(formBuilderKey.currentState!.value['servings']) != mealPlan.servings) {
                                          servings = int.parse(formBuilderKey.currentState!.value['servings']);
                                        }

                                        String? fromDate;
                                        String? toDate;
                                        DateTimeRange tmpDateTimeRange = formBuilderKey.currentState!.value['date'];
                                        DateTime tmpFromDate = tmpDateTimeRange.start;
                                        DateTime tmpToDate = tmpDateTimeRange.end;
                                        DateTime mealPlanFromDate = DateTime.parse(mealPlan.fromDate!);
                                        DateTime mealPlanToDate = DateTime.parse(mealPlan.toDate!);

                                        if (tmpFromDate.year != mealPlanFromDate.year || tmpFromDate.month != mealPlanFromDate.month || tmpFromDate.day != mealPlanFromDate.day) {
                                          fromDate = DateFormat('yyyy-MM-dd').format(tmpFromDate);
                                        }
                                        if (tmpToDate.year != mealPlanToDate.year || tmpToDate.month != mealPlanToDate.month || tmpToDate.day != mealPlanToDate.day) {
                                          toDate = DateFormat('yyyy-MM-dd').format(tmpToDate);
                                        }

                                        MealPlanEntry newMealPlan = mealPlan.copyWith(
                                            title: (title != mealPlan.title) ? title : null,
                                            recipe: recipe,
                                            servings: servings,
                                            mealType: (formBuilderKey.currentState!.value['mealType'].id != mealPlan.mealType) ?  formBuilderKey.currentState!.value['mealType'] : null,
                                            shared: newUserList,
                                            fromDate: fromDate,
                                            toDate: toDate
                                        );

                                        mealPlanBloc.add(UpdateMealPlan(mealPlan: newMealPlan));
                                      } else {
                                        DateTimeRange tmpDateTimeRange = formBuilderKey.currentState!.value['date'];
                                        DateTime fromDate = tmpDateTimeRange.start;
                                        DateTime toDate = tmpDateTimeRange.end;

                                        MealPlanEntry mealPlan = MealPlanEntry(
                                            title: title ?? '',
                                            recipe: formBuilderKey.currentState!.value['recipe${context.hashCode}'],
                                            servings: int.parse(formBuilderKey.currentState!.value['servings']),
                                            note: '',
                                            fromDate: DateFormat('yyyy-MM-dd').format(fromDate),
                                            toDate: DateFormat('yyyy-MM-dd').format(toDate),
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