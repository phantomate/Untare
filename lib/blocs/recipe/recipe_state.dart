import 'package:tare/blocs/abstract_state.dart';
import 'package:tare/models/recipe.dart';

abstract class RecipeState extends AbstractState{}

class RecipeInitial extends RecipeState {}

class RecipeLoading extends RecipeState {}

class RecipeProcessing extends RecipeState {
  final String processingString;
  RecipeProcessing({required this.processingString});
}

class RecipeFetched extends RecipeState {
  final Recipe recipe;
  RecipeFetched({required this.recipe});
}

class RecipeUpdated extends RecipeState {
  final Recipe recipe;
  RecipeUpdated({required this.recipe});
}

class RecipeCreated extends RecipeState {
  final Recipe recipe;
  RecipeCreated({required this.recipe});
}

class RecipeDeleted extends RecipeState {
  final Recipe recipe;
  RecipeDeleted({required this.recipe});
}

class RecipeImported extends RecipeState {
  final Recipe recipe;
  RecipeImported({required this.recipe});
}

class RecipeAddedIngredientsToShoppingList extends RecipeState {}

class RecipeListLoading extends RecipeState {}

class RecipeListFetched extends RecipeState {
  final List<Recipe> recipes;
  RecipeListFetched({required this.recipes});
}

class RecipeError extends RecipeState {
  final String error;

  RecipeError({required this.error});

  @override
  List<Object> get props => [error];
}

class RecipeUnauthorized extends RecipeState {}