import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tare/blocs/recipe/recipe_bloc.dart';
import 'package:tare/blocs/recipe/recipe_state.dart';
import 'package:tare/blocs/shopping_list/shopping_list_bloc.dart';
import 'package:tare/blocs/shopping_list/shopping_list_event.dart';
import 'package:tare/blocs/shopping_list/shopping_list_state.dart';
import 'package:tare/components/bottom_sheets/add_shopping_list_entry_bottom_sheet_component.dart';
import 'package:tare/components/bottom_sheets/shopping_list_more_bottom_sheet_component.dart';
import 'package:tare/components/custom_scroll_notification.dart';
import 'package:tare/components/dialogs/edit_shopping_list_entry_dialog.dart';
import 'package:tare/components/loading_component.dart';
import 'package:tare/components/widgets/hide_bottom_nav_bar_stateful_widget.dart';
import 'package:tare/cubits/shopping_list_entry_cubit.dart';
import 'package:tare/models/food.dart';
import 'package:tare/models/shopping_list_entry.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:configurable_expansion_tile_null_safety/configurable_expansion_tile.dart';
import 'package:tare/extensions/double_extension.dart';

class ShoppingListPage extends HideBottomNavBarStatefulWidget {
  ShoppingListPage({required isHideBottomNavBar}) : super(isHideBottomNavBar: isHideBottomNavBar);

  @override
  _ShoppingListPageState createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  late ShoppingListBloc _shoppingListBloc;
  String shoppingListFilter = 'recent';
  List<ShoppingListEntry> shoppingListEntries = [];
  
  @override
  void initState() {
    super.initState();
    _shoppingListBloc = BlocProvider.of<ShoppingListBloc>(context);
    _shoppingListBloc.add(FetchShoppingListEntries(checked: shoppingListFilter));
  }

