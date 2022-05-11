import 'package:tare/models/meal_plan_entry.dart';

import '../abstract_event.dart';

abstract class MealPlanEvent extends AbstractEvent {}

class MealPlanPageLoaded extends MealPlanEvent {}

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