import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';

Future upsertRecipeStepTimeDialog(BuildContext context, int stepIndex, Function(Map<String, dynamic>) upsertStepTime, {int? stepTime}) {
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
                child: Text(AppLocalizations.of(context)!.timeInMinutes, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              ),
              const SizedBox(height: 10),
              FormBuilder(
                key: formKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: Column(
                  children: [
                    FormBuilderTextField(
                      name: 'stepTime',
                      initialValue: (stepTime != null) ? stepTime.toString() : '0',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.integer()
                      ]),
                    ),
                    const SizedBox(height: 15),
                    Container(
                        alignment: Alignment.bottomRight,
                        child: MaterialButton(
                            color: Theme.of(context).primaryColor,
                            onPressed: () {
                              formKey.currentState!.setInternalFieldValue('stepIndex', stepIndex);
                              formKey.currentState!.save();
                              if (formKey.currentState!.validate()) {
                                upsertStepTime(formKey.currentState!.value);
                                Navigator.pop(dContext);
                              }
                            },
                            child: Text(AppLocalizations.of(context)!.edit)
                        )
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