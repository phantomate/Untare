import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:untare/blocs/meal_plan/meal_plan_bloc.dart';
import 'package:untare/blocs/meal_plan/meal_plan_event.dart';
import 'package:untare/blocs/meal_plan/meal_plan_state.dart';
import 'package:untare/components/bottom_sheets/meal_plan_entry_more_bottom_sheet_component.dart';
import 'package:untare/components/bottom_sheets/meal_plan_more_bottom_sheet_component.dart';
import 'package:untare/components/dialogs/upsert_meal_plan_entry_dialog.dart';
import 'package:untare/components/loading_component.dart';
import 'package:untare/components/recipes/recipe_grid_component.dart';
import 'package:untare/components/recipes/recipe_list_component.dart';
import 'package:untare/components/widgets/hide_bottom_nav_bar_stateful_widget.dart';
import 'package:untare/cubits/settings_cubit.dart';
import 'package:untare/models/app_setting.dart';
import 'package:untare/models/meal_plan_entry.dart';
import 'package:untare/models/meal_type.dart';
import '../components/custom_scroll_notification.dart';


class MealPlanPage extends HideBottomNavBarStatefulWidget {
  const MealPlanPage({super.key, required super.isHideBottomNavBar});

  @override
  MealPlanPageState createState() => MealPlanPageState();
}

class MealPlanPageState extends State<MealPlanPage> with WidgetsBindingObserver {
  DateTime dateTime = DateTime.now().toLocal();
  late String rangeTitleText;
  late MealPlanBloc _mealPlanBloc;
  List<MealPlanEntry> mealPlanList = [];
  late DateTime fromDateTime;
  late DateTime toDateTime;
  
  late String fromDate;
  late String toDate;

