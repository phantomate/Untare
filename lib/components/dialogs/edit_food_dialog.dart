import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:untare/blocs/food/food_bloc.dart';
import 'package:untare/blocs/food/food_event.dart';
import 'package:untare/models/food.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';

Future editFoodDialog(BuildContext context, Food food) {
  final formBuilderKey = GlobalKey<FormBuilderState>();
  FoodBloc foodBloc = BlocProvider.of<FoodBloc>(context);

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
                              child: Text(AppLocalizations.of(context)!.editFood, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                            ),
                            FormBuilderTextField(
                              name: 'name',
                              initialValue: food.name,
                              decoration: InputDecoration(
                                  label: Text(AppLocalizations.of(context)!.name)
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required()
                              ]),
                            ),
                            const SizedBox(height: 15),
                            FormBuilderTextField(
                              name: 'plural',
                              decoration: InputDecoration(
                                  label: Text(AppLocalizations.of(context)!.plural)
                              ),
                              initialValue: food.pluralName,
                            ),
                            const SizedBox(height: 15),
                            Container(
                                alignment: Alignment.bottomRight,
                                child: ElevatedButton(
                                    onPressed: () {
                                      formBuilderKey.currentState!.save();
                                      if (formBuilderKey.currentState!.validate()) {
                                        Map<String, dynamic> formBuilderData = formBuilderKey.currentState!.value;

                                        Food newFood = food.copyWith(name: formBuilderData['name'], pluralName: formBuilderData['plural']);
                                        foodBloc.add(UpdateFood(food: newFood));

                                        Navigator.pop(dContext);
                                      }
                                    },
                                    child: Text(AppLocalizations.of(context)!.edit)
                                )
                            )
                          ]
                      );
                    }
                )
            )
        )
    );
  });
}