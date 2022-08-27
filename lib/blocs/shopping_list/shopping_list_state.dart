import 'package:untare/models/shopping_list_entry.dart';
import 'package:untare/models/supermarket_category.dart';

abstract class ShoppingListState {}

class ShoppingListInitial extends ShoppingListState {}

class ShoppingListLoading extends ShoppingListState {}

class ShoppingListEntriesFetched extends ShoppingListState {
  final List<ShoppingListEntry> shoppingListEntries;
  ShoppingListEntriesFetched({required this.shoppingListEntries});
}

class ShoppingListEntriesFetchedFromCache extends ShoppingListState {
  final List<ShoppingListEntry> shoppingListEntries;
  ShoppingListEntriesFetchedFromCache({required this.shoppingListEntries});
}

class ShoppingListEntriesSynced extends ShoppingListState {
  final List<ShoppingListEntry> shoppingListEntries;
  ShoppingListEntriesSynced({required this.shoppingListEntries});
}

class ShoppingListEntryCreated extends ShoppingListState {
  final ShoppingListEntry shoppingListEntry;
  ShoppingListEntryCreated({required this.shoppingListEntry});
}

class ShoppingListEntryUpdated extends ShoppingListState {
  final ShoppingListEntry shoppingListEntry;
  ShoppingListEntryUpdated({required this.shoppingListEntry});
}

class ShoppingListEntryCheckedChanged extends ShoppingListState {
  final ShoppingListEntry shoppingListEntry;
  ShoppingListEntryCheckedChanged({required this.shoppingListEntry});
}

class ShoppingListEntryDeleted extends ShoppingListState {
  final ShoppingListEntry shoppingListEntry;
  ShoppingListEntryDeleted({required this.shoppingListEntry});
}

class ShoppingListMarkedAsCompleted extends ShoppingListState {}

class ShoppingListError extends ShoppingListState {
  final String error;

  ShoppingListError({required this.error});

  List<Object> get props => [error];
}

class ShoppingListUnauthorized extends ShoppingListState {}

class ShoppingListUpdatedSupermarketCategory extends ShoppingListState {
  final SupermarketCategory supermarketCategory;
  ShoppingListUpdatedSupermarketCategory({required this.supermarketCategory});
}

class ShoppingListDeletedSupermarketCategory extends ShoppingListState {
  final SupermarketCategory supermarketCategory;
  ShoppingListDeletedSupermarketCategory({required this.supermarketCategory});
}