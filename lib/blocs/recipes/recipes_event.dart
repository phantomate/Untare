import 'package:tare/blocs/abstract_event.dart';

abstract class RecipesEvent extends AbstractEvent {}

class RecipesPageLoaded extends RecipesEvent {}

class FetchRecipes extends RecipesEvent {
  final String query;
  final bool random;
  final int page;
  final int pageSize;
  final String? sortOrder;

  FetchRecipes({required this.query, required this.random, required this.page, required this.pageSize, this.sortOrder});
}