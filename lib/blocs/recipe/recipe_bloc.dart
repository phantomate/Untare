import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tare/blocs/recipe/recipe_event.dart';
import 'package:tare/blocs/recipe/recipe_state.dart';
import 'package:tare/exceptions/api_exception.dart';
import 'package:tare/models/recipe.dart';
import 'package:tare/services/api/api_recipe.dart';

class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  final ApiRecipe apiRecipe;

  RecipeBloc({required this.apiRecipe}) : super(RecipeInitial()) {
    on<FetchRecipeList>(_onFetchRecipeList);
    on<FetchRecipe>(_onFetchRecipe);
    on<UpdateRecipe>(_onUpdateRecipe);
    on<CreateRecipe>(_onCreateRecipe);
    on<DeleteRecipe>(_onDeleteRecipe);
    on<AddIngredientsToShoppingList>(_onAddIngredientsToShoppingList);
    on<ImportRecipe>(_onImportRecipe);
  }

  Future<void> _onFetchRecipeList(FetchRecipeList event, Emitter<RecipeState> emit) async {
    emit(RecipeListLoading());
    try {
      List<Recipe> recipes = await apiRecipe.getRecipeList(event.query, event.random, event.page, event.pageSize, event.sortOrder);
      emit(RecipeListFetched(recipes: recipes));
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(RecipeUnauthorized());
      } else {
        emit(RecipeError(error: e.message ?? e.toString()));
      }
    } catch (e) {
      emit(RecipeError(error: e.toString()));
    }
  }

  Future<void> _onFetchRecipe(FetchRecipe event, Emitter<RecipeState> emit) async {
    emit(RecipeLoading());
    try {
      Recipe? recipe = await apiRecipe.getRecipe(event.id);

      if (recipe != null) {
        emit(RecipeFetched(recipe: recipe));
      } else {
        emit(RecipeError(error: 'No recipe found with id ' + event.id.toString()));
      }

    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(RecipeUnauthorized());
      } else {
        emit(RecipeError(error: e.message ?? e.toString()));
      }
    } catch (e) {
      emit(RecipeError(error: e.toString()));
    }
  }

  Future<void> _onUpdateRecipe(UpdateRecipe event, Emitter<RecipeState> emit) async {
    emit(RecipeLoading());
    try {
      Recipe? recipe = await apiRecipe.updateRecipe(event.recipe);
      if (event.image != null) {
        recipe = await apiRecipe.updateImage(recipe, event.image);
      }

      emit(RecipeUpdated(recipe: recipe));

    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(RecipeUnauthorized());
      } else {
        emit(RecipeError(error: e.message ?? e.toString()));
      }
    } catch (e) {
      emit(RecipeError(error: e.toString()));
    }
  }

  Future<void> _onCreateRecipe(CreateRecipe event, Emitter<RecipeState> emit) async {
    try {
      Recipe? recipe = await apiRecipe.createRecipe(event.recipe);
      if (event.image != null) {
        recipe = await apiRecipe.updateImage(recipe, event.image);
      }

      emit(RecipeCreated(recipe: recipe));

    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(RecipeUnauthorized());
      } else {
        emit(RecipeError(error: e.message ?? e.toString()));
      }
    } catch (e) {
      emit(RecipeError(error: e.toString()));
    }
  }

  Future<void> _onDeleteRecipe(DeleteRecipe event, Emitter<RecipeState> emit) async {
    try {
      Recipe? recipe = await apiRecipe.deleteRecipe(event.recipe);

      emit(RecipeDeleted(recipe: recipe));

    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(RecipeUnauthorized());
      } else {
        emit(RecipeError(error: e.message ?? e.toString()));
      }
    } catch (e) {
      emit(RecipeError(error: e.toString()));
    }
  }

  Future<void> _onAddIngredientsToShoppingList(AddIngredientsToShoppingList event, Emitter<RecipeState> emit) async {
    try {
      await apiRecipe.addIngredientsToShoppingList(event.recipeId, event.ingredientIds, event.servings);

      emit(RecipeAddedIngredientsToShoppingList());
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(RecipeUnauthorized());
      } else {
        emit(RecipeError(error: e.message ?? e.toString()));
      }
    } catch (e) {
      emit(RecipeError(error: e.toString()));
    }
  }

  Future<void> _onImportRecipe(ImportRecipe event, Emitter<RecipeState> emit) async {
    try {
      Recipe? recipe = await apiRecipe.importRecipe(event.url);

      emit(RecipeImported(recipe: recipe));

    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(RecipeUnauthorized());
      } else {
        emit(RecipeError(error: e.message ?? e.toString()));
      }
    } catch (e) {
      emit(RecipeError(error: e.toString()));
    }
  }
}