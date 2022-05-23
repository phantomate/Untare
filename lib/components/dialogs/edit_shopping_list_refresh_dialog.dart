import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:tare/constants/colors.dart';
import 'package:tare/cubits/settings_cubit.dart';
import 'package:tare/models/user_setting.dart';

Future editShoppingListRefreshDialog(BuildContext context, UserSetting userSetting) {
  final _formBuilderKey = GlobalKey<FormBuilderState>();
  final SettingsCubit _settingsCubit = context.read<SettingsCubit>();

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
                            child: Text('Edit refresh interval', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                          ),
                          FormBuilderTextField(
                            name: 'refresh',
                            initialValue: userSetting.shoppingAutoSync.toString(),
                            decoration: InputDecoration(
                              label: Text('Refresh interval in seconds')
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              FormBuilderValidators.numeric(),
                              FormBuilderValidators.integer(),
                              FormBuilderValidators.min(1)
                            ]),
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 15),
                          Container(
                              alignment: Alignment.bottomRight,
                              child: MaterialButton(
                                  color: primaryColor,
                                  onPressed: () {
                                    _formBuilderKey.currentState!.save();

                                    if (_formBuilderKey.currentState!.validate()) {
                                      int newRefresh = int.parse(_formBuilderKey.currentState!.value['refresh']);

                                      UserSetting newUserSetting = userSetting.copyWith(shoppingAutoSync: newRefresh);
                                      _settingsCubit.updateServerSetting(newUserSetting);

                                      Navigator.pop(dContext);
                                    }
                                  },
                                  child: Text('Edit')
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