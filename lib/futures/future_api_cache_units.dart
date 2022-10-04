import 'package:untare/models/unit.dart';
import 'package:untare/services/api/api_unit.dart';
import 'package:untare/services/cache/cache_unit_service.dart';

Future getUnitsFromApiCache(String query) async {
  final CacheUnitService cacheUnitService = CacheUnitService();
  final ApiUnit apiUnit = ApiUnit();

  List<Unit>? cacheUnits = cacheUnitService.getUnits(query, 1, 25);

  try {
    Future<List<Unit>> units = apiUnit.getUnits(query, 1, 25);
    units.then((value) => cacheUnitService.upsertUnits(value, query, 1, 25));
    return units;
  } catch (e) {
    if (cacheUnits != null && cacheUnits.isNotEmpty) {
      return cacheUnits;
    }
  }
}