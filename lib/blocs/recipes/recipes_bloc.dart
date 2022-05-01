import 'package:tare/blocs/recipes/recipes_event.dart';
import 'package:tare/blocs/recipes/recipes_state.dart';
import 'package:bloc/bloc.dart';
import 'package:tare/exceptions/api_exception.dart';
import 'package:tare/models/recipe.dart';
import 'package:tare/services/api/api_recipe.dart';

class RecipesBloc extends Bloc<RecipesEvent, RecipesState> {
  final ApiRecipe apiRecipe;

  RecipesBloc({required this.apiRecipe}) : super(RecipesInitial()) {
    on<FetchRecipes>(_onFetchRecipes);
  }

  Future<void> _onFetchRecipes(FetchRecipes event, Emitter<RecipesState> emit) async {
    emit(RecipesLoading());
    try {
      List<Recipe> recipes = await apiRecipe.getRecipes(event.query, event.random, event.page, event.pageSize, event.sortOrder);
      emit(RecipesFetched(recipes: recipes));
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(RecipesUnauthorized());
      } else {
        emit(RecipesError(error: e.message ?? e.toString()));
      }
    } catch (e) {
      emit(RecipesError(error: e.toString()));
    }
  }
}