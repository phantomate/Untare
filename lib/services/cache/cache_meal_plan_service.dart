// ignore_for_file: annotate_overrides, overridden_fields

import 'package:hive/hive.dart';
import 'package:untare/models/meal_plan_entry.dart';
import 'package:untare/models/meal_type.dart';
import 'package:untare/services/cache/cache_service.dart';

class CacheMealPlanService extends CacheService{
  var box = Hive.box('unTaReBox');

  List<MealPlanEntry>? getMealPlanList(String from, String to) {
    List<dynamic>? cache = box.get('mealPlanEntries');
    List<MealPlanEntry>? cacheMealPlanEntries = (cache != null) ? cache.cast<MealPlanEntry>() : null;
    List<MealPlanEntry>? mealPLanEntries;

    mealPLanEntries = cacheMealPlanEntries;
    if (cacheMealPlanEntries != null && cacheMealPlanEntries.isNotEmpty) {
      mealPLanEntries = [];
      DateTime fromDate = DateTime.parse(from);
      DateTime toDate = DateTime.parse(to);

      for (var entry in cacheMealPlanEntries) {
        DateTime entryDate = DateTime.parse(entry.date);

        if ((fromDate.isBefore(entryDate) || fromDate.isAtSameMomentAs(entryDate)) && (toDate.isAfter(entryDate) || toDate.isAtSameMomentAs(entryDate))) {
          mealPLanEntries.add(entry);
        }
      }
    }

    return mealPLanEntries;
  }

  upsertMealPlanEntries(List<MealPlanEntry> mealPlanEntries) {
    upsertEntityList(mealPlanEntries, 'mealPlanEntries');
  }

  upsertMealPlanEntry(MealPlanEntry mealPlanEntry) {
    upsertEntity(mealPlanEntry, 'mealPlanEntries');
  }

  deleteMealPlanEntry(MealPlanEntry mealPlanEntry) {
    deleteEntity(mealPlanEntry, 'mealPlanEntries');
  }

  List<MealType>? getMealTypes() {
    List<dynamic>? mealTypes = box.get('mealTypes');

    if (mealTypes != null) {
      return mealTypes.cast<MealType>();
    }

    return null;
  }

  upsertMealTypes(List<MealType> mealTypes) {
    upsertEntityList(mealTypes, 'mealTypes');
  }

  upsertMealType(MealType mealType) {
    upsertEntity(mealType, 'mealTypes');
  }

  deleteMealType(MealType mealType) {
    deleteEntity(mealType, 'mealTypes');
  }
}