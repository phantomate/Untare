import 'package:hive/hive.dart';

abstract class CacheService {
  var box = Hive.box('unTaReBox');

  getQueryablePaginatedList(String query, int page, int pageSize, String cacheKey) {
    List<dynamic>? cacheEntities = box.get(cacheKey);
    List<dynamic>? entities;

    entities = cacheEntities;
    if (cacheEntities != null && cacheEntities.isNotEmpty) {
      int start = pageSize * (page - 1);
      int end = pageSize * page;

      if (query != '') {
        cacheEntities = cacheEntities.where((entity) {
          if (entity.name.toLowerCase().contains(query.toLowerCase()))
            return true;

          if (entity.description != null && entity.description!.toLowerCase().contains(query.toLowerCase()))
            return true;

          return false;
        }).toList();
      }

      end = (cacheEntities.length < end) ? cacheEntities.length : end;

      // If we want to get more entities than stored we return an empty list
      if (start < cacheEntities.length) {
        entities = cacheEntities.sublist(start, end);
      } else {
        entities = [];
      }
    }

    return entities;
  }

  upsertEntityList(List<dynamic> entities, String cacheKey) {
    List<dynamic>? cacheEntities = box.get(cacheKey);

    if (cacheEntities != null && cacheEntities.isNotEmpty) {
      entities.forEach((entity) {
        int cacheEntityIndex = cacheEntities!.indexWhere((cacheRecipe) => cacheRecipe.id == entity.id);

        // If we found the entity in cache entities, overwrite data, if not add entity
        if (cacheEntityIndex >= 0) {
          // Keep steps from recipe, because be get empty step list from recipe list call
          if (cacheKey == 'recipes') {
            entity = entity.copyWith(steps: cacheEntities[cacheEntityIndex].steps);
          }

          cacheEntities[cacheEntityIndex] = entity;
        } else {
          cacheEntities.add(entity);
        }
      });
    } else {
      cacheEntities = [];
      cacheEntities.addAll(entities);
    }

    box.put(cacheKey, cacheEntities);
  }


  upsertEntity(dynamic entity, String cacheKey) {
    List<dynamic>? cacheEntities = box.get(cacheKey);

    if (cacheEntities != null && cacheEntities.isNotEmpty) {
      int cacheEntityIndex = cacheEntities.indexWhere((cacheEntity) => cacheEntity.id == entity.id);

      if (cacheEntityIndex >= 0) {
        cacheEntities[cacheEntityIndex] = entity;
      } else {
        cacheEntities.add(entity);
      }
    } else {
      cacheEntities = [];
      cacheEntities.add(entity);
    }

    box.put(cacheKey, cacheEntities);
  }

  deleteEntity(dynamic entity, String cacheKey) {
    List<dynamic>? cacheEntities = box.get(cacheKey);

    if (cacheEntities != null && cacheEntities.isNotEmpty) {
      cacheEntities.removeWhere((cacheEntity) => cacheEntity.id == entity.id);
    }

    box.put(cacheKey, cacheEntities);
  }
}