import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tare/blocs/shopping_list/shopping_list_event.dart';
import 'package:tare/blocs/shopping_list/shopping_list_state.dart';
import 'package:tare/exceptions/api_exception.dart';
import 'package:tare/models/shopping_list_entry.dart';
import 'package:tare/models/supermarket_category.dart';
import 'package:tare/services/api/api_shopping_list.dart';
import 'package:tare/services/api/api_supermarket_category.dart';

class ShoppingListBloc extends Bloc<ShoppingListEvent, ShoppingListState> {
  final ApiShoppingList apiShoppingList;
  final ApiSupermarketCategory apiSupermarketCategory;

  ShoppingListBloc({required this.apiShoppingList, required this.apiSupermarketCategory}) : super(ShoppingListInitial()) {
    on<FetchShoppingListEntries>(_onFetchShoppingListEntries);
    on<CreateShoppingListEntry>(_onCreateShoppingListEntry);
    on<UpdateShoppingListEntry>(_onUpdateShoppingListEntry);
    on<UpdateShoppingListEntryChecked>(_onUpdateShoppingListEntryChecked);
    on<DeleteShoppingListEntry>(_onDeleteShoppingListEntry);
    on<MarkAllAsCompleted>(_onMarkAllAsCompleted);
    on<UpdateSupermarketCategory>(_onUpdateSupermarketCategory);
    on<DeleteSupermarketCategory>(_onDeleteSupermarketCategory);
    on<SyncShoppingListEntries>(_onSyncShoppingListEntries);
  }

  Future<void> _onFetchShoppingListEntries(FetchShoppingListEntries event, Emitter<ShoppingListState> emit) async {
    emit(ShoppingListLoading());
    try {
      List<ShoppingListEntry> shoppingListEntries = await apiShoppingList.getShoppingListEntries(event.checked, '');
      emit(ShoppingListEntriesFetched(shoppingListEntries: shoppingListEntries));
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(ShoppingListUnauthorized());
      } else {
        emit(ShoppingListError(error: e.message ?? e.toString()));
      }
    } catch (e) {
      emit(ShoppingListError(error: e.toString()));
    }
  }

  Future<void> _onSyncShoppingListEntries(SyncShoppingListEntries event, Emitter<ShoppingListState> emit) async {
    try {
      List<ShoppingListEntry> shoppingListEntries = await apiShoppingList.getShoppingListEntries(event.checked, '');
      emit(ShoppingListEntriesSynced(shoppingListEntries: shoppingListEntries));
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(ShoppingListUnauthorized());
      } else {
        emit(ShoppingListError(error: e.message ?? e.toString()));
      }
    } catch (e) {
      emit(ShoppingListError(error: e.toString()));
    }
  }

  Future<void> _onCreateShoppingListEntry(CreateShoppingListEntry event, Emitter<ShoppingListState> emit) async {
    try {
      ShoppingListEntry shoppingListEntry = await apiShoppingList.createShoppingListEntry(event.shoppingListEntry);
      emit(ShoppingListEntryCreated(shoppingListEntry: shoppingListEntry));
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(ShoppingListUnauthorized());
      } else {
        emit(ShoppingListError(error: e.message ?? e.toString()));
      }
    } catch (e) {
      emit(ShoppingListError(error: e.toString()));
    }
  }

  Future<void> _onUpdateShoppingListEntry(UpdateShoppingListEntry event, Emitter<ShoppingListState> emit) async {
    try {
      ShoppingListEntry shoppingListEntry = await apiShoppingList.updateShoppingListEntry(event.shoppingListEntry);
      emit(ShoppingListEntryUpdated(shoppingListEntry: shoppingListEntry));
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(ShoppingListUnauthorized());
      } else {
        emit(ShoppingListError(error: e.message ?? e.toString()));
      }
    } catch (e) {
      emit(ShoppingListError(error: e.toString()));
    }
  }

  Future<void> _onUpdateShoppingListEntryChecked(UpdateShoppingListEntryChecked event, Emitter<ShoppingListState> emit) async {
    try {
      ShoppingListEntry shoppingListEntry = await apiShoppingList.patchShoppingListEntryCheckedStatus(event.shoppingListEntry);
      emit(ShoppingListEntryCheckedChanged(shoppingListEntry: shoppingListEntry));
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(ShoppingListUnauthorized());
      } else {
        emit(ShoppingListError(error: e.message ?? e.toString()));
      }
    } catch (e) {
      emit(ShoppingListError(error: e.toString()));
    }
  }

  Future<void> _onDeleteShoppingListEntry(DeleteShoppingListEntry event, Emitter<ShoppingListState> emit) async {
    try {
      ShoppingListEntry shoppingListEntry = await apiShoppingList.deleteShoppingListEntry(event.shoppingListEntry);
      emit(ShoppingListEntryDeleted(shoppingListEntry: shoppingListEntry));
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(ShoppingListUnauthorized());
      } else {
        emit(ShoppingListError(error: e.message ?? e.toString()));
      }
    } catch (e) {
      emit(ShoppingListError(error: e.toString()));
    }
  }

  Future<void> _onMarkAllAsCompleted(MarkAllAsCompleted event, Emitter<ShoppingListState> emit) async {
    emit(ShoppingListMarkedAsCompleted());
  }

  Future<void> _onUpdateSupermarketCategory(UpdateSupermarketCategory event, Emitter<ShoppingListState> emit) async {
    try {
      SupermarketCategory supermarketCategory = await apiSupermarketCategory.patchSupermarketCategory(event.supermarketCategory);
      emit(ShoppingListUpdatedSupermarketCategory(supermarketCategory: supermarketCategory));
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(ShoppingListUnauthorized());
      } else {
        emit(ShoppingListError(error: e.message ?? e.toString()));
      }
    } catch (e) {
      emit(ShoppingListError(error: e.toString()));
    }
  }
  
  Future<void> _onDeleteSupermarketCategory(DeleteSupermarketCategory event, Emitter<ShoppingListState> emit) async {
    try {
      SupermarketCategory supermarketCategory = await apiSupermarketCategory.deleteSupermarketCategory(event.supermarketCategory);
      emit(ShoppingListDeletedSupermarketCategory(supermarketCategory: supermarketCategory));
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(ShoppingListUnauthorized());
      } else {
        emit(ShoppingListError(error: e.message ?? e.toString()));
      }
    } catch (e) {
      emit(ShoppingListError(error: e.toString()));
    }
  }
}