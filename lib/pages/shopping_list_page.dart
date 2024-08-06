// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:async';

import 'package:configurable_expansion_tile_null_safety/configurable_expansion_tile_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:untare/blocs/recipe/recipe_bloc.dart';
import 'package:untare/blocs/recipe/recipe_state.dart';
import 'package:untare/blocs/shopping_list/shopping_list_bloc.dart';
import 'package:untare/blocs/shopping_list/shopping_list_event.dart';
import 'package:untare/blocs/shopping_list/shopping_list_state.dart';
import 'package:untare/components/bottom_sheets/shopping_list_more_bottom_sheet_component.dart';
import 'package:untare/components/custom_scroll_notification.dart';
import 'package:untare/components/dialogs/add_shopping_list_entry_dialog.dart';
import 'package:untare/components/dialogs/edit_shopping_list_entry_dialog.dart';
import 'package:untare/components/loading_component.dart';
import 'package:untare/components/widgets/hide_bottom_nav_bar_stateful_widget.dart';
import 'package:untare/cubits/settings_cubit.dart';
import 'package:untare/cubits/shopping_list_entry_cubit.dart';
import 'package:untare/models/food.dart';
import 'package:untare/models/shopping_list_entry.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:untare/extensions/double_extension.dart';

class ShoppingListPage extends HideBottomNavBarStatefulWidget {
  const ShoppingListPage({super.key, required super.isHideBottomNavBar});

  @override
  ShoppingListPageState createState() => ShoppingListPageState();
}

class ShoppingListPageState extends State<ShoppingListPage> with TickerProviderStateMixin, WidgetsBindingObserver {
  late ShoppingListBloc _shoppingListBloc;
  String shoppingListFilter = 'recent';
  List<ShoppingListEntry> shoppingListEntries = [];
  late AnimationController _controller;
  late Animation<double> _animation;
  late Timer _timer;


  @override
  void initState() {
    super.initState();
    _shoppingListBloc = BlocProvider.of<ShoppingListBloc>(context);
    _shoppingListBloc.add(FetchShoppingListEntries(checked: shoppingListFilter));
    _controller =  AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linearToEaseOut,
    );

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state.name == 'resumed') {
      _shoppingListBloc.add(FetchShoppingListEntries(checked: shoppingListFilter));
    }
  }

  @override
  Widget build(BuildContext context) {
    final CustomScrollNotification customScrollNotification = CustomScrollNotification(widget: widget);
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext hsbContext, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(hsbContext),
              sliver: SliverLayoutBuilder( builder: (BuildContext hsbContext, constraints) {
                final scrolled = constraints.scrollOffset > 32;

                return SliverAppBar(
                  expandedHeight: 90,
                  titleSpacing: 0,
                  automaticallyImplyLeading: false,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.fromLTRB(15, 0, 0, 16),
                    expandedTitleScale: 1.3,
                    title: Text(
                      AppLocalizations.of(context)!.shoppingListTitle,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: (Theme.of(context).appBarTheme.titleTextStyle != null) ? Theme.of(context).appBarTheme.titleTextStyle!.color : null
                      ),
                    ),
                  ),
                  actions: [
                    RotationTransition(
                        turns: _animation,
                        child: IconButton(
                            tooltip: AppLocalizations.of(context)!.autoSync,
                            splashRadius: 20,
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              if (_controller.isAnimating) {
                                _controller.stop();
                                _timer.cancel();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(AppLocalizations.of(context)!.disabledAutoSync),
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              } else {
                                SettingsCubit settingsCubit = context.read<SettingsCubit>();
                                if (settingsCubit.state.userServerSetting != null && settingsCubit.state.userServerSetting!.shoppingAutoSync > 0) {
                                  _timer = Timer.periodic(Duration(seconds: settingsCubit.state.userServerSetting!.shoppingAutoSync), (timer) {
                                    _shoppingListBloc.add(SyncShoppingListEntries(checked: shoppingListFilter));
                                  });
                                  _controller.repeat();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(AppLocalizations.of(context)!.enabledAutoSync.replaceFirst('%s', settingsCubit.state.userServerSetting!.shoppingAutoSync.toString())),
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.sync_outlined)
                        )
                    ),
                    IconButton(
                        tooltip: AppLocalizations.of(context)!.add,
                        splashRadius: 20,
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          addShoppingListEntryDialog(context);
                        },
                        icon: const Icon(Icons.add)
                    ),
                    IconButton(
                        tooltip: AppLocalizations.of(context)!.moreTooltip,
                        splashRadius: 20,
                        onPressed: () {
                          shoppingListMoreBottomSheet(context);
                        },
                        icon: const Icon(Icons.more_vert_outlined)
                    )
                  ],
                  elevation: (scrolled) ? 1.5 : 0,
                  pinned: true,
                  forceElevated: true,
                );
              }),
            )
          ];
        },
        body: BlocListener<RecipeBloc, RecipeState>(
            listener: (context, recipeState) {
              if (recipeState is RecipeAddedIngredientsToShoppingList) {
                _shoppingListBloc.add(FetchShoppingListEntries(checked: shoppingListFilter));
              }
            },
            child: BlocConsumer<ShoppingListBloc, ShoppingListState>(
                listener: (context, state) {
                  if (state is ShoppingListEntryCreated) {
                    shoppingListEntries.add(state.shoppingListEntry);
                  } else if (state is ShoppingListEntryUpdated) {
                    shoppingListEntries[shoppingListEntries.indexWhere((element) => element.id == state.shoppingListEntry.id)] = state.shoppingListEntry;
                  } else if (state is ShoppingListEntryDeleted) {
                    shoppingListEntries.removeWhere((element) => element.id == state.shoppingListEntry.id);
                  } else if (state is ShoppingListEntryCheckedChanged) {
                    shoppingListEntries[shoppingListEntries.indexWhere((element) => element.id == state.shoppingListEntry.id)] = state.shoppingListEntry;
                  } else if (state is ShoppingListMarkedAsCompleted) {
                    for (var element in shoppingListEntries) {
                      if (!element.checked) {
                        ShoppingListEntry entry = element.copyWith(checked: true);
                        _shoppingListBloc.add(UpdateShoppingListEntryChecked(shoppingListEntry: entry));
                      }
                    }
                  } else if (state is ShoppingListUpdatedSupermarketCategory) {
                    for (var element in shoppingListEntries) {
                      if (element.food != null && element.food!.supermarketCategory != null && element.food!.supermarketCategory!.id == state.supermarketCategory.id) {
                        Food newFood = element.food!.copyWith(supermarketCategory: state.supermarketCategory);
                        ShoppingListEntry entry = element.copyWith(food: newFood);
                        shoppingListEntries[shoppingListEntries.indexWhere((element) => element.id == entry.id)] = entry;
                      }
                    }
                  } else if (state is ShoppingListDeletedSupermarketCategory) {
                    for (var element in shoppingListEntries) {
                      if (element.food != null && element.food!.supermarketCategory != null && element.food!.supermarketCategory!.id == state.supermarketCategory.id) {
                        Food newFood = Food(id: element.food!.id, name: element.food!.name, description: element.food!.description, onHand: element.food!.onHand, supermarketCategory: null, ignoreShopping: element.food!.ignoreShopping);
                        ShoppingListEntry entry = element.copyWith(food: newFood);
                        shoppingListEntries[shoppingListEntries.indexWhere((element) => element.id == entry.id)] = entry;
                      }
                    }
                  } else if (state is ShoppingListEntriesSynced) {
                    shoppingListEntries = state.shoppingListEntries;
                  }
                },
                builder: (context, state) {
                  if (state is ShoppingListLoading) {
                    return buildLoading();
                  } else if (state is ShoppingListEntriesFetched) {
                    shoppingListEntries = state.shoppingListEntries;
                  } else if (state is ShoppingListEntriesFetchedFromCache) {
                    shoppingListEntries = state.shoppingListEntries;
                  }

                  return BlocBuilder<ShoppingListEntryCubit, String>(
                      builder: (context, shoppingListCheckedFilter) {
                        List<ShoppingListEntry> shoppingListEntryList = [];
                        List<ShoppingListEntry> deDuplicatedList = [];

                        // Sort by checked to prevent bug
                        shoppingListEntries.sort((a, b) => (a.checked) ? 1 : -1);

                        // Sort out duplicates
                        shoppingListEntries.forEach((element) {
                          var contains = deDuplicatedList.where((el) {
                            if (el.food != null && element.food != null) {
                              return el.food!.id == element.food!.id;
                            }
                            return false;
                          });

                          if (contains.isEmpty) {
                            deDuplicatedList.add(element);
                          }
                        });

                        if (shoppingListCheckedFilter == 'hide') {
                          // Sort out checked entries based on setting
                          for (var element in deDuplicatedList) {
                            if (!element.checked) {
                              shoppingListEntryList.add(element);
                            }
                          }
                        } else {
                          shoppingListEntryList = deDuplicatedList;
                        }

                        if (shoppingListEntryList.isNotEmpty) {
                          return NotificationListener<ScrollNotification>(
                              onNotification: customScrollNotification.handleScrollNotification,
                              child: CustomScrollView(
                                physics: const BouncingScrollPhysics(),
                                slivers: [
                                  SliverToBoxAdapter(
                                    child: GroupedListView<dynamic, String>(
                                      shrinkWrap: true,
                                      padding: const EdgeInsets.fromLTRB(0, 100, 0, 20),
                                      elements: shoppingListEntryList,
                                      groupBy: (element) {
                                        if (element.food != null && element.food!.supermarketCategory != null) {
                                          return element.food!.supermarketCategory.name;
                                        } else {
                                          return AppLocalizations.of(context)!.uncategorized;
                                        }
                                      },
                                      groupSeparatorBuilder: (String groupByValue) {
                                        return Padding(
                                          padding: const EdgeInsets.fromLTRB(15, 25, 15, 5),
                                          child: Text(groupByValue.toUpperCase(), style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold)),
                                        );
                                      },
                                      itemComparator: (item1, item2) {
                                        if (item1.food != null && item2.food != null) {
                                          return item1.food.name.compareTo(item2.food.name);
                                        }
                                        return -1;
                                      } ,
                                      itemBuilder: (context, dynamic element) {

                                        Iterable<ShoppingListEntry> groupedList = shoppingListEntries.where((el) {
                                          bool checkedAllowed = (shoppingListCheckedFilter != 'hide') ? true : (!el.checked);
                                          if (el.food != null && element.food != null && checkedAllowed) {
                                            return el.food!.id == element.food!.id;
                                          }
                                          return false;
                                        });

                                        if (groupedList.length > 1) {
                                          List<Widget> groupedWidgetList = [];
                                          bool checkBoxValue = true;

                                          for (var element in groupedList) {
                                            if (!element.checked) {
                                              checkBoxValue = false;
                                            }
                                            groupedWidgetList.add(buildShoppingListEntryWidget(element, grouped: true));
                                          }

                                          return StatefulBuilder(
                                              builder: (context, setState) {
                                                return ConfigurableExpansionTile(
                                                  headerExpanded: Flexible(
                                                      child: ListTile(
                                                        minLeadingWidth: 20,
                                                        visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
                                                        contentPadding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                                                        trailing: Transform.scale(
                                                            scale: 1.2,
                                                            child: Checkbox(
                                                                value: checkBoxValue,
                                                                activeColor: Theme.of(context).colorScheme.secondary,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(3)
                                                                ),
                                                                onChanged: (bool? value) {
                                                                  setState(() {
                                                                    checkBoxValue = value ?? false;
                                                                  });

                                                                  // Delay for animation purpose
                                                                  Future.delayed(const Duration(milliseconds: 100), () {
                                                                    for (var element in groupedList) {
                                                                      ShoppingListEntry entry = element.copyWith(checked: value);
                                                                      _shoppingListBloc.add(UpdateShoppingListEntryChecked(shoppingListEntry: entry));
                                                                    }
                                                                  });
                                                                }
                                                            )
                                                        ),
                                                        title: Text(
                                                            groupedList.first.food!.name,
                                                            style: (checkBoxValue)
                                                                ? const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.lineThrough)
                                                                : const TextStyle(fontWeight: FontWeight.bold)
                                                        ),
                                                        leading: const Icon(Icons.keyboard_arrow_up),
                                                      )
                                                  ),
                                                  header: (isExpanded,_,heightFactor, configController) {
                                                    return Flexible(
                                                        child: Container(
                                                            decoration: BoxDecoration(
                                                                border: Border(
                                                                    bottom: BorderSide(
                                                                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                                                                        width: 0.8
                                                                    )
                                                                )
                                                            ),
                                                            child: ListTile(
                                                              minLeadingWidth: 20,
                                                              visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
                                                              contentPadding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                                                              trailing: Transform.scale(
                                                                  scale: 1.2,
                                                                  child: Checkbox(
                                                                      value: checkBoxValue,
                                                                      activeColor: Theme.of(context).colorScheme.secondary,
                                                                      shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(3)
                                                                      ),
                                                                      onChanged: (bool? value) {
                                                                        setState(() {
                                                                          checkBoxValue = value ?? false;
                                                                        });

                                                                        // Delay for animation purpose
                                                                        Future.delayed(const Duration(milliseconds: 100), () {
                                                                          for (var element in groupedList) {
                                                                            ShoppingListEntry entry = element.copyWith(checked: value);
                                                                            _shoppingListBloc.add(UpdateShoppingListEntryChecked(shoppingListEntry: entry));
                                                                          }
                                                                        });
                                                                      }
                                                                  )
                                                              ),
                                                              title: Text(
                                                                  groupedList.first.food!.name,
                                                                  style: (checkBoxValue)
                                                                      ? const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.lineThrough)
                                                                      : const TextStyle(fontWeight: FontWeight.bold)
                                                              ),
                                                              leading: const Icon(Icons.keyboard_arrow_down),
                                                            )
                                                        )
                                                    );
                                                  },
                                                  childrenBody: Column(children: groupedWidgetList),
                                                );
                                              });
                                        } else {
                                          return buildShoppingListEntryWidget(element);
                                        }
                                      },
                                      floatingHeader: true, // optional
                                      order: GroupedListOrder.ASC, // optional
                                    ),
                                  )
                                ],
                              )
                          );
                        } else {
                          return Center(
                            child: Text(AppLocalizations.of(context)!.shoppingListNoEntries),
                          );
                        }
                      });
                }
            )
        )
      )
    );
  }

  Widget buildShoppingListEntryWidget(ShoppingListEntry shoppingListEntry, {bool? grouped}) {
    String amount = (shoppingListEntry.amount > 0) ? ('${shoppingListEntry.amount.toFormattedString()} ') : '';
    String unit = (shoppingListEntry.amount > 0 && shoppingListEntry.unit != null) ? ('${shoppingListEntry.unit!.getUnitName(shoppingListEntry.amount)} ') : '';
    String food = (shoppingListEntry.food != null) ? (shoppingListEntry.food!.getFoodName(shoppingListEntry.amount)) : '';
    bool checkBoxValue = shoppingListEntry.checked;
    double paddingLeft = (grouped != null && grouped == true) ? 35 : 20;

    return Slidable(
        key: UniqueKey(),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          dismissible: DismissiblePane(
              onDismissed: () {
                _shoppingListBloc.add(DeleteShoppingListEntry(shoppingListEntry: shoppingListEntry));
              }
          ),
          children: [
            SlidableAction(
              autoClose: false,
              flex: 1,
              onPressed: (slideContext) {
                Slidable.of(slideContext)!.dismiss(
                    ResizeRequest(
                        const Duration(milliseconds: 300),
                            () {
                              _shoppingListBloc.add(DeleteShoppingListEntry(shoppingListEntry: shoppingListEntry));
                        }
                    ),
                    duration: const Duration(milliseconds: 300)
                );
              },
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              icon: Icons.delete_outline,
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            editShoppingListEntryDialog(context, shoppingListEntry);
          },
          child: Container(
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                        width: 0.8
                    )
                )
            ),
            child: StatefulBuilder(
              builder: (context, setState) {
                return ListTile(
                    visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
                    contentPadding: EdgeInsets.fromLTRB(paddingLeft, 0, 15, 0),
                    title: Wrap(
                        children: [
                          RichText(
                              text: TextSpan(
                                  children: [
                                    TextSpan(text: amount, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color, fontWeight: FontWeight.bold)),
                                    TextSpan(text: unit, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color, fontWeight: FontWeight.bold)),
                                    TextSpan(text: food, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color, fontWeight: (shoppingListEntry.food != null && shoppingListEntry.food!.recipe != null) ? FontWeight.bold : FontWeight.w400)),
                                  ],
                                  style: (checkBoxValue)
                                      ? const TextStyle(decoration: TextDecoration.lineThrough)
                                      : null
                              )
                          )
                        ]
                    ),
                    subtitle: (shoppingListEntry.recipeMealPlan != null)
                        ? Padding(padding: const EdgeInsets.only(top: 4), child: Text(shoppingListEntry.recipeMealPlan!.name))
                        : null,
                    trailing: Transform.scale(
                      scale: 1.2,
                      child: Checkbox(
                        activeColor: Theme.of(context).colorScheme.secondary,
                        value: checkBoxValue,
                        onChanged: (bool? value) {
                          setState(() {
                            checkBoxValue = value ?? false;
                          });

                          // Delay for animation purpose
                          Future.delayed(const Duration(milliseconds: 100), () {
                            ShoppingListEntry entry = shoppingListEntry.copyWith(checked: value);
                            _shoppingListBloc.add(UpdateShoppingListEntryChecked(shoppingListEntry: entry));
                          });
                        },
                      ),
                    ),
                );
              }
            ),
          ),
        )
    );
  }
}

