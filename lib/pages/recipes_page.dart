import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:tare/blocs/recipe/recipe_bloc.dart';
import 'package:tare/blocs/recipe/recipe_event.dart';
import 'package:tare/blocs/recipe/recipe_state.dart';
import 'package:tare/components/dialogs/import_recipe_website_dialog.dart';
import 'package:tare/components/bottom_sheets/sort_bottom_sheet_component.dart';
import 'package:tare/components/recipes/recipes_view_component.dart';
import 'package:tare/components/widgets/hide_bottom_nav_bar_stateful_widget.dart';
import 'package:tare/components/loading_component.dart';
import 'package:tare/models/recipe.dart';
import 'package:tare/pages/recipe_upsert_page.dart';


class RecipesPage extends HideBottomNavBarStatefulWidget {
  RecipesPage({required isHideBottomNavBar}) : super(isHideBottomNavBar: isHideBottomNavBar);

  @override
  _RecipesPageState createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  int pageSize = 20;
  final searchTextController = TextEditingController();
  late RecipeBloc recipeBloc;
  bool showSearchClear = false;
  List<Recipe> recipes = [];
  bool isLastPage = false;
  int page = 1;
  String query = '';
  bool random = false;
  String? sortOrder;

  @override
  void initState() {
    super.initState();
    widget.isHideBottomNavBar(true);
    searchTextController.addListener(_onSearchValueChange);
    recipeBloc = BlocProvider.of<RecipeBloc>(context);
    recipeBloc.add(FetchRecipeList(query: query, random: random, page: page, pageSize: pageSize));
  }

  void _fetchMoreRecipes() {
    if(recipeBloc.state is RecipeListFetched && !isLastPage) {
      page += 1;
      recipeBloc.add(FetchRecipeList(query: query, random: random, page: page, pageSize: pageSize));
    }
  }

  _onSearchValueChange() {
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
      recipeBloc.add(FetchRecipeList(query: query, random: random, page: page, pageSize: pageSize));
    }
  }

  void onSortSelected(selected) {
    sortOrder = selected;
    page = 1;
    recipes = [];
    recipeBloc.add(FetchRecipeList(query: query, random: random, page: page, pageSize: pageSize, sortOrder: sortOrder));
  }

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext hsbContext, bool innerBoxIsScrolled) {
        return <Widget>[
          sliverAppBarWidget(context, innerBoxIsScrolled, searchTextController, onSortSelected, showSearchClear),
        ];
      },
      body: Container(
          child: BlocConsumer<RecipeBloc, RecipeState>(
              listener: (context, state) {
                if (state is RecipeListFetched) {
                  if (state.recipes.isEmpty) {
                    isLastPage = true;
                  }
                  recipes.addAll(state.recipes);
                }

                if (state is RecipeError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error),
                      duration: Duration(seconds: 8),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RecipeUpsertPage(recipe: state.recipe)),
                  );
                }
              },
              builder: (context, state) {
                if (state is RecipeInitial) {
                  return buildLoading();
                }

                return LazyLoadScrollView(
                  onEndOfPage: () => _fetchMoreRecipes(),
                  scrollOffset: 80,
                  child: buildRecipesView(recipes, state, widget, context),
                );
              }
          )
      ),
    );
  }
}

Widget sliverAppBarWidget(BuildContext context, bool innerBoxIsScrolled, TextEditingController searchTextController, Function(String) onSortSelected, bool showSearchClear) {
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
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    pinned: true,
    stretch: true,
    forceElevated: innerBoxIsScrolled,
    elevation: 1.5,
    bottom: PreferredSize(
      preferredSize: Size(double.maxFinite, 42),
      child: Container(
        height: 42,
        padding: const EdgeInsets.fromLTRB(40, 0, 30, 10),
        child:  Row(
          children: [
            Flexible(
              child: TextField(
                controller: searchTextController,
                cursorColor: Theme.of(context).primaryColor,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.search,
                  contentPadding: const EdgeInsets.only(top: 10),
                  prefixIcon: Icon(Icons.search_outlined),
                  suffixIcon: showSearchClear ? IconButton(
                    splashRadius: 1,
                    padding: const EdgeInsets.fromLTRB(8, 7, 8, 8),
                    icon: Icon(Icons.clear_outlined),
                    onPressed: () {
                      searchTextController.clear();
                    },
                  ) : null,
                  fillColor: (Theme.of(context).brightness.name == 'light') ? Colors.grey[200] : Colors.grey[700],
                  focusedBorder:  OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent, width: 0.0),
                    borderRadius: const BorderRadius.all(const Radius.circular(30.0)),
                  ),
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent, width: 0.0),
                    borderRadius: const BorderRadius.all(const Radius.circular(30.0)),
                  ),
                ),
              ),
            ),
            IconButton(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                tooltip: AppLocalizations.of(context)!.sort,
                splashRadius: 20,
                onPressed: () => sortBottomSheet(context, onSortSelected),
                icon: Icon(
                  Icons.sort_outlined,
                )
            )
          ],
        )
      ),
    ),
    actions: [
      PopupMenuButton(
        tooltip: AppLocalizations.of(context)!.recipesTooltipAddRecipe,
        icon: Icon(
          Icons.add,
        ),
        elevation: 3,
        shape: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(8)
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            child: Text(AppLocalizations.of(context)!.create),
            value: 1,
          ),
          PopupMenuItem(
            child: Text(AppLocalizations.of(context)!.import),
            value: 2,
          )
        ],
        onSelected: (value) {
          if (value == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RecipeUpsertPage()),
            );
          } else if (value == 2) {
            importRecipeWebsiteDialog(context);
          }
        },
      ),
    ],
  );
}