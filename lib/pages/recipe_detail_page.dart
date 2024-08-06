import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:untare/blocs/recipe/recipe_bloc.dart';
import 'package:untare/blocs/recipe/recipe_event.dart';
import 'package:untare/blocs/recipe/recipe_state.dart';
import 'package:untare/components/bottom_sheets/recipe_more_bottom_sheet_component.dart';
import 'package:untare/components/widgets/recipe_detail_tabbar_widget.dart';
import 'package:untare/components/recipes/recipe_image_component.dart';
import 'package:untare/components/loading_component.dart';
import 'package:untare/models/keyword.dart';
import 'package:untare/models/recipe.dart';
import 'package:untare/extensions/int_extension.dart';
import 'package:wakelock/wakelock.dart';

class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;
  final String? referer;

  const RecipeDetailPage({super.key, required this.recipe, this.referer});

  @override
  RecipeDetailPageState createState() => RecipeDetailPageState();
}

class RecipeDetailPageState extends State<RecipeDetailPage> with WidgetsBindingObserver {
  late RecipeBloc recipeBloc;
  late Recipe recipe;
  bool isScreenLocked = false;

  @override
  void initState() {
    super.initState();
    recipe = widget.recipe;
    recipeBloc = BlocProvider.of<RecipeBloc>(context);
    recipeBloc.add(FetchRecipe(id: recipe.id!));
    Wakelock.disable();
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
      recipeBloc.add(FetchRecipe(id: recipe.id!));
    }
  }

  void changeLockState() {
    setState(() {
      isScreenLocked = !isScreenLocked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Wakelock.disable();
          return true;
        },
        child: Scaffold(
            body: BlocConsumer<RecipeBloc, RecipeState>(
                listener: (context, state) {
                  if (state is RecipeDeleted) {
                    Navigator.pop(context);
                  } else if (state is RecipeUpdated) {
                    recipe = state.recipe;
                  }
                },
                builder: (context, state) {
                  if (state is RecipeFetched) {
                    if (widget.recipe.id == state.recipe.id) {
                      recipe = state.recipe;
                    }
                  } else if (state is RecipeFetchedFromCache) {
                    if (widget.recipe.id == state.recipe.id && state.recipe.steps.isNotEmpty) {
                      recipe = state.recipe;
                    }
                  }

                  return
                    DefaultTabController(
                      length: (recipe.hasNutritionalValues()) ? 3 : 2,
                      child: NestedScrollView(
                        headerSliverBuilder: (BuildContext hsbContext, bool innerBoxIsScrolled) {
                          return <Widget>[
                            sliverWidget(context, hsbContext, recipe, referer: widget.referer)
                          ];
                        },
                        body: Container(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            child: (state is RecipeLoading || (state is RecipeFetchedFromCache && state.recipe.steps.isEmpty))
                                ? buildLoading()
                                : RecipeDetailTabBarWidget(recipe: recipe)
                        ),
                      ),
                    );
                }
            )
            )
    );
  }

  Widget sliverWidget(BuildContext context, BuildContext hsbContext, Recipe recipe, {String? referer}) {
    String? lastCooked;
    List<Widget> keywordsWidget = [];

    if (recipe.lastCooked != null) {
      DateTime tempDate = DateTime.parse(recipe.lastCooked!).toLocal();
      lastCooked = DateFormat("dd.MM.yy").format(tempDate);
    }

    int keywordsLength = (recipe.keywords.length > 5) ? 5 : recipe.keywords.length;
    recipe.keywords.sublist(0, keywordsLength).forEach((keyword) {
      Widget? keywordWidget = getKeywordWidget(context, keyword);

      if (keywordWidget != null) {
        keywordsWidget.add(keywordWidget);
      }
    });

    return SliverOverlapAbsorber(
      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(hsbContext),
      sliver: MultiSliver(
        children: [
          SliverLayoutBuilder(
            builder: (BuildContext hsbContext, constraints) {
              final scrolled = constraints.scrollOffset > 0 && constraints.scrollOffset < 290;

              return StatefulBuilder(builder: (context, setState){
                return SliverAppBar(
                  leadingWidth: 50,
                  titleSpacing: 0,
                  automaticallyImplyLeading: false,
                  leading: IconButton(
                    iconSize: 30,
                    padding: const EdgeInsets.all(0),
                    onPressed: () {
                      Wakelock.disable();
                      Navigator.pop(hsbContext);
                    },
                    splashRadius: 20,
                    icon: const Icon(
                      Icons.chevron_left,
                    ),
                  ),
                  title: Text(
                    recipe.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                    ),
                  ),
                  actions: [
                    IconButton(
                      tooltip: AppLocalizations.of(context)!.screenLock,
                      splashRadius: 20,
                      onPressed: () {
                        changeLockState();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: (isScreenLocked) ? Text(AppLocalizations.of(context)!.enabledScreenLock) : Text(AppLocalizations.of(context)!.disabledScreenLock),
                            duration: const Duration(seconds: 3),
                          ),
                        );

                        Wakelock.toggle(enable: isScreenLocked);
                      },
                      icon: isScreenLocked ? const Icon(Icons.lock_outline) : const Icon(Icons.lock_open_outlined),
                    ),
                    IconButton(
                        tooltip: AppLocalizations.of(context)!.moreTooltip,
                        splashRadius: 20,
                        onPressed: () {
                          recipeMoreBottomSheet(context, recipe);
                        },
                        icon: const Icon(Icons.more_vert_outlined)
                    )
                  ],
                  elevation: (scrolled) ? 1.5 : 0,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  pinned: true,
                );
              });
            },
          ),
          SliverList(
              delegate: SliverChildListDelegate(
                  [
                    Stack(
                      children: [
                        SizedBox(
                          height: 250,
                          child: buildRecipeImage(recipe, BorderRadius.zero, 250, referer: referer),
                        ),
                        Container(
                            height: 250,
                            width: double.maxFinite,
                            alignment: Alignment.bottomLeft,
                            child: Wrap(
                                direction: Axis.horizontal,
                                children: keywordsWidget
                            )
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 45,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (lastCooked != null) Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                      Icons.restaurant_outlined,
                                      size: 13
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    lastCooked,
                                    style: const TextStyle(
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                AppLocalizations.of(context)!.lastCooked,
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.8)
                                ),
                              )
                            ],
                          ),
                          if (recipe.rating != null && recipe.rating! > 0) Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    recipe.rating.toString(),
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(
                                    Icons.star,
                                    size: 13,
                                    color: Colors.amberAccent,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                AppLocalizations.of(context)!.rating,
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.8)
                                ),
                              )
                            ],
                          ),
                          if (recipe.workingTime != null && recipe.workingTime! > 0) Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.timer_outlined,
                                    size: 13,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    recipe.workingTime!.minutesToTimeString(),
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                AppLocalizations.of(context)!.prepTime,
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.8)
                                ),
                              )
                            ],
                          ),
                          if (recipe.waitingTime != null && recipe.waitingTime! > 0) Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                      Icons.hourglass_bottom_outlined,
                                      size: 13
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    recipe.waitingTime!.minutesToTimeString(),
                                    style: const TextStyle(
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                AppLocalizations.of(context)!.waitingTime,
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.8)
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    )
                  ]
              )
          ),
          SliverPersistentHeader(
            delegate: _SliverAppBarDelegate(
              TabBar(
                tabs: [
                  Tab(text: AppLocalizations.of(context)!.ingredients),
                  Tab(text: AppLocalizations.of(context)!.directions),
                  if (recipe.hasNutritionalValues())
                    Tab(text: AppLocalizations.of(context)!.nutritionalValues),
                ],
              ),
            ),
            pinned: true,
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow:[
          BoxShadow(
              color: Colors.black12.withOpacity(0.45), //color of shadow
              spreadRadius: 0.2, //spread radius
              blurRadius: 0.7, // blur radius
              offset: const Offset(0, 0.5)
          ),
        ],
      ),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return true;
  }
}

Widget? getKeywordWidget(BuildContext context, Keyword keyword) {
  if (keyword.name != null || keyword.label != null) {
    String text = keyword.name ?? keyword.label!;
    return Container(
        padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
        margin: const EdgeInsets.fromLTRB(5, 5, 0, 5),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(30)
        ),
        child: Text(text, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onTertiaryContainer))
    );
  }

  return null;
}