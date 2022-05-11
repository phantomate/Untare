import 'package:tare/models/shopping_list_entry.dart';

abstract class ShoppingListState {}

class ShoppingListInitial extends ShoppingListState {}

class ShoppingListLoading extends ShoppingListState {}

class ShoppingListEntriesFetched extends ShoppingListState {
  final List<ShoppingListEntry> shoppingListEntries;
  ShoppingListEntriesFetched({required this.shoppingListEntries});
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