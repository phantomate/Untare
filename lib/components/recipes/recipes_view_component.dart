import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tare/blocs/abstract_state.dart';
import 'package:tare/blocs/recipe/recipe_state.dart';
import 'package:tare/components/custom_scroll_notification.dart';
import 'package:tare/components/recipes/recipe_grid_component.dart';
import 'package:tare/components/recipes/recipe_list_component.dart';
import 'package:tare/components/recipes/recipes_grid_component.dart';
import 'package:tare/components/recipes/recipes_list_component.dart';
import 'package:tare/components/widgets/hide_bottom_nav_bar_stateful_widget.dart';
import 'package:tare/components/loading_component.dart';
import 'package:tare/cubits/recipe_layout_cubit.dart';
import 'package:tare/models/recipe.dart';

Widget buildRecipesView(List<Recipe> recipes, AbstractState state, HideBottomNavBarStatefulWidget widget, BuildContext context) {
  final CustomScrollNotification customScrollNotification = CustomScrollNotification(widget: widget);
  final List<Widget> recipesWidgetList = [];

  if (state is RecipeListLoading) {
    recipesWidgetList.add(buildLoading());
  }

  if (recipes.length == 0) {
    if (state is RecipeListFetched) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text('No recipes found'),
        )
      );
    } else {
      return Center();
    }
  } else {
    return BlocBuilder<RecipeLayoutCubit, String>(
      builder: (context, layout) {
        recipesWidgetList.clear();
        if (layout == 'list') {
          recipesWidgetList.addAll(recipes.map((item) => recipeListComponent(item, context)).toList());
        } else {
          recipesWidgetList.addAll(recipes.map((item) => recipeGridComponent(item, context)).toList());
        }

        return NotificationListener<ScrollNotification>(
            onNotification: customScrollNotification.handleScrollNotification,
            child: LayoutBuilder(
                builder: (lbContext, constraints) {
                  Widget recipesWidget;
                  if (layout == 'list') {
                    recipesWidget = buildRecipesList(recipesWidgetList);
                  } else {
                    recipesWidget = buildRecipesGrid(recipesWidgetList, constraints);
                  }

                  return Container(
                      padding: const EdgeInsets.only(right: 12, bottom: 0, left: 12),
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        cacheExtent: recipesWidgetList.length * 100,
                        slivers: <Widget>[
                          recipesWidget
                        ],
                      )
                  );
                }
            )
        );
      }
    );
  }
}
