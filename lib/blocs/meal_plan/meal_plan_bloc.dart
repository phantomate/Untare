// ignore_for_file: unused_catch_clause

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untare/blocs/meal_plan/meal_plan_event.dart';
import 'package:untare/blocs/meal_plan/meal_plan_state.dart';
import 'package:untare/exceptions/api_connection_exception.dart';
import 'package:untare/exceptions/api_exception.dart';
import 'package:untare/models/meal_plan_entry.dart';
import 'package:untare/models/meal_type.dart';
import 'package:untare/services/api/api_meal_plan.dart';
import 'package:untare/services/api/api_meal_type.dart';
import 'package:untare/services/cache/cache_meal_plan_service.dart';

class MealPlanBloc extends Bloc<MealPlanEvent, MealPlanState> {
  final ApiMealPlan apiMealPlan;
  final ApiMealType apiMealType;
  final CacheMealPlanService cacheMealPlanService;

  MealPlanBloc({required this.apiMealPlan, required this.apiMealType, required this.cacheMealPlanService}) : super(MealPlanInitial()) {
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
      List<MealPlanEntry>? cacheMealPlanEntries = cacheMealPlanService.getMealPlanList(event.from, event.to);

      if (cacheMealPlanEntries != null && cacheMealPlanEntries.isNotEmpty) {
        emit(MealPlanFetchedFromCache(mealPlanList: cacheMealPlanEntries));
      }

      List<MealPlanEntry> mealPlanList = await apiMealPlan.getMealPlanList(event.from, event.to);
      emit(MealPlanFetched(mealPlanList: mealPlanList));

      cacheMealPlanService.upsertMealPlanEntries(mealPlanList, event.from, event.to);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(MealPlanUnauthorized());
      } else {
        emit(MealPlanError(error: e.message ?? e.toString()));
      }
    } on ApiConnectionException catch (e) {
      // Do nothing
    } catch (e) {
      emit(MealPlanError(error: e.toString()));
    }
  }

  Future<void> _onCreateMealPlan(CreateMealPlan event, Emitter<MealPlanState> emit) async {
    try {
      MealPlanEntry mealPlanEntry = await apiMealPlan.createMealPlan(event.mealPlan);
      emit(MealPlanCreated(mealPlan: mealPlanEntry));

      cacheMealPlanService.upsertMealPlanEntry(mealPlanEntry);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(MealPlanUnauthorized());
      } else {
        emit(MealPlanError(error: e.message ?? e.toString()));
      }
    } on ApiConnectionException catch (e) {
      emit(MealPlanCreated(mealPlan: event.mealPlan));
    } catch (e) {
      emit(MealPlanError(error: e.toString()));
    }
  }

  Future<void> _onUpdateMealPlan(UpdateMealPlan event, Emitter<MealPlanState> emit) async {
    try {
      MealPlanEntry mealPlanEntry = await apiMealPlan.updateMealPlan(event.mealPlan);
      emit(MealPlanUpdated(mealPlan: mealPlanEntry));

      cacheMealPlanService.upsertMealPlanEntry(mealPlanEntry);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(MealPlanUnauthorized());
      } else {
        emit(MealPlanError(error: e.message ?? e.toString()));
      }
    } on ApiConnectionException catch (e) {
      emit(MealPlanUpdated(mealPlan: event.mealPlan));
      cacheMealPlanService.upsertMealPlanEntry(event.mealPlan);
    } catch (e) {
      emit(MealPlanError(error: e.toString()));
    }
  }

  Future<void> _onDeleteMealPlan(DeleteMealPlan event, Emitter<MealPlanState> emit) async {
    try {
      MealPlanEntry mealPlanEntry = await apiMealPlan.deleteMealPlan(event.mealPlan);
      emit(MealPlanDeleted(mealPlan: mealPlanEntry));

      cacheMealPlanService.deleteMealPlanEntry(mealPlanEntry);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(MealPlanUnauthorized());
      } else {
        emit(MealPlanError(error: e.message ?? e.toString()));
      }
    } on ApiConnectionException catch (e) {
      emit(MealPlanDeleted(mealPlan: event.mealPlan));
      cacheMealPlanService.deleteMealPlanEntry(event.mealPlan);
    } catch (e) {
      emit(MealPlanError(error: e.toString()));
    }
  }

  Future<void> _onUpdateMealType(UpdateMealType event, Emitter<MealPlanState> emit) async {
    try {
      MealType mealType = await apiMealType.patchMealType(event.mealType);
      emit(MealPlanUpdatedType(mealType: mealType));

      cacheMealPlanService.upsertMealType(mealType);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(MealPlanUnauthorized());
      } else {
        emit(MealPlanError(error: e.message ?? e.toString()));
      }
    } on ApiConnectionException catch (e) {
      emit(MealPlanUpdatedType(mealType: event.mealType));
      cacheMealPlanService.upsertMealType(event.mealType);
    } catch (e) {
      emit(MealPlanError(error: e.toString()));
    }
  }

  Future<void> _onDeleteMealType(DeleteMealType event, Emitter<MealPlanState> emit) async {
    try {
      MealType mealType = await apiMealType.deleteMealType(event.mealType);
      emit(MealPlanDeletedType(mealType: mealType));

      cacheMealPlanService.deleteMealType(mealType);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(MealPlanUnauthorized());
      } else {
        emit(MealPlanError(error: e.message ?? e.toString()));
      }
    } on ApiConnectionException catch (e) {
      emit(MealPlanDeletedType(mealType: event.mealType));
      cacheMealPlanService.deleteMealType(event.mealType);
    } catch (e) {
      emit(MealPlanError(error: e.toString()));
    }
  }
}