import 'package:tare/blocs/abstract_state.dart';
import 'package:tare/models/recipe.dart';

abstract class RecipesState extends AbstractState {}

class RecipesInitial extends RecipesState {}

class RecipesLoading extends RecipesState {}

class RecipesFetched extends RecipesState {
  final List<Recipe> recipes;
  RecipesFetched({required this.recipes});
}

class RecipesError extends RecipesState {
  final String error;

  RecipesError({required this.error});

  @override
  List<Object> get props => [error];
}

class RecipesUnauthorized extends RecipesState {}