  @override
  void initState() {
    super.initState();
    fromDateTime = findFirstDateOfTheWeek(dateTime).subtract(const Duration(days: 28));
    fromDate = DateFormat('yyyy-MM-dd').format(fromDateTime);

    toDateTime = findLastDateOfTheWeek(dateTime).add(const Duration(days: 28));
    toDate = DateFormat('yyyy-MM-dd').format(toDateTime);

    _mealPlanBloc = BlocProvider.of<MealPlanBloc>(context);
    _mealPlanBloc.add(FetchMealPlan(from: fromDate, to: toDate));

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state.name == 'resumed') {
      _mealPlanBloc.add(FetchMealPlan(from: fromDate, to: toDate));
    }
  }

  DateTime findFirstDateOfTheWeek(DateTime dateTime) {
    return dateTime.subtract(Duration(days: dateTime.weekday - 1));
  }

  DateTime findLastDateOfTheWeek(DateTime dateTime) {
    return dateTime.add(Duration(days: DateTime.daysPerWeek - dateTime.weekday));
  }

  @override
  void didChangeDependencies() {
    rangeTitleText = getTitleText();
    super.didChangeDependencies();
  }

  void decreaseDate() {
    setState(() {
      dateTime = dateTime.subtract(const Duration(days: 7));
      rangeTitleText = getTitleText();

      DateTime firstDay = findFirstDateOfTheWeek(dateTime);
      if (firstDay.year == fromDateTime.year && firstDay.month == fromDateTime.month && firstDay.day == fromDateTime.day) {
        fromDateTime = fromDateTime.subtract(const Duration(days: 28));
        fromDate = DateFormat('yyyy-MM-dd').format(fromDateTime);
        _mealPlanBloc.add(FetchMealPlan(from: fromDate, to: toDate));
      }
    });
  }

  void increaseDate() {
    setState(() {
      dateTime = dateTime.add(const Duration(days: 7));
      rangeTitleText = getTitleText();

      DateTime lastDay = findLastDateOfTheWeek(dateTime);
      if (lastDay.year == toDateTime.year && lastDay.month == toDateTime.month && lastDay.day == toDateTime.day) {
        toDateTime = toDateTime.add(const Duration(days: 28));
        toDate = DateFormat('yyyy-MM-dd').format(toDateTime);
        _mealPlanBloc.add(FetchMealPlan(from: fromDate, to: toDate));
      }
    });
  }

  String getTitleText() {
    DateTime today = DateTime.now().toLocal();
    DateTime todayNextWeek = today.add(const Duration(days: 7));
    DateTime todayLastWeek = today.subtract(const Duration(days: 7));

    // Add and subtract one millisecond cause there is no <= and >=
    if (dateTime.add(const Duration(microseconds: 1)).isAfter(findFirstDateOfTheWeek(today))
        && dateTime.subtract(const Duration(microseconds: 1)).isBefore(findLastDateOfTheWeek(today))) {
      return AppLocalizations.of(context)!.mealPlanThisWeek;
    } else if (dateTime.add(const Duration(microseconds: 1)).isAfter(findFirstDateOfTheWeek(todayNextWeek))
        && dateTime.subtract(const Duration(microseconds: 1)).isBefore(findLastDateOfTheWeek(todayNextWeek))) {
      return AppLocalizations.of(context)!.mealPlanNextWeek;
    } else if (dateTime.add(const Duration(microseconds: 1)).isAfter(findFirstDateOfTheWeek(todayLastWeek))
        && dateTime.subtract(const Duration(microseconds: 1)).isBefore(findLastDateOfTheWeek(todayLastWeek))) {
      return AppLocalizations.of(context)!.mealPlanLastWeek;
    }

    return '${DateFormat('d. MMM', Platform.localeName).format(findFirstDateOfTheWeek(dateTime))} - ${DateFormat('d. MMM', Platform.localeName).format(findLastDateOfTheWeek(dateTime))}';
  }

  @override
  Widget build(BuildContext context) {
    final CustomScrollNotification customScrollNotification = CustomScrollNotification(widget: widget);
    return NestedScrollView(
        headerSliverBuilder: (BuildContext hsbContext, bool innerBoxIsScrolled) {
      return <Widget>[
        SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(hsbContext),
            sliver: SliverLayoutBuilder(builder: (BuildContext hsbContext, constraints) {
              final scrolled = constraints.scrollOffset > 27;

              return SliverAppBar(
                expandedHeight: 120,
                leadingWidth: 0,
                titleSpacing: 0,
                automaticallyImplyLeading: false,
                iconTheme: const IconThemeData(color: Colors.black87),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.fromLTRB(15, 0, 0, 55),
                  expandedTitleScale: 1.3,
                  title: Text(
                    AppLocalizations.of(context)!.mealPlanTitle,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: (Theme.of(context).appBarTheme.titleTextStyle != null) ? Theme.of(context).appBarTheme.titleTextStyle!.color : null
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                      tooltip: AppLocalizations.of(context)!.moreTooltip,
                      splashRadius: 20,
                      onPressed: () {
                        mealPlanMoreBottomSheet(context);
                      },
                      icon: Icon(
                        Icons.more_vert_outlined,
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                      )
                  )
                ],
                elevation: (scrolled) ? 1.5 : 0,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                pinned: true,
                forceElevated: true,
                bottom: PreferredSize(
                  preferredSize: const Size(double.maxFinite, 35),
                  child:  Container(
                    height: 35,
                    padding: const EdgeInsets.fromLTRB(15, 0, 15, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                            padding: const EdgeInsets.fromLTRB(8, 1, 8, 12),
                            splashRadius: 20,
                            onPressed: () {
                              decreaseDate();
                            },
                            icon: const Icon(Icons.chevron_left_outlined)
                        ),
                        SizedBox(
                          width: 155,
                          child: Text(
                            rangeTitleText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).textTheme.bodyMedium!.color,
                            ),
                          ),
                        ),
                        IconButton(
                            padding: const EdgeInsets.fromLTRB(8, 1, 8, 12),
                            splashRadius: 20,
                            onPressed: () {
                              increaseDate();
                            },
                            icon: const Icon(Icons.chevron_right_outlined)
                        ),
                      ],
                    ),
                  ),
                ),
              );
            })
        )
      ];
    },
    body: BlocConsumer<MealPlanBloc, MealPlanState>(
        listener: (context, state) {
          if (state is MealPlanCreated) {
            mealPlanList.add(state.mealPlan);
          } else if (state is MealPlanUpdated) {
            mealPlanList[mealPlanList.indexWhere((element) => element.id == state.mealPlan.id)] = state.mealPlan;
          } else if (state is MealPlanDeleted) {
            mealPlanList.removeWhere((element) => element.id == state.mealPlan.id);
          } else if (state is MealPlanUpdatedType) {
            for (var element in mealPlanList) {
              if (element.mealType.id == state.mealType.id) {
                MealType newMealType = element.mealType.copyWith(name: state.mealType.name);
                MealPlanEntry entry = element.copyWith(mealType: newMealType);
                mealPlanList[mealPlanList.indexWhere((element) => element.id == entry.id)] = entry;
              }
            }
          } else if (state is MealPlanDeletedType) {
            List<int> idsToRemove = [];
            for (var element in mealPlanList) {
              if (element.mealType.id == state.mealType.id) {
                idsToRemove.add(element.id!);
              }
            }

            for (var element in idsToRemove) {
              mealPlanList.removeWhere((el) => el.id == element);
            }
          } else if (state is MealPlanFetched) {
            mealPlanList = state.mealPlanList;
          } else if (state is MealPlanFetchedFromCache) {
            mealPlanList = state.mealPlanList;
          }
        },
        builder: (context, state) {
          if (state is MealPlanLoading) {
            return buildLoading();
          }

          return NotificationListener<ScrollNotification>(
            onNotification: customScrollNotification.handleScrollNotification,
            child: ListView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.only(bottom: 20, top: 145),
              children: buildMealPlanLayout(context, mealPlanList, dateTime),
            ),
          );
        }
      )
    );
  }
}

