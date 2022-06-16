import 'package:tare/blocs/abstract_event.dart';
import 'package:tare/models/shopping_list_entry.dart';
import 'package:tare/models/supermarket_category.dart';

abstract class ShoppingListEvent extends AbstractEvent {}

class ShoppingListPageLoaded extends ShoppingListEvent {}

class FetchShoppingListEntries extends ShoppingListEvent {
  final String checked;

  FetchShoppingListEntries({required this.checked});
}

class SyncShoppingListEntries extends ShoppingListEvent {
  final String checked;

  SyncShoppingListEntries({required this.checked});
}

class CreateShoppingListEntry extends ShoppingListEvent {
  final ShoppingListEntry shoppingListEntry;

  CreateShoppingListEntry({required this.shoppingListEntry});
}

class UpdateShoppingListEntry extends ShoppingListEvent {
  final ShoppingListEntry shoppingListEntry;

  UpdateShoppingListEntry({required this.shoppingListEntry});
}

class UpdateShoppingListEntryChecked extends ShoppingListEvent {
  final ShoppingListEntry shoppingListEntry;

  UpdateShoppingListEntryChecked({required this.shoppingListEntry});
}

class DeleteShoppingListEntry extends ShoppingListEvent {
  final ShoppingListEntry shoppingListEntry;

  DeleteShoppingListEntry({required this.shoppingListEntry});
}

class MarkAllAsCompleted extends ShoppingListEvent{}

class UpdateSupermarketCategory extends ShoppingListEvent {
  final SupermarketCategory supermarketCategory;
  UpdateSupermarketCategory({required this.supermarketCategory});
}

class DeleteSupermarketCategory extends ShoppingListEvent {
  final SupermarketCategory supermarketCategory;
  DeleteSupermarketCategory({required this.supermarketCategory});
}