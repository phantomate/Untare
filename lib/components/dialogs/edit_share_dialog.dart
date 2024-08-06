import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hive/hive.dart';
import 'package:untare/cubits/settings_cubit.dart';
import 'package:untare/futures/future_api_cache_users.dart';
import 'package:untare/models/user.dart';
import 'package:untare/models/user_setting.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';

Future editShareDialog(BuildContext context, UserSetting userSetting, String referer) async {
  var box = Hive.box('unTaReBox');
  User? loggedInUser = box.get('user');
  final formBuilderKey = GlobalKey<FormBuilderState>();
  final SettingsCubit settingsCubit = context.read<SettingsCubit>();
  List<FormBuilderChipOption> shareOptionList = [];
  List<User> userList = await getUsersFromApiCache();

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
                            child: Text(((referer == 'shopping') ? AppLocalizations.of(context)!.editShoppingListSharing : AppLocalizations.of(context)!.editMealPlanSharing), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                          ),
                          FormBuilderFilterChip (
                            name: 'share',
                            checkmarkColor: Theme.of(context).primaryColor,
                            initialValue: (referer == 'shopping') ? userSetting.shoppingShare.map((user) => user.id).toList() : userSetting.planShare.map((user) => user.id).toList(),
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
                              child: ElevatedButton(
                                  onPressed: () {
                                    formBuilderKey.currentState!.save();

                                    if (formBuilderKey.currentState!.validate()) {
                                      List<User> newUserList = [];
                                      formBuilderKey.currentState!.value['share'].forEach((id) {
                                        newUserList.add(userList.firstWhere((user) => user.id == id));
                                      });

                                      UserSetting newUserSetting;
                                      if (referer == 'shopping') {
                                        newUserSetting = userSetting.copyWith(shoppingShare: newUserList);
                                      } else {
                                        newUserSetting = userSetting.copyWith(planShare: newUserList);
                                      }

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