import 'package:untare/models/food.dart';

abstract class FoodState {}

class FoodsLoading extends FoodState {}

class FoodsInitial extends FoodState {}

class FoodsFetched extends FoodState {
  final List<Food> foods;
  FoodsFetched({required this.foods});
}

class FoodsFetchedFromCache extends FoodState {
  final List<Food> foods;

  FoodsFetchedFromCache({required this.foods});
}

class FoodCreated extends FoodState {
  final Food food;
  FoodCreated({required this.food});
}

class FoodUpdated extends FoodState {
  final Food food;
  FoodUpdated({required this.food});
}

class FoodDeleted extends FoodState {
  final Food food;
  FoodDeleted({required this.food});
}

class FoodsError extends FoodState {
  final String error;

  FoodsError({required this.error});

  List<Object> get props => [error];
}

class FoodsUnauthorized extends FoodState {}