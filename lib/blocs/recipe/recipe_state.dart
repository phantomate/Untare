import 'package:tare/blocs/abstract_state.dart';
import 'package:tare/models/recipe.dart';

abstract class RecipeState extends AbstractState{}

class RecipeInitial extends RecipeState {}

class RecipeLoading extends RecipeState {}

class RecipeFetched extends RecipeState {
  final Recipe recipe;
  RecipeFetched({required this.recipe});
}

class RecipeUpdated extends RecipeState {
  final Recipe recipe;
  RecipeUpdated({required this.recipe});
}

class RecipeError extends RecipeState {
  final String error;

  RecipeError({required this.error});

  @override
  List<Object> get props => [error];
}

class RecipeUnauthorized extends RecipeState {}