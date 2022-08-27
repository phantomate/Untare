import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:untare/blocs/recipe/recipe_bloc.dart';
import 'package:untare/blocs/recipe/recipe_event.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';

Future importRecipeWebsiteDialog(BuildContext context) {
  final formBuilderKey = GlobalKey<FormBuilderState>();
  final RecipeBloc recipeBloc = BlocProvider.of<RecipeBloc>(context);
  bool splitInstructions = true;

  return showDialog(context: context, builder: (BuildContext dContext){
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      insetPadding: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: StatefulBuilder(
        builder: (context, setState) {
          return FormBuilder(
              key: formBuilderKey,
              autovalidateMode: AutovalidateMode.disabled,
              child: Wrap(
                spacing: 15,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(AppLocalizations.of(context)!.importRecipe, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  ),
                  FormBuilderTextField(
                    name: 'url',
                    decoration: InputDecoration(
                        label: Text(AppLocalizations.of(context)!.url)
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.url(),
                    ]),
                  ),
                  FormBuilderSwitch(
                    name: 'split',
                    title: Text(AppLocalizations.of(context)!.splitDirections),
                    onChanged: (bool? value) {
                      setState(() {
                        splitInstructions = value ?? false;
                      });
                    },
                    initialValue: splitInstructions,
                    activeColor: Theme.of(context).primaryColor,
                    decoration: const InputDecoration(
                        border: InputBorder.none
                    ),
                  ),
                  Container(
                      alignment: Alignment.bottomRight,
                      child: MaterialButton(
                          color: Theme.of(context).primaryColor,
                          onPressed: () {
                            formBuilderKey.currentState!.save();

                            if (formBuilderKey.currentState!.validate()) {
                              recipeBloc.add(
                                  ImportRecipe(
                                      url: formBuilderKey.currentState!.value['url'],
                                      splitDirections: formBuilderKey.currentState!.value['split']
                                  )
                              );

                              Navigator.pop(dContext);
                            }
                          },
                          child: Text(AppLocalizations.of(context)!.import)
                      )
                  )
                ],
              )
          );
        })
      ),
    );
  });
}