import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:untare/blocs/unit/unit_bloc.dart';
import 'package:untare/blocs/unit/unit_event.dart';
import 'package:untare/models/unit.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';

Future editUnitDialog(BuildContext context, Unit unit) {
  final formBuilderKey = GlobalKey<FormBuilderState>();
  UnitBloc unitBloc = BlocProvider.of<UnitBloc>(context);

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
                              child: Text(AppLocalizations.of(context)!.editUnit, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                            ),
                            FormBuilderTextField(
                              name: 'name',
                              initialValue: unit.name,
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
                              initialValue: unit.pluralName,
                            ),
                            const SizedBox(height: 15),
                            Container(
                                alignment: Alignment.bottomRight,
                                child: MaterialButton(
                                    color: Theme.of(context).primaryColor,
                                    onPressed: () {
                                      formBuilderKey.currentState!.save();
                                      if (formBuilderKey.currentState!.validate()) {
                                        Map<String, dynamic> formBuilderData = formBuilderKey.currentState!.value;

                                        Unit newUnit = unit.copyWith(name: formBuilderData['name'], pluralName: formBuilderData['plural']);
                                        unitBloc.add(UpdateUnit(unit: newUnit));

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