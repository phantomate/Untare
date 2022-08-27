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

  upsertUnits(List<Unit> units) {
    upsertEntityList(units, 'units');
  }


  upsertUnit(Unit unit) {
    upsertEntity(unit, 'units');
  }

  deleteUnit(Unit unit) {
    deleteEntity(unit, 'units');
  }
}