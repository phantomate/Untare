// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:untare/models/recipe.dart';

import '../abstract_event.dart';

abstract class RecipeEvent extends AbstractEvent {}

class FetchRecipe extends RecipeEvent {
  final int id;

  FetchRecipe({required this.id});
}

class UpdateRecipe extends RecipeEvent {
  final Recipe recipe;
  final image;

  UpdateRecipe({required this.recipe, this.image});
}

class CreateRecipe extends RecipeEvent {
  final Recipe recipe;
  final image;

  CreateRecipe({required this.recipe, this.image});
}

class DeleteRecipe extends RecipeEvent {
  final Recipe recipe;

  DeleteRecipe({required this.recipe});
}

class ImportRecipe extends RecipeEvent {
  final String url;
  final bool splitDirections;
  ImportRecipe({required this.url, required this.splitDirections});
}

class AddIngredientsToShoppingList extends RecipeEvent {
  final int recipeId;
  final List<int> ingredientIds;
  final int servings;

  AddIngredientsToShoppingList({required this.recipeId, required this.ingredientIds, required this.servings});
}

class FetchRecipeList extends RecipeEvent {
  final String query;
  final bool random;
  final int page;
  final int pageSize;
  final String? sortOrder;

  FetchRecipeList({required this.query, required this.random, required this.page, required this.pageSize, this.sortOrder});
}