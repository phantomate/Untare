

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hive/hive.dart';
import 'package:tare/constants/colors.dart';
import 'package:tare/cubits/settings_cubit.dart';
import 'package:tare/models/user.dart';
import 'package:tare/models/user_setting.dart';
import 'package:tare/services/api/api_user.dart';

Future editShareDialog(BuildContext context, UserSetting userSetting, String referer) async {
  var box = Hive.box('hydrated_box');
  User? loggedInUser = box.get('user');
  final _formBuilderKey = GlobalKey<FormBuilderState>();
  final SettingsCubit _settingsCubit = context.read<SettingsCubit>();
  List<FormBuilderFieldOption> shareOptionList = [];
  final ApiUser _apiUser = ApiUser();
  List<User> userList = await _apiUser.getUsers();

  userList.forEach((element) {
    if (loggedInUser == null || loggedInUser.id != element.id) {
      shareOptionList.add(
          FormBuilderFieldOption(
              value: element.id, child: Text(element.username)
          )
      );
    }
  });

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
                            child: Text('Edit ' + ((referer == 'shopping') ? 'shopping list' : 'meal plan' + ' sharing'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                          ),
                          FormBuilderFilterChip (
                            name: 'share',
                            initialValue: (referer == 'shopping') ? userSetting.shoppingShare.map((user) => user.id).toList() : userSetting.planShare.map((user) => user.id).toList(),
                            decoration: InputDecoration(
                              labelText: 'Share with',
                              isDense: true,
                              contentPadding: const EdgeInsets.fromLTRB(10, 10 ,10, 0),
                            ),
                            options: shareOptionList,
                          ),
                          SizedBox(height: 15),
                          Container(
                              alignment: Alignment.bottomRight,
                              child: MaterialButton(
                                  color: primaryColor,
                                  onPressed: () {
                                    _formBuilderKey.currentState!.save();

                                    if (_formBuilderKey.currentState!.validate()) {
                                      List<User> newUserList = [];
                                      _formBuilderKey.currentState!.value['share'].forEach((id) {
                                        newUserList.add(userList.firstWhere((user) => user.id == id));
                                      });

                                      UserSetting newUserSetting;
                                      if (referer == 'shopping') {
                                        newUserSetting = userSetting.copyWith(shoppingShare: newUserList);
                                      } else {
                                        print(newUserList);
                                        newUserSetting = userSetting.copyWith(planShare: newUserList);
                                      }

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