import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:untare/components/form_fields/food_type_ahead_form_field.dart';
import 'package:untare/components/form_fields/note_text_form_field.dart';
import 'package:untare/components/form_fields/quantity_text_form_field.dart';
import 'package:untare/components/form_fields/unit_type_ahead_form_field.dart';
import 'package:untare/models/ingredient.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';

Future upsertRecipeIngredientDialog(BuildContext context, int stepIndex, int ingredientIndex, Function(Map<String, dynamic>) upsertIngredient, {Ingredient? ingredient}) {
  final formKey = GlobalKey<FormBuilderState>();

  return showDialog(context: context, builder: (BuildContext dContext) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        insetPadding: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Wrap(
            spacing: 10,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Text((ingredient != null) ? AppLocalizations.of(context)!.editIngredient : AppLocalizations.of(context)!.createIngredient, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              ),
              const SizedBox(height: 10),
              FormBuilder(
                key: formKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                            width: 90,
                            child: quantityTextFormField((ingredient != null) ? ingredient.amount : null, formKey, context)
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                            child: unitTypeAheadFormField((ingredient != null) ? ingredient.unit : null, formKey, context)
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    foodTypeAheadFormField((ingredient != null) ? ingredient.food : null, formKey, context),
                    const SizedBox(height: 10),
                    noteTextFormField((ingredient != null) ? ingredient.note : null, formKey, context),
                    const SizedBox(height: 10),
                    Container(
                      alignment: Alignment.bottomRight,
                      child: MaterialButton(
                        color: Theme.of(context).primaryColor,
                        child: Text((ingredient != null) ? AppLocalizations.of(context)!.edit : AppLocalizations.of(context)!.add),
                        onPressed: () {

                          formKey.currentState!.setInternalFieldValue('stepIndex', stepIndex);
                          formKey.currentState!.setInternalFieldValue('ingredientIndex', ingredientIndex);
                          formKey.currentState!.setInternalFieldValue('method', ((ingredient != null) ? 'edit' : 'add'));
                          formKey.currentState!.save();

                          if (formKey.currentState!.validate()) {
                            upsertIngredient(formKey.currentState!.value);
                            Navigator.pop(dContext);
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        )
    );
  });
}