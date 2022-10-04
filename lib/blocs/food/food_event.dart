import 'package:untare/blocs/abstract_event.dart';
import 'package:untare/models/food.dart';

abstract class FoodEvent extends AbstractEvent {}

class FetchFoods extends FoodEvent {
  final String query;
  final int page;
  final int pageSize;

  FetchFoods({required this.query, required this.page, required this.pageSize});
}

class CreateFood extends FoodEvent {
  final Food food;

  CreateFood({required this.food});
}

class UpdateFood extends FoodEvent {
  final Food food;

  UpdateFood({required this.food});
}

class DeleteFood extends FoodEvent {
  final Food food;

  DeleteFood({required this.food});
}