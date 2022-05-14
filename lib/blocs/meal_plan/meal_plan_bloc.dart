import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tare/blocs/meal_plan/meal_plan_event.dart';
import 'package:tare/blocs/meal_plan/meal_plan_state.dart';
import 'package:tare/exceptions/api_exception.dart';
import 'package:tare/models/meal_plan_entry.dart';
import 'package:tare/models/meal_type.dart';
import 'package:tare/services/api/api_meal_plan.dart';
import 'package:tare/services/api/api_meal_type.dart';

class MealPlanBloc extends Bloc<MealPlanEvent, MealPlanState> {
  final ApiMealPlan apiMealPlan;
  final ApiMealType apiMealType;

  MealPlanBloc({required this.apiMealPlan, required this.apiMealType}) : super(MealPlanInitial()) {
    on<FetchMealPlan>(_onFetchMealPlan);
    on<CreateMealPlan>(_onCreateMealPlan);
    on<UpdateMealPlan>(_onUpdateMealPlan);
    on<DeleteMealPlan>(_onDeleteMealPlan);
    on<UpdateMealType>(_onUpdateMealType);
    on<DeleteMealType>(_onDeleteMealType);
  }

  Future<void> _onFetchMealPlan(FetchMealPlan event, Emitter<MealPlanState> emit) async {
    emit(MealPlanLoading());
    try {
      List<MealPlanEntry> mealPlanList = await apiMealPlan.getMealPlanList(event.from, event.to);
      emit(MealPlanFetched(mealPlanList: mealPlanList));
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(MealPlanUnauthorized());
      } else {
        emit(MealPlanError(error: e.message ?? e.toString()));
      }
    } catch (e) {
      emit(MealPlanError(error: e.toString()));
    }
  }

  Future<void> _onCreateMealPlan(CreateMealPlan event, Emitter<MealPlanState> emit) async {
    try {
      MealPlanEntry mealPlan = await apiMealPlan.createMealPlan(event.mealPlan);
      emit(MealPlanCreated(mealPlan: mealPlan));
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(MealPlanUnauthorized());
      } else {
        emit(MealPlanError(error: e.message ?? e.toString()));
      }
    } catch (e) {
      emit(MealPlanError(error: e.toString()));
    }
  }

  Future<void> _onUpdateMealPlan(UpdateMealPlan event, Emitter<MealPlanState> emit) async {
    try {
      MealPlanEntry mealPlan = await apiMealPlan.updateMealPlan(event.mealPlan);
      emit(MealPlanUpdated(mealPlan: mealPlan));
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(MealPlanUnauthorized());
      } else {
        emit(MealPlanError(error: e.message ?? e.toString()));
      }
    } catch (e) {
      emit(MealPlanError(error: e.toString()));
    }
  }

  Future<void> _onDeleteMealPlan(DeleteMealPlan event, Emitter<MealPlanState> emit) async {
    try {
      MealPlanEntry mealPlan = await apiMealPlan.deleteMealPlan(event.mealPlan);
      emit(MealPlanDeleted(mealPlan: mealPlan));
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(MealPlanUnauthorized());
      } else {
        emit(MealPlanError(error: e.message ?? e.toString()));
      }
    } catch (e) {
      emit(MealPlanError(error: e.toString()));
    }
  }

  Future<void> _onUpdateMealType(UpdateMealType event, Emitter<MealPlanState> emit) async {
    try {
      MealType mealType = await apiMealType.patchMealType(event.mealType);
      emit(MealPlanUpdatedType(mealType: mealType));
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(MealPlanUnauthorized());
      } else {
        emit(MealPlanError(error: e.message ?? e.toString()));
      }
    } catch (e) {
      emit(MealPlanError(error: e.toString()));
    }
  }

  Future<void> _onDeleteMealType(DeleteMealType event, Emitter<MealPlanState> emit) async {
    try {
      MealType mealType = await apiMealType.deleteMealType(event.mealType);
      emit(MealPlanDeletedType(mealType: mealType));
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(MealPlanUnauthorized());
      } else {
        emit(MealPlanError(error: e.message ?? e.toString()));
      }
    } catch (e) {
      emit(MealPlanError(error: e.toString()));
    }
  }
}