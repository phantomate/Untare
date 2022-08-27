import 'package:untare/models/meal_plan_entry.dart';
import 'package:untare/models/meal_type.dart';

abstract class MealPlanState {}

class MealPlanInitial extends MealPlanState {}

class MealPlanLoading extends MealPlanState {}

class MealPlanFetched extends MealPlanState {
  final List<MealPlanEntry> mealPlanList;
  MealPlanFetched({required this.mealPlanList});
}

class MealPlanFetchedFromCache extends MealPlanState {
  final List<MealPlanEntry> mealPlanList;
  MealPlanFetchedFromCache({required this.mealPlanList});
}

class MealPlanCreated extends MealPlanState {
  final MealPlanEntry mealPlan;
  MealPlanCreated({required this.mealPlan});
}

class MealPlanUpdated extends MealPlanState {
  final MealPlanEntry mealPlan;
  MealPlanUpdated({required this.mealPlan});
}

class MealPlanDeleted extends MealPlanState {
  final MealPlanEntry mealPlan;
  MealPlanDeleted({required this.mealPlan});
}

class MealPlanError extends MealPlanState {
  final String error;

  MealPlanError({required this.error});

  List<Object> get props => [error];
}

class MealPlanUnauthorized extends MealPlanState {}

class MealPlanUpdatedType extends MealPlanState {
  final MealType mealType;
  MealPlanUpdatedType({required this.mealType});
}

class MealPlanDeletedType extends MealPlanState {
  final MealType mealType;
  MealPlanDeletedType({required this.mealType});
}