List<Widget> buildMealPlanLayout(BuildContext context, List<MealPlanEntry> mealPLanList, DateTime dateTime) {
  List<Widget> mealPlanLayout = [];
  DateTime firstDayOfWeek = dateTime.subtract(Duration(days: dateTime.weekday - 1));

  for(int i = 0; i < 7; i++) {
    DateTime day = firstDayOfWeek.add(Duration(days: i));

    mealPlanLayout.add(buildDayLayout(context, mealPLanList, day));
  }

  return mealPlanLayout;
}

Widget buildDayLayout(BuildContext context, List<MealPlanEntry> mealPlanList, DateTime day) {
  DateTime today = DateTime.now();
  bool isToday = (today.year == day.year && today.month == day.month && today.day == day.day);
  List<MealPlanEntry> dailyMealPlanList = [];
  List<Widget> dailyMealPlanWidgetList = [];

  for (var mealPlan in mealPlanList) {
    DateTime tempFromDate = DateTime.parse(mealPlan.fromDate!).toLocal();
    DateTime tempToDate = DateTime.parse(mealPlan.toDate!).toLocal();

    if (day.year == tempFromDate.year && day.month == tempFromDate.month && day.day == tempFromDate.day) {
      dailyMealPlanList.add(mealPlan);
    }
    if (tempFromDate.year != tempToDate.year || tempFromDate.month != tempToDate.month || tempFromDate.day != tempToDate.day) {
      if (day.year == tempToDate.year && day.month == tempToDate.month && day.day == tempToDate.day) {
        dailyMealPlanList.add(mealPlan);
      }
    }
  }

  return Container(
    decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(
                color: Theme.of(context).textTheme.labelMedium!.color!,
                width: 0.8
            )
        )
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Row(
            children: [
              Text(
                  DateFormat('EEEE', Platform.localeName).format(day),
                  style: TextStyle(
                      fontWeight: (dailyMealPlanList.isNotEmpty) ? FontWeight.bold : FontWeight.normal,
                      color: (dailyMealPlanList.isNotEmpty) ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).textTheme.bodySmall!.color
                  )
              ),
              const SizedBox(width: 8),
              (isToday)
                  ? Text(AppLocalizations.of(context)!.mealPlanToday.toLowerCase(), style: TextStyle(color: Theme.of(context).primaryColor))
                  : Text(DateFormat('d. MMM', Platform.localeName).format(day), style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color))
            ],
          ),
          trailing: IconButton(
              onPressed: () {
                upsertMealPlanEntryDialog(context, date: day, referer: 'meal-plan');
              },
              icon: const Icon(Icons.add),
              splashRadius: 20,
          ),
        ),
        BlocBuilder<SettingsCubit, AppSetting>(
            builder: (context, setting) {
              dailyMealPlanWidgetList.clear();
              for (var mealPlan in dailyMealPlanList) {
                DateTime tempFromDate = DateTime.parse(mealPlan.fromDate!).toLocal();
                bool disabled = (day.year != tempFromDate.year || day.month != tempFromDate.month || day.day != tempFromDate.day);

                if (mealPlan.recipe != null) {
                  if (setting.layout == 'list') {
                    dailyMealPlanWidgetList.add(
                      Container(
                        padding: const EdgeInsets.fromLTRB(10, 0, 12, 0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                            border: Border(
                                bottom: BorderSide(
                                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                                    width: 1
                                )
                            )
                        ),
                        child: recipeListComponent(mealPlan.recipe!, context, referer: 'mealList${mealPlan.id}${day.toString()}', mealPlan: mealPlan, disabled: disabled),
                      )

                    );
                  } else {
                    dailyMealPlanWidgetList.add(
                        SizedBox(
                            width: 180,
                            child: recipeGridComponent(mealPlan.recipe!, context, referer: 'mealGrid${mealPlan.id}${day.toString()}', mealPlan: mealPlan, disabled: disabled)
                        )
                    );
                    dailyMealPlanWidgetList.add(const SizedBox(width: 5));
                  }
                } else {
                  if (setting.layout == 'list') {
                    dailyMealPlanWidgetList.add(
                        InkWell(
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                            onLongPress: () {
                              mealPlanEntryMoreBottomSheet(context, mealPlan);
                            },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(10, 0, 12, 0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainer,
                                border: Border(
                                    bottom: BorderSide(
                                        color: Theme.of(context).colorScheme.surfaceContainerHigh,
                                        width: 1
                                    )
                                )
                            ),
                            child: ListTile(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              onLongPress: () {
                                mealPlanEntryMoreBottomSheet(context, mealPlan);
                              },
                              contentPadding: const EdgeInsets.all(5),
                              leading: SizedBox(
                                width: 100,
                                child: Container(
                                  height: 100,
                                  width: double.maxFinite,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.secondary,
                                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.restaurant_menu_outlined,
                                      color: Theme.of(context).colorScheme.onSecondary,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(mealPlan.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                              subtitle: Row(
                                children: [
                                  Flexible(
                                      child: Text(mealPlan.mealType.name, style: TextStyle(color: Theme.of(context).colorScheme.secondary.withOpacity(0.8), fontSize: 12))
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                    );
                  } else {
                    dailyMealPlanWidgetList.add(
                        InkWell(
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                            onLongPress: () {
                              mealPlanEntryMoreBottomSheet(context, mealPlan);
                            },
                            child: SizedBox(
                                width: 180,
                                child:  Card(
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(10))
                                  ),
                                  child:Column(
                                    children: [
                                      Stack(
                                        children: [
                                          Container(
                                            height: 140,
                                            width: double.maxFinite,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).colorScheme.secondary,
                                              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.restaurant_menu_outlined,
                                                color: Theme.of(context).colorScheme.onSecondary,
                                              ),
                                            ),
                                          ),

                                          Container(
                                            height: 140,
                                            width: double.maxFinite,
                                            alignment: Alignment.bottomLeft,
                                            child: Container(
                                              padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
                                              margin: const EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context).colorScheme.tertiaryContainer,
                                                  borderRadius: BorderRadius.circular(30)
                                              ),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [Flexible(child: Text(mealPlan.mealType.name, style: TextStyle(color: Theme.of(context).colorScheme.onTertiaryContainer, fontSize: 11)))],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      Container(
                                        height: 48,
                                        alignment: Alignment.centerLeft,
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                                        ),
                                        padding: const EdgeInsets.only(top: 6, right: 15, bottom: 8, left: 15),
                                        child: Text(
                                          mealPlan.title,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )
                                    ],
                                  ),
                                )
                            )
                        )
                        );
                    dailyMealPlanWidgetList.add(const SizedBox(width: 5));
                  }
                }
              }

              if (setting.layout == 'list') {
                return Column(
                  children: dailyMealPlanWidgetList,
                );
              } else {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  scrollDirection: Axis.horizontal,
                  padding: (dailyMealPlanWidgetList.isNotEmpty) ? const EdgeInsets.fromLTRB(12, 0, 7, 8) : null,
                  child: Row(
                    children: dailyMealPlanWidgetList,
                  ),
                );
              }
            }
        )
      ],
    ),
  );
}
