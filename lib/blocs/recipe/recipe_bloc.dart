import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tare/blocs/recipe/recipe_event.dart';
import 'package:tare/blocs/recipe/recipe_state.dart';
import 'package:tare/exceptions/api_exception.dart';
import 'package:tare/models/recipe.dart';
import 'package:tare/services/api/api_recipe.dart';

class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  final ApiRecipe apiRecipe;

  RecipeBloc({required this.apiRecipe}) : super(RecipeInitial()) {
    on<FetchRecipe>(_onFetchRecipe);
    on<UpdateRecipe>(_onUpdateRecipe);
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
}