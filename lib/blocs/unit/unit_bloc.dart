// ignore_for_file: unused_catch_clause

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untare/blocs/unit/unit_event.dart';
import 'package:untare/blocs/unit/unit_state.dart';
import 'package:untare/exceptions/api_connection_exception.dart';
import 'package:untare/exceptions/api_exception.dart';
import 'package:untare/models/unit.dart';
import 'package:untare/services/api/api_unit.dart';
import 'package:untare/services/cache/cache_unit_service.dart';

class UnitBloc extends Bloc<UnitEvent, UnitState> {
  final ApiUnit apiUnit;
  final CacheUnitService cacheUnitService;

  UnitBloc({required this.apiUnit, required this.cacheUnitService}) : super(UnitsInitial()) {
    on<FetchUnits>(_onFetchUnits);
    on<CreateUnit>(_onCreateUnit);
    on<UpdateUnit>(_onUpdateUnit);
    on<DeleteUnit>(_onDeleteUnit);
  }

  Future<void> _onFetchUnits(FetchUnits event, Emitter<UnitState> emit) async {
    emit(UnitsLoading());
    try {
      List<Unit>? cacheUnits = cacheUnitService.getUnits(event.query, event.page, event.pageSize);

      if (cacheUnits != null && cacheUnits.isNotEmpty) {
        emit(UnitsFetchedFromCache(units: cacheUnits));
      }

      List<Unit> units = await apiUnit.getUnits(event.query, event.page, event.pageSize);
      emit(UnitsFetched(units: units));

      cacheUnitService.upsertUnits(units, event.query, event.page, event.pageSize);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(UnitsUnauthorized());
      } else {
        emit(UnitsError(error: e.message ?? e.toString()));
      }
    } on ApiConnectionException catch (e) {
      // Do nothing
    } catch (e) {
      emit(UnitsError(error: e.toString()));
    }
  }

  Future<void> _onCreateUnit(CreateUnit event, Emitter<UnitState> emit) async {
    try {
      Unit unit = await apiUnit.createUnit(event.unit);
      emit(UnitCreated(unit: unit));

      cacheUnitService.upsertUnit(unit);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(UnitsUnauthorized());
      } else {
        emit(UnitsError(error: e.message ?? e.toString()));
      }
    } on ApiConnectionException catch (e) {
      emit(UnitCreated(unit: event.unit));
    } catch (e) {
      emit(UnitsError(error: e.toString()));
    }
  }

  Future<void> _onUpdateUnit(UpdateUnit event, Emitter<UnitState> emit) async {
    try {
      Unit unit = await apiUnit.updateUnit(event.unit);
      emit(UnitUpdated(unit: unit));

      cacheUnitService.upsertUnit(unit);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(UnitsUnauthorized());
      } else {
        emit(UnitsError(error: e.message ?? e.toString()));
      }
    } on ApiConnectionException catch (e) {
      emit(UnitUpdated(unit: event.unit));
      cacheUnitService.upsertUnit(event.unit);
    } catch (e) {
      emit(UnitsError(error: e.toString()));
    }
  }

  Future<void> _onDeleteUnit(DeleteUnit event, Emitter<UnitState> emit) async {
    try {
      Unit unit = await apiUnit.deleteUnit(event.unit);
      emit(UnitDeleted(unit: unit));

      cacheUnitService.deleteUnit(unit);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(UnitsUnauthorized());
      } else {
        emit(UnitsError(error: e.message ?? e.toString()));
      }
    } on ApiConnectionException catch (e) {
      emit(UnitDeleted(unit: event.unit));
      cacheUnitService.deleteUnit(event.unit);
    } catch (e) {
      emit(UnitsError(error: e.toString()));
    }
  }
}