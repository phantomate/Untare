import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:untare/cubits/settings_cubit.dart';
import 'package:untare/models/user_setting.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';

Future editShoppingListRefreshDialog(BuildContext context, UserSetting userSetting) {
  final formBuilderKey = GlobalKey<FormBuilderState>();
  final SettingsCubit settingsCubit = context.read<SettingsCubit>();

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
                            child: Text(AppLocalizations.of(context)!.editRefreshInterval, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                          ),
                          FormBuilderTextField(
                            name: 'refresh',
                            initialValue: userSetting.shoppingAutoSync.toString(),
                            decoration: InputDecoration(
                              label: Text(AppLocalizations.of(context)!.refreshIntervalInSeconds)
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              FormBuilderValidators.numeric(),
                              FormBuilderValidators.integer(),
                              FormBuilderValidators.min(1)
                            ]),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 15),
                          Container(
                              alignment: Alignment.bottomRight,
                              child: ElevatedButton(
                                  onPressed: () {
                                    formBuilderKey.currentState!.save();

                                    if (formBuilderKey.currentState!.validate()) {
                                      int newRefresh = int.parse(formBuilderKey.currentState!.value['refresh']);

                                      UserSetting newUserSetting = userSetting.copyWith(shoppingAutoSync: newRefresh);
                                      settingsCubit.updateServerSetting(newUserSetting);

                                      Navigator.pop(dContext);
                                    }
                                  },
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