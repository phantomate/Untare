import 'package:tare/models/recipe.dart';

import '../abstract_event.dart';

abstract class RecipeEvent extends AbstractEvent {}

class FetchRecipe extends RecipeEvent {
  final int id;

  FetchRecipe({required this.id});
}

class UpdateRecipe extends RecipeEvent {
  final Recipe recipe;

  UpdateRecipe({required this.recipe});
}