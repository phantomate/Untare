import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:hive/hive.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:untare/blocs/recipe/recipe_bloc.dart';
import 'package:untare/blocs/recipe/recipe_event.dart';
import 'package:untare/blocs/recipe/recipe_state.dart';
import 'package:untare/components/bottom_sheets/recipes_more_bottom_sheet_component.dart';
import 'package:untare/components/dialogs/import_recipe_website_dialog.dart';
import 'package:untare/components/bottom_sheets/sort_bottom_sheet_component.dart';
import 'package:untare/components/recipes/recipes_view_component.dart';
import 'package:untare/components/widgets/hide_bottom_nav_bar_stateful_widget.dart';
import 'package:untare/components/loading_component.dart';
import 'package:untare/models/recipe.dart';
import 'package:untare/pages/recipe_detail_page.dart';
import 'package:untare/pages/recipe_upsert_page.dart';
import 'package:untare/services/cache/cache_recipe_service.dart';


class RecipesPage extends HideBottomNavBarStatefulWidget {
  const RecipesPage({super.key, required super.isHideBottomNavBar});

  @override
  RecipesPageState createState() => RecipesPageState();
}

class RecipesPageState extends State<RecipesPage> {
  int pageSize = 30;
  final searchTextController = TextEditingController();
  late StreamSubscription _intentSub;
  late RecipeBloc recipeBloc;
  bool showSearchClear = false;
  List<Recipe> recipes = [];
  List<Recipe> fetchedRecipes = [];
  List<Recipe> cachedRecipes = [];
  bool isLastPage = false;
  int page = 1;
  String query = '';
  bool random = false;
  String? sortOrder;
  Map<String, bool> sortMap = {
    'score': true,
    'name': true,
    'lastcooked': true,
    'rating': true,
    'favorite': true,
    'created_at': true
  };
  bool isLoading = false;
  var box = Hive.box('unTaReBox');

  @override
  void initState() {
    super.initState();
    widget.isHideBottomNavBar(true);
    searchTextController.addListener(onSearchValueChange);
    recipeBloc = BlocProvider.of<RecipeBloc>(context);
    isLoading = true;
    recipeBloc.add(FetchRecipeList(query: query, random: random, page: page, pageSize: pageSize, sortOrder: sortOrder));

    // Listen to media sharing coming from outside the app while the app is in the memory.
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen((value) {
      setState(() {
        openOrImportRecipeIntend(value);
      });
    }, onError: (err) {

    });

    // Get the media sharing coming from outside the app while the app is closed.
    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      setState(() {
        openOrImportRecipeIntend(value);
        // Tell the library that we are done processing the intent.
        ReceiveSharingIntent.instance.reset();
      });
    });
  }

  void openOrImportRecipeIntend(List<SharedMediaFile> value) {
    // If it's a link from tandoor recipes, try to open the recipe. Otherwise import it
    if (value.isNotEmpty) {
      if (value.first.path.contains(box.get('url'))) {
        if (value.first.path.contains('/recipe/')) {
          String recipeId = value.first.path.substring(value.first.path.indexOf('/recipe/')+8, value.first.path.length);
          final CacheRecipeService cacheRecipeService = CacheRecipeService();
          Recipe? cacheRecipe = cacheRecipeService.getRecipe(int.parse(recipeId));

          if (cacheRecipe != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RecipeDetailPage(recipe: cacheRecipe)),
            );
          }
        }
      } else {
        recipeBloc.add(
            ImportRecipe(
                url: value.first.path,
                splitDirections: true
            )
        );
      }
    }
  }

  void fetchMoreRecipes() {
    if((recipeBloc.state is RecipeListFetched || recipeBloc.state is RecipeListFetchedFromCache
        || recipeBloc.state is RecipeFetched || recipeBloc.state is RecipeFetchedFromCache)
        && !isLastPage) {
      isLoading = true;
      page++;
      recipeBloc.add(FetchRecipeList(query: query, random: random, page: page, pageSize: pageSize, sortOrder: sortOrder));
    }
  }

  onSearchValueChange() {
    String searchQuery = searchTextController.text;
    if (searchQuery != '' && !showSearchClear) {
      setState(() {
        showSearchClear = true;
      });
    } else if (searchQuery == '' && showSearchClear) {
      setState(() {
        showSearchClear = false;
      });
    }

    if (query != searchQuery) {
      query = searchQuery;
      page = 1;
      random = false;
      recipes = [];
      fetchedRecipes = [];
      cachedRecipes = [];
      recipeBloc.add(FetchRecipeList(query: query, random: random, page: page, pageSize: pageSize, sortOrder: sortOrder));
    }
  }

  void onSortSelected(String selected, bool isAsc) {
    sortOrder = (!isAsc) ? '-$selected' : selected;

    sortMap[selected] = !isAsc;

    page = 1;
    recipes = [];
    fetchedRecipes = [];
    cachedRecipes = [];
    recipeBloc.add(FetchRecipeList(query: query, random: random, page: page, pageSize: pageSize, sortOrder: sortOrder));
  }

  @override
  void dispose() {
    searchTextController.dispose();
    _intentSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext hsbContext, bool innerBoxIsScrolled) {
          return <Widget>[
            sliverAppBarWidget(context, innerBoxIsScrolled, searchTextController, onSortSelected, showSearchClear, sortMap),
          ];
        },
        body: BlocConsumer<RecipeBloc, RecipeState>(
            listener: (context, state) {
              if (state is RecipeListFetched) {
                isLastPage = false;
                if (state.recipes.isEmpty || state.recipes.length < pageSize) {
                  isLastPage = true;
                }
                isLoading = false;
                recipes.addAll(state.recipes);
              } else if (state is RecipeListFetchedFromCache) {
                if (state.recipes.isEmpty || state.recipes.length < pageSize) {
                  isLastPage = true;
                }
                isLoading = false;
                recipes.addAll(state.recipes);
              }

              if (state is RecipeError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error),
                    duration: const Duration(seconds: 8),
                  ),
                );
              } else if (state is RecipeUnauthorized) {
                Phoenix.rebirth(context);
              } else if (state is RecipeCreated) {
                recipes.add(state.recipe);
              } else if (state is RecipeUpdated) {
                recipes[recipes.indexWhere((element) => element.id == state.recipe.id)] = state.recipe;
              } else if (state is RecipeDeleted) {
                recipes.removeWhere((element) => element.id == state.recipe.id);
              } else if (state is RecipeImported) {
                if (state.recipe.id != null) {
                  recipes.add(state.recipe);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.importedRecipe),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RecipeUpsertPage(recipe: state.recipe, splitDirections: state.spiltDirections)),
                  );
                }
              }
            },
            builder: (context, state) {
              if (state is RecipeInitial) {
                return buildLoading();
              }

              return LazyLoadScrollView(
                  onEndOfPage: fetchMoreRecipes,
                  child: buildRecipesView(recipes, state, widget, context, isLoading)
              );
            }
        ),
      ),
    );
  }
}

Widget sliverAppBarWidget(BuildContext context, bool innerBoxIsScrolled, TextEditingController searchTextController, Function(String, bool) onSortSelected, bool showSearchClear, Map<String, bool> sortMap) {
  return SliverAppBar(
    expandedHeight: 120,
    flexibleSpace: FlexibleSpaceBar(
      titlePadding: const EdgeInsets.fromLTRB(15, 0, 0, 60),
      expandedTitleScale: 1.3,
      title: Text(
        AppLocalizations.of(context)!.recipesTitle,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: (Theme.of(context).appBarTheme.titleTextStyle != null) ? Theme.of(context).appBarTheme.titleTextStyle!.color : null
        ),
      ),
    ),
    pinned: true,
    stretch: true,
    forceElevated: innerBoxIsScrolled,
    elevation: 1.5,
    bottom: PreferredSize(
      preferredSize: const Size(double.maxFinite, 50),
      child: Container(
        height: 50,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        child: SearchBar(
          backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.surfaceContainer),
          controller: searchTextController,
          elevation: WidgetStateProperty.all(0),
          leading: Icon(Icons.search_rounded, color: Theme.of(context).colorScheme.secondary),
          trailing: <Widget>[
              IconButton(
                tooltip: AppLocalizations.of(context)!.sort,
                splashRadius: 20,
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  sortBottomSheet(context, onSortSelected, sortMap);
                },
                icon: const Icon(
                  Icons.sort_outlined,
                )
            )
          ],
        ),
      ),
    ),
    actions: [
      PopupMenuButton(
        tooltip: AppLocalizations.of(context)!.recipesTooltipAddRecipe,
        icon: const Icon(
          Icons.add,
        ),
        elevation: 3,
        shape: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(8)
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 1,
            child: Text(AppLocalizations.of(context)!.create),
          ),
          PopupMenuItem(
            value: 2,
            child: Text(AppLocalizations.of(context)!.import),
          )
        ],
        onSelected: (value) {
          if (value == 1) {
            FocusManager.instance.primaryFocus?.unfocus();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RecipeUpsertPage()),
            );
          } else if (value == 2) {
            FocusManager.instance.primaryFocus?.unfocus();
            importRecipeWebsiteDialog(context);
          }
        },
      ),
      IconButton(
          tooltip: AppLocalizations.of(context)!.moreTooltip,
          splashRadius: 20,
          onPressed: () {
            FocusManager.instance.primaryFocus?.unfocus();
            recipesBottomSheet(context);
          },
          icon: const Icon(Icons.more_vert_outlined)
      )
    ],
  );
}