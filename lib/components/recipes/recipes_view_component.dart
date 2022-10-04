import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untare/blocs/abstract_state.dart';
import 'package:untare/blocs/recipe/recipe_state.dart';
import 'package:untare/components/custom_scroll_notification.dart';
import 'package:untare/components/recipes/recipe_grid_component.dart';
import 'package:untare/components/recipes/recipe_list_component.dart';
import 'package:untare/components/recipes/recipes_grid_component.dart';
import 'package:untare/components/recipes/recipes_list_component.dart';
import 'package:untare/components/widgets/hide_bottom_nav_bar_stateful_widget.dart';
import 'package:untare/components/loading_component.dart';
import 'package:untare/cubits/settings_cubit.dart';
import 'package:untare/models/app_setting.dart';
import 'package:untare/models/recipe.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';

Widget buildRecipesView(List<Recipe> recipes, RecipeState state, HideBottomNavBarStatefulWidget widget, BuildContext context, bool isLoading) {
  final CustomScrollNotification customScrollNotification = CustomScrollNotification(widget: widget);
  final List<Widget> recipesWidgetList = [];

  if (recipes.isEmpty) {
    if (state is RecipeListFetched) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(AppLocalizations.of(context)!.noRecipesFound),
        )
      );
    } else {
      return buildLoading();
    }
  } else {
    return BlocBuilder<SettingsCubit, AppSetting>(
      builder: (context, setting) {
        recipesWidgetList.clear();
        if (setting.layout == 'list') {
          recipesWidgetList.addAll(recipes.map((item) => recipeListComponent(item, context)).toList());
        } else {
          recipesWidgetList.addAll(recipes.map((item) => recipeGridComponent(item, context)).toList());
        }

        return NotificationListener<ScrollNotification>(
            onNotification: customScrollNotification.handleScrollNotification,
            child: LayoutBuilder(
                builder: (lbContext, constraints) {
                  Widget recipesWidget;
                  if (setting.layout == 'list') {
                    recipesWidget = buildRecipesList(recipesWidgetList);
                  } else {
                    recipesWidget = buildRecipesGrid(recipesWidgetList, constraints);
                  }

                  return Container(
                      padding: const EdgeInsets.only(right: 12, bottom: 0, left: 12, top: 15),
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        cacheExtent: recipesWidgetList.length * 100,
                        slivers: <Widget>[
                          recipesWidget,
                          if (state is RecipeListLoading || isLoading)
                            SliverToBoxAdapter(child: buildLoading()),
                          const SliverPadding(padding: EdgeInsets.only(bottom: 15))
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
