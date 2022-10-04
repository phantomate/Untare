// ignore_for_file: unused_catch_clause

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untare/blocs/food/food_event.dart';
import 'package:untare/blocs/food/food_state.dart';
import 'package:untare/exceptions/api_connection_exception.dart';
import 'package:untare/exceptions/api_exception.dart';
import 'package:untare/models/food.dart';
import 'package:untare/services/api/api_food.dart';
import 'package:untare/services/cache/cache_food_service.dart';

class FoodBloc extends Bloc<FoodEvent, FoodState> {
  final ApiFood apiFood;
  final CacheFoodService cacheFoodService;

  FoodBloc(
      {required this.apiFood, required this.cacheFoodService})
      : super(FoodsInitial()) {
    on<FetchFoods>(_onFetchFoods);
    on<CreateFood>(_onCreateFood);
    on<UpdateFood>(_onUpdateFood);
    on<DeleteFood>(_onDeleteFood);
  }

  Future<void> _onFetchFoods(FetchFoods event, Emitter<FoodState> emit) async {
    emit(FoodsLoading());
    try {
      List<Food>? cacheFoods = cacheFoodService.getFoods(event.query, event.page, event.pageSize);

      if (cacheFoods != null && cacheFoods.isNotEmpty) {
        emit(FoodsFetchedFromCache(foods: cacheFoods));
      }

      List<Food> foods = await apiFood.getFoods(event.query, event.page, event.pageSize);
      emit(FoodsFetched(foods: foods));

      cacheFoodService.upsertFoods(foods, event.query, event.page, event.pageSize);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(FoodsUnauthorized());
      } else {
        emit(FoodsError(error: e.message ?? e.toString()));
      }
    } on ApiConnectionException catch (e) {
      // Do nothing
    } catch (e) {
      emit(FoodsError(error: e.toString()));
    }
  }

  Future<void> _onCreateFood(CreateFood event, Emitter<FoodState> emit) async {
    try {
      Food food = await apiFood.createFood(event.food);
      emit(FoodCreated(food: food));

      cacheFoodService.upsertFood(food);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(FoodsUnauthorized());
      } else {
        emit(FoodsError(error: e.message ?? e.toString()));
      }
    } on ApiConnectionException catch (e) {
      emit(FoodCreated(food: event.food));
    } catch (e) {
      emit(FoodsError(error: e.toString()));
    }
  }

  Future<void> _onUpdateFood(UpdateFood event, Emitter<FoodState> emit) async {
    try {
      Food food = await apiFood.updateFood(event.food);
      emit(FoodUpdated(food: food));

      cacheFoodService.upsertFood(food);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(FoodsUnauthorized());
      } else {
        emit(FoodsError(error: e.message ?? e.toString()));
      }
    } on ApiConnectionException catch (e) {
      emit(FoodUpdated(food: event.food));
      cacheFoodService.upsertFood(event.food);
    } catch (e) {
      emit(FoodsError(error: e.toString()));
    }
  }

  Future<void> _onDeleteFood(DeleteFood event, Emitter<FoodState> emit) async {
    try {
      Food food = await apiFood.deleteFood(event.food);
      emit(FoodDeleted(food: food));

      cacheFoodService.deleteFood(food);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(FoodsUnauthorized());
      } else {
        emit(FoodsError(error: e.message ?? e.toString()));
      }
    } on ApiConnectionException catch (e) {
      emit(FoodDeleted(food: event.food));
      cacheFoodService.deleteFood(event.food);
    } catch (e) {
      emit(FoodsError(error: e.toString()));
    }
  }
}