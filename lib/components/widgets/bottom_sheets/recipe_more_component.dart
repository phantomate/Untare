import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_locales.dart';
import 'package:untare/blocs/recipe/recipe_bloc.dart';
import 'package:untare/blocs/recipe/recipe_event.dart';
import 'package:untare/components/bottom_sheets/recipe_shopping_list_bottom_sheet_component.dart';
import 'package:untare/components/dialogs/delete_recipe_dialog.dart';
import 'package:untare/components/dialogs/upsert_meal_plan_entry_dialog.dart';
import 'package:untare/models/recipe.dart';
import 'package:untare/pages/recipe_upsert_page.dart';
import 'package:url_launcher/url_launcher.dart';

Widget buildRecipeMore(BuildContext context, BuildContext btsContext, Recipe recipe) {
  RecipeBloc recipeBloc = BlocProvider.of<RecipeBloc>(context);

  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.only(left: 12, right: 12, bottom: 6),
    child: Column(
      children: [
        if (recipe.sourceUrl != null)
          ListTile(
            minLeadingWidth: 35,
            enabled: (recipe.sourceUrl != null),
            onTap: () {
              launchUrl(Uri.parse(recipe.sourceUrl!));
              Navigator.pop(btsContext);
            },
            leading: const Icon(Icons.open_in_browser_outlined),
            title: Text(AppLocalizations.of(context)!.openInBrowser),
          ),
        ListTile(
          minLeadingWidth: 35,
          onTap: () {
            recipeBloc.add(ShareLink(recipeId: recipe.id!));

            Navigator.pop(btsContext);
          },
          leading: const Icon(Icons.share_outlined),
          title: Text(AppLocalizations.of(context)!.share),
        ),
        ListTile(
          minLeadingWidth: 35,
          onTap: () {
            Navigator.pop(btsContext);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RecipeUpsertPage(recipe: recipe)),
            );
          },
          leading: const Icon(Icons.edit_outlined),
          title: Text(AppLocalizations.of(context)!.edit),
        ),
        ListTile(
          minLeadingWidth: 35,
          onTap: () {
            Navigator.pop(btsContext);
            upsertMealPlanEntryDialog(context, recipe: recipe, referer: 'recipe');
          },
          leading: const Icon(Icons.calendar_today_outlined),
          title: Text(AppLocalizations.of(context)!.addToMealPlan),
        ),
        ListTile(
          minLeadingWidth: 35,
          onTap: () {
            Navigator.pop(btsContext);
            recipeShoppingListBottomSheet(context, recipe);
          },
          leading: const Icon(Icons.add_shopping_cart_outlined),
          title: Text(AppLocalizations.of(context)!.addToShoppingList),
        ),
        const Divider(),
        ListTile(
          minLeadingWidth: 35,
          onTap: () {
            Navigator.pop(btsContext);
            deleteRecipeDialog(context, recipe);
          },
          leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
          title: Text(
            AppLocalizations.of(context)!.remove,
            style: const TextStyle(color: Colors.redAccent),
          ),
        )
      ],
    ),
  );
}