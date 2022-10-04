import 'package:untare/models/meal_plan_entry.dart';
import 'package:untare/models/meal_type.dart';

import '../abstract_event.dart';

abstract class MealPlanEvent extends AbstractEvent {}

class FetchMealPlan extends MealPlanEvent {
  final String from;
  final String to;

  FetchMealPlan({required this.from, required this.to});
}

class CreateMealPlan extends MealPlanEvent {
  final MealPlanEntry mealPlan;

  CreateMealPlan({required this.mealPlan});
}

class UpdateMealPlan extends MealPlanEvent {
  final MealPlanEntry mealPlan;

  UpdateMealPlan({required this.mealPlan});
}

class DeleteMealPlan extends MealPlanEvent {
  final MealPlanEntry mealPlan;

  DeleteMealPlan({required this.mealPlan});
}

class UpdateMealType extends MealPlanEvent {
  final MealType mealType;
  UpdateMealType({required this.mealType});
}

class DeleteMealType extends MealPlanEvent {
  final MealType mealType;
  DeleteMealType({required this.mealType});
}