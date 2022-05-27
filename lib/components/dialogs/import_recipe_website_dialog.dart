import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:tare/blocs/recipe/recipe_bloc.dart';
import 'package:tare/blocs/recipe/recipe_event.dart';

Future importRecipeWebsiteDialog(BuildContext context) {
  final _formBuilderKey = GlobalKey<FormBuilderState>();
  final RecipeBloc _recipeBloc = BlocProvider.of<RecipeBloc>(context);

  return showDialog(context: context, builder: (BuildContext dContext){
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      insetPadding: EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child:  FormBuilder(
          key: _formBuilderKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Wrap(
            spacing: 15,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text('Import recipe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              ),
              FormBuilderTextField(
                name: 'url',
                decoration: InputDecoration(
                    label: Text('Url')
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.url(),
                ]),
              ),
              Container(
                  alignment: Alignment.bottomRight,
                  child: MaterialButton(
                      color: Theme.of(context).primaryColor,
                      onPressed: () {
                        _formBuilderKey.currentState!.save();

                        if (_formBuilderKey.currentState!.validate()) {
                          _recipeBloc.add(ImportRecipe(url: _formBuilderKey.currentState!.value['url']));

                          Navigator.pop(dContext);
                        }
                      },
                      child: Text('Import')
                  )
              )
            ],
          )
        )
      ),
    );
  });
}