  @override
  Widget build(BuildContext context) {
    final CustomScrollNotification customScrollNotification = CustomScrollNotification(widget: widget);
    return Scaffold(
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
                shoppingListEntries.forEach((element) {
                  if (!element.checked) {
                    ShoppingListEntry entry = element.copyWith(checked: true);
                    _shoppingListBloc.add(UpdateShoppingListEntryChecked(shoppingListEntry: entry));
                  }
                });
              } else if (state is ShoppingListUpdatedSupermarketCategory) {
                shoppingListEntries.forEach((element) {
                  if (element.food != null && element.food!.supermarketCategory != null && element.food!.supermarketCategory!.id == state.supermarketCategory.id) {
                    Food newFood = element.food!.copyWith(supermarketCategory: state.supermarketCategory);
                    ShoppingListEntry entry = element.copyWith(food: newFood);
                    shoppingListEntries[shoppingListEntries.indexWhere((element) => element.id == entry.id)] = entry;
                  }
                });
              } else if (state is ShoppingListDeletedSupermarketCategory) {
                shoppingListEntries.forEach((element) {
                  if (element.food != null && element.food!.supermarketCategory != null && element.food!.supermarketCategory!.id == state.supermarketCategory.id) {
                    Food newFood = Food(id: element.food!.id, name: element.food!.name, description: element.food!.description, onHand: element.food!.onHand, supermarketCategory: null, ignoreShopping: element.food!.ignoreShopping);
                    ShoppingListEntry entry = element.copyWith(food: newFood);
                    shoppingListEntries[shoppingListEntries.indexWhere((element) => element.id == entry.id)] = entry;
                  }
                });
              }
            },
            builder: (context, state) {
              if (state is ShoppingListLoading) {
                return buildLoading();
              } else if (state is ShoppingListEntriesFetched) {
                shoppingListEntries = state.shoppingListEntries;
              }

              return BlocBuilder<ShoppingListEntryCubit, String>(
                  builder: (context, shoppingListFilter) {
                    List<ShoppingListEntry> shoppingListEntryList = [];
                    List<ShoppingListEntry> deDuplicatedList = [];

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

                    if (shoppingListFilter == 'hide') {
                      // Sort out checked entries based on setting
                      deDuplicatedList.forEach((element) {
                        if (!element.checked) {
                          shoppingListEntryList.add(element);
                        }
                      });
                    } else {
                      shoppingListEntryList = deDuplicatedList;
                    }

                    if (shoppingListEntryList.isNotEmpty) {
                      return NestedScrollView(
                          headerSliverBuilder: (BuildContext hsbContext, bool innerBoxIsScrolled) {
                            return <Widget>[
                              SliverAppBar(
                                expandedHeight: 90,
                                leadingWidth: 0,
                                titleSpacing: 0,
                                automaticallyImplyLeading: false,
                                iconTheme: const IconThemeData(color: Colors.black87),
                                flexibleSpace: FlexibleSpaceBar(
                                  titlePadding: const EdgeInsets.fromLTRB(15, 0, 0, 16),
                                  expandedTitleScale: 1.3,
                                  title: Text(
                                    'Shopping list',
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                                actions: [
                                  IconButton(
                                      tooltip: 'Add',
                                      splashRadius: 20,
                                      onPressed: () {
                                        addShoppingListEntryBottomSheet(context);
                                      },
                                      icon: Icon(
                                        Icons.add,
                                        color: Colors.black87,
                                      )
                                  ),
                                  IconButton(
                                      tooltip: 'More',
                                      splashRadius: 20,
                                      onPressed: () {
                                        shoppingListMoreBottomSheet(context);
                                      },
                                      icon: Icon(
                                        Icons.more_vert_outlined,
                                        color: Colors.black87,
                                      )
                                  )
                                ],
                                elevation: 1.5,
                                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                pinned: true,
                              )
                            ];
                          },
                          body: Container(
                              child: NotificationListener<ScrollNotification>(
                                  onNotification: customScrollNotification.handleScrollNotification,
                                  child: CustomScrollView(
                                    physics: BouncingScrollPhysics(),
                                    slivers: [
                                      SliverToBoxAdapter(
                                        child: GroupedListView<dynamic, String>(
                                          shrinkWrap: true,
                                          padding: const EdgeInsets.only(bottom: 20),
                                          elements: shoppingListEntryList,
                                          groupBy: (element) {
                                            if (element.food != null && element.food!.supermarketCategory != null) {
                                              return element.food!.supermarketCategory.name;
                                            } else {
                                              return 'uncategorized';
                                            }
                                          },
                                          groupSeparatorBuilder: (String groupByValue) {
                                            return Padding(
                                              padding: const EdgeInsets.fromLTRB(15, 25, 15, 5),
                                              child: Text(groupByValue.toUpperCase(), style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
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
                                              bool checkedAllowed = (shoppingListFilter != 'hide') ? true : (!el.checked);
                                              if (el.food != null && element.food != null && checkedAllowed) {
                                                return el.food!.id == element.food!.id;
                                              }
                                              return false;
                                            });

                                            if (groupedList.length > 1) {
                                              List<Widget> groupedWidgetList = [];
                                              bool checkBoxValue = true;

                                              groupedList.forEach((element) {
                                                if (!element.checked) {
                                                  checkBoxValue = false;
                                                }
                                                groupedWidgetList.add(buildShoppingListEntryWidget(element, grouped: true));
                                              });

                                              return StatefulBuilder(
                                                  builder: (context, setState) {
                                                    return ConfigurableExpansionTile(
                                                      headerExpanded: Flexible(
                                                          child: ListTile(
                                                            visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                                                            contentPadding: const EdgeInsets.fromLTRB(10, 0, 20, 0),
                                                            leading: Checkbox(
                                                                value: checkBoxValue,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(3)
                                                                ),
                                                                onChanged: (bool? value) {
                                                                  setState(() {
                                                                    checkBoxValue = value ?? false;
                                                                  });

                                                                  // Delay for animation purpose
                                                                  Future.delayed(const Duration(milliseconds: 100), () {
                                                                    groupedList.forEach((element) {
                                                                      ShoppingListEntry entry = element.copyWith(checked: value);
                                                                      _shoppingListBloc.add(UpdateShoppingListEntryChecked(shoppingListEntry: entry));
                                                                    });
                                                                  });
                                                                }
                                                            ),
                                                            title: Text(
                                                                groupedList.first.food!.name,
                                                                style: (checkBoxValue)
                                                                    ? TextStyle(color: Colors.black45, fontWeight: FontWeight.bold, decoration: TextDecoration.lineThrough)
                                                                    : TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)
                                                            ),
                                                            trailing: Icon(Icons.keyboard_arrow_up),
                                                          )
                                                      ),
                                                      header: Flexible(
                                                          child: Container(
                                                              decoration: BoxDecoration(
                                                                  border: Border(
                                                                      bottom: BorderSide(
                                                                          color: Colors.grey[200]!,
                                                                          width: 1.0
                                                                      )
                                                                  )
                                                              ),
                                                              child: ListTile(
                                                                visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                                                                contentPadding: const EdgeInsets.fromLTRB(10, 0, 20, 0),
                                                                leading: Checkbox(
                                                                    value: checkBoxValue,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(3)
                                                                    ),
                                                                    onChanged: (bool? value) {
                                                                      setState(() {
                                                                        checkBoxValue = value ?? false;
                                                                      });

                                                                      // Delay for animation purpose
                                                                      Future.delayed(const Duration(milliseconds: 100), () {
                                                                        groupedList.forEach((element) {
                                                                          ShoppingListEntry entry = element.copyWith(checked: value);
                                                                          _shoppingListBloc.add(UpdateShoppingListEntryChecked(shoppingListEntry: entry));
                                                                        });
                                                                      });
                                                                    }
                                                                ),
                                                                title: Text(
                                                                    groupedList.first.food!.name,
                                                                    style: (checkBoxValue)
                                                                        ? TextStyle(color: Colors.black45, fontWeight: FontWeight.bold, decoration: TextDecoration.lineThrough)
                                                                        : TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)
                                                                ),
                                                                trailing: Icon(Icons.keyboard_arrow_down),
                                                              )
                                                          )
                                                      ),
                                                      children: groupedWidgetList,
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
                              )
                          )
                      );
                    } else {
                      return Center(
                        child: Text('There are no items on your shopping list'),
                      );
                    }
                  });
              }
          )
        )
    );
  }

  Widget buildShoppingListEntryWidget(ShoppingListEntry shoppingListEntry, {bool? grouped}) {
    String amount = (shoppingListEntry.amount > 0) ? (shoppingListEntry.amount.toFormattedString() + ' ') : '';
    String unit = (shoppingListEntry.unit != null) ? (shoppingListEntry.unit!.name + ' ') : '';
    String food = (shoppingListEntry.food != null) ? (shoppingListEntry.food!.name) : '';
    bool checkBoxValue = shoppingListEntry.checked;
    double paddingLeft = (grouped != null && grouped == true) ? 25 : 10;

    return Slidable(
        key: UniqueKey(),
        endActionPane: ActionPane(
          motion: ScrollMotion(),
          children: [
            SlidableAction(
              autoClose: true,
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
          dismissible: DismissiblePane(
              onDismissed: () {
                _shoppingListBloc.add(DeleteShoppingListEntry(shoppingListEntry: shoppingListEntry));
              }
          ),
        ),
        child: InkWell(
          highlightColor: Colors.grey[50],
          onTap: () {
            editShoppingListEntryDialog(context, shoppingListEntry);
          },
          child: Container(
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: Colors.grey[200]!,
                        width: 1.0
                    )
                )
            ),
            child: StatefulBuilder(
              builder: (context, setState) {
                return ListTile(
                  visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                  contentPadding: EdgeInsets.fromLTRB(paddingLeft, 0, 10, 0),
                  title: Wrap(
                      children: [
                        RichText(
                            text: TextSpan(
                                children: [
                                  TextSpan(text: amount, style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: unit, style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: food),
                                ],
                                style: (checkBoxValue)
                                    ? TextStyle(color: Colors.black45, decoration: TextDecoration.lineThrough)
                                    : TextStyle(color: Colors.black87)
                            )
                        )
                      ]
                  ),
                  subtitle: (shoppingListEntry.recipeMealPlan != null) ? Text(shoppingListEntry.recipeMealPlan!.name) : null,
                  leading: Checkbox(
                      value: checkBoxValue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3)
                      ),
                      onChanged: (bool? value) {
                        setState(() {
                          checkBoxValue = value ?? false;
                        });

                        // Delay for animation purpose
                        Future.delayed(const Duration(milliseconds: 100), () {
                          ShoppingListEntry entry = shoppingListEntry.copyWith(checked: value);
                          _shoppingListBloc.add(UpdateShoppingListEntryChecked(shoppingListEntry: entry));
                        });
                      }
                  ),
                );
              }
            ),
          ),
        )
    );
  }
}

