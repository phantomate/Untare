// ignore_for_file: annotate_overrides, overridden_fields

import 'package:hive/hive.dart';
import 'package:untare/models/unit.dart';
import 'package:untare/services/cache/cache_service.dart';

class CacheUnitService extends CacheService {
  var box = Hive.box('unTaReBox');

  List<Unit>? getUnits(String query, int page, int pageSize) {
    List<dynamic>? units = getQueryablePaginatedList(query, page, pageSize, 'units');

    if (units != null) {
      return units.cast<Unit>();
    }

    return null;
  }

  upsertUnits(List<Unit> units, String query, int page, int pageSize) {
    upsertEntityList(units, 'units');

    // After upsert, check if we have to delete entries
    List<Unit>? cacheEntitiesForDeletion = getUnits(query, page, pageSize);

    if (cacheEntitiesForDeletion != null) {
      cacheEntitiesForDeletion.removeWhere((element) {
        return units.indexWhere((e) => e.id == element.id) >= 0;
      });

      for (var entity in cacheEntitiesForDeletion) {
        deleteUnit(entity);
      }
    }
  }


  upsertUnit(Unit unit) {
    upsertEntity(unit, 'units');
  }

  deleteUnit(Unit unit) {
    deleteEntity(unit, 'units');
  }
}