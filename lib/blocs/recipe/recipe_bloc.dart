import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tare/blocs/recipe/recipe_event.dart';
import 'package:tare/blocs/recipe/recipe_state.dart';
import 'package:tare/exceptions/api_connection_exception.dart';
import 'package:tare/exceptions/api_exception.dart';
import 'package:tare/models/recipe.dart';
import 'package:tare/services/api/api_recipe.dart';
import 'package:tare/services/cache/cache_recipe_service.dart';

class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  final ApiRecipe apiRecipe;
  final CacheRecipeService cacheRecipeService;

  RecipeBloc({required this.apiRecipe, required this.cacheRecipeService}) : super(RecipeInitial()) {
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
      List<Recipe>? cacheRecipes = cacheRecipeService.getRecipeList(event.query, event.random, event.page, event.pageSize, event.sortOrder);

      if (cacheRecipes != null && cacheRecipes.isNotEmpty) {
        emit(RecipeListFetchedFromCache(recipes: cacheRecipes, page: event.page));
      }

      List<Recipe> recipes = await apiRecipe.getRecipeList(event.query, event.random, event.page, event.pageSize, event.sortOrder);
      if (recipes.isNotEmpty) {
        emit(RecipeListFetched(recipes: recipes, page: event.page));
        cacheRecipeService.upsertRecipeList(recipes);
      }
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(RecipeUnauthorized());
      } else {
        emit(RecipeError(error: e.message ?? e.toString()));
      }
    } on ApiConnectionException catch (e) {
      // Do nothing
    } catch (e) {
      emit(RecipeError(error: e.toString()));
    }
  }

  Future<void> _onFetchRecipe(FetchRecipe event, Emitter<RecipeState> emit) async {
    emit(RecipeLoading());
    try {
      Recipe? cachedRecipe = cacheRecipeService.getRecipe(event.id);

      if (cachedRecipe != null) {
        emit(RecipeFetchedFromCache(recipe: cachedRecipe));
      }

      Recipe? recipe = await apiRecipe.getRecipe(event.id);

      if (recipe != null) {
        emit(RecipeFetched(recipe: recipe));
        cacheRecipeService.upsertRecipe(recipe);
      } else {
        emit(RecipeError(error: 'No recipe found with id ' + event.id.toString()));
      }

    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(RecipeUnauthorized());
      } else {
        emit(RecipeError(error: e.message ?? e.toString()));
      }
    } on ApiConnectionException catch (e) {
      // Do nothing
    } catch (e) {
      emit(RecipeError(error: e.toString()));
    }
  }

  Future<void> _onUpdateRecipe(UpdateRecipe event, Emitter<RecipeState> emit) async {
    emit(RecipeProcessing(processingString: 'updatingRecipe'));
    try {
      Recipe? recipe = await apiRecipe.updateRecipe(event.recipe);
      if (event.image != null) {
        recipe = await apiRecipe.updateImage(recipe, event.image);
      }

      emit(RecipeUpdated(recipe: recipe));
      cacheRecipeService.upsertRecipe(recipe);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(RecipeUnauthorized());
      } else {
        emit(RecipeError(error: e.message ?? e.toString()));
      }
    } on ApiConnectionException catch (e) {
      emit(RecipeUpdated(recipe: event.recipe));
      cacheRecipeService.upsertRecipe(event.recipe);
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
      cacheRecipeService.upsertRecipe(recipe);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(RecipeUnauthorized());
      } else {
        emit(RecipeError(error: e.message ?? e.toString()));
      }
    } on ApiConnectionException catch (e) {
      emit(RecipeCreated(recipe: event.recipe));
    } catch (e) {
      emit(RecipeError(error: e.toString()));
    }
  }

  Future<void> _onDeleteRecipe(DeleteRecipe event, Emitter<RecipeState> emit) async {
    try {
      Recipe? recipe = await apiRecipe.deleteRecipe(event.recipe);

      emit(RecipeDeleted(recipe: recipe));
      cacheRecipeService.deleteRecipe(recipe);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(RecipeUnauthorized());
      } else {
        emit(RecipeError(error: e.message ?? e.toString()));
      }
    } on ApiConnectionException catch (e) {
      emit(RecipeDeleted(recipe: event.recipe));
      cacheRecipeService.deleteRecipe(event.recipe);
    } catch (e) {
      emit(RecipeError(error: e.toString()));
    }
  }

  Future<void> _onAddIngredientsToShoppingList(AddIngredientsToShoppingList event, Emitter<RecipeState> emit) async {
    emit(RecipeProcessing(processingString: 'addingIngredientsToShoppingList'));
    try {
      await apiRecipe.addIngredientsToShoppingList(event.recipeId, event.ingredientIds, event.servings);

      emit(RecipeAddedIngredientsToShoppingList());
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(RecipeUnauthorized());
      } else {
        emit(RecipeError(error: e.message ?? e.toString()));
      }
    } on ApiConnectionException catch (e) {
      // Do nothing
    } catch (e) {
      emit(RecipeError(error: e.toString()));
    }
  }

  Future<void> _onImportRecipe(ImportRecipe event, Emitter<RecipeState> emit) async {
    emit(RecipeProcessing(processingString: 'importingRecipe'));
    try {
      Recipe? recipe = await apiRecipe.importRecipe(event.url);

      emit(RecipeImported(recipe: recipe));

    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(RecipeUnauthorized());
      } else {
        emit(RecipeError(error: e.message ?? e.toString()));
      }
    } on ApiConnectionException catch (e) {
      // Do nothing
    } catch (e) {
      emit(RecipeError(error: e.toString()));
    }
  }
}