import 'package:hive/hive.dart';
import 'package:tare/models/unit.dart';
import 'package:tare/services/cache/cache_service.dart';

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
}