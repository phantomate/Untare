import 'package:hive/hive.dart';
import 'package:tare/models/app_setting.dart';
import 'package:tare/models/shopping_list_entry.dart';
import 'package:tare/models/supermarket_category.dart';
import 'package:tare/services/cache/cache_service.dart';

class CacheShoppingListService extends CacheService {
  var box = Hive.box('unTaReBox');

  List<ShoppingListEntry>? getShoppingListEntries(String checked, String idFilter) {
    List<dynamic>? cache = box.get('shoppingListEntries');
    List<ShoppingListEntry>? cacheShoppingListEntries = (cache != null) ? cache.cast<ShoppingListEntry>() : null;
    List<ShoppingListEntry>? shoppingListEntries;

    shoppingListEntries = cacheShoppingListEntries;
    if (cacheShoppingListEntries != null && cacheShoppingListEntries.isNotEmpty) {
      shoppingListEntries = [];

      cacheShoppingListEntries.forEach((entry) {
        if (checked == 'true') {
          if (entry.checked) {
            shoppingListEntries!.add(entry);
          }
        } else if (checked == 'false') {
          if (!entry.checked) {
            shoppingListEntries!.add(entry);
          }
        } else if (checked == 'both') {
          shoppingListEntries!.add(entry);
        } else if (checked == 'recent') {
          if (!entry.checked) {
            shoppingListEntries!.add(entry);
          } else {
            AppSetting? appSetting = box.get('settings');

            int recentDays = 7;
            if (appSetting != null && appSetting.userServerSetting != null) {
              recentDays = appSetting.userServerSetting!.shoppingRecentDays;
            }

            if (entry.completedAt != null) {
              DateTime completedAtDate = DateTime.parse(entry.completedAt!);
              DateTime todayMinusRecentDays = DateTime.now().subtract(Duration(days: recentDays));

              if (completedAtDate.year >= todayMinusRecentDays.year
                  && completedAtDate.month >= todayMinusRecentDays.month
                  && completedAtDate.day >= todayMinusRecentDays.day) {
                shoppingListEntries!.add(entry);
              }
            } else {
              shoppingListEntries!.add(entry);
            }
          }
        }

        // @todo Implement id filter
      });
    }

    return shoppingListEntries;
  }

  upsertShoppingListEntries(List<ShoppingListEntry> shoppingListEntries) {
    upsertEntityList(shoppingListEntries, 'shoppingListEntries');
  }

  upsertShoppingListEntry(ShoppingListEntry shoppingListEntry) {
    upsertEntity(shoppingListEntry, 'shoppingListEntries');
  }

  deleteShoppingListEntry(ShoppingListEntry shoppingListEntry) {
    deleteEntity(shoppingListEntry, 'shoppingListEntries');
  }

  List<SupermarketCategory>? getSupermarketCategories() {
    List<dynamic>? categories = box.get('supermarketCategories');

    if (categories != null) {
      return categories.cast<SupermarketCategory>();
    }

    return null;
  }

  upsertSupermarketCategories(List<SupermarketCategory> categories) {
    upsertEntityList(categories, 'supermarketCategories');
  }

  upsertSupermarketCategory(SupermarketCategory category) {
    upsertEntity(category, 'supermarketCategories');
  }

  deleteSupermarketCategory(SupermarketCategory category) {
    deleteEntity(category, 'supermarketCategories');
  }
}