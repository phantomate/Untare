import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:tare/blocs/recipe/recipe_bloc.dart';
import 'package:tare/blocs/recipe/recipe_event.dart';
import 'package:tare/blocs/recipe/recipe_state.dart';
import 'package:tare/components/bottom_sheets/sort_bottom_sheet_component.dart';
import 'package:tare/components/recipes/recipes_view_component.dart';
import 'package:tare/components/widgets/hide_bottom_nav_bar_stateful_widget.dart';
import 'package:tare/components/loading_component.dart';
import 'package:tare/components/widgets/search_stateful_widget.dart';
import 'package:tare/constants/colors.dart';
import 'package:tare/models/recipe.dart';
import 'package:tare/pages/recipe_upsert_page.dart';


class RecipesPage extends HideBottomNavBarStatefulWidget {
  RecipesPage({required isHideBottomNavBar}) : super(isHideBottomNavBar: isHideBottomNavBar);

  @override
  _RecipesPageState createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  int pageSize = 20;
  final _scrollController = ScrollController();
  final _scrollThreshold = 800.0;
  late RecipeBloc recipeBloc;
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
    _scrollController.addListener(_onScroll);
    recipeBloc = BlocProvider.of<RecipeBloc>(context);
    recipeBloc.add(FetchRecipeList(query: query, random: random, page: page, pageSize: pageSize));
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      if(recipeBloc.state is RecipeListFetched && !isLastPage) {
        page += 1;
        recipeBloc.add(FetchRecipeList(query: query, random: random, page: page, pageSize: pageSize));
      }
    }
  }

  _onSearchValueChange(String searchQuery) {
    if (!identical(query, searchQuery)) {
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

  _openSortBottomSheet() {
    sortBottomSheet(context, onSortSelected);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          sliverAppBar(context, _onSearchValueChange, innerBoxIsScrolled)
        ];
      },
      body: Container(
          child: BlocConsumer<RecipeBloc, RecipeState>(
              listener: (context, state) {
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
                }
              },
              builder: (context, state) {
                if (state is RecipeInitial) {
                  return buildLoading();
                } else if (state is RecipeListFetched || state is RecipeListLoading) {
                  if (state is RecipeListFetched) {
                    if (state.recipes.isEmpty) {
                      isLastPage = true;
                    }

                    recipes.addAll(state.recipes);
                  }
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      padding: const EdgeInsets.only(left: 12, top: 10),
                      //alignment: Alignment.topLeft,
                      child: TextButton(
                          onPressed: _openSortBottomSheet,
                          child: Row(
                            children: [
                              Text(
                                'Filter',
                                style: TextStyle(
                                    color: Colors.black54
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down_outlined,
                                color: Colors.black54,
                              )
                            ],
                          )
                      ),
                    ),
                    Expanded(
                        child: buildRecipesView(recipes, state, widget, context)
                    )
                  ],
                );
              }
          )
      ),
    );
  }
}

Widget sliverAppBar(BuildContext context, Function(String) _onSearchValueChange, bool innerBoxIsScrolled) {
  return SliverAppBar(
    title: Row(
      children: [
        Text(
          'Recipes',
          style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.black87
          ),
        ),
      ],
    ),
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    pinned: true,
    stretch: true,
    forceElevated: innerBoxIsScrolled,
    elevation: 1.5,
    actions: [
      Container(
        padding: const EdgeInsets.only(top: 12, bottom: 12),
        child: SearchWidget(onSearchValueChange: _onSearchValueChange),
      ),
      IconButton(
          tooltip: 'Add recipe',
          splashRadius: 20,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RecipeUpsertPage()),
            );
          },
          icon: Icon(
            Icons.add,
            color: Colors.black54,
          )
      )
    ],
  );
}