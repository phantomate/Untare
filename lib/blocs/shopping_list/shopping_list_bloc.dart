// ignore_for_file: unused_catch_clause

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untare/blocs/shopping_list/shopping_list_event.dart';
import 'package:untare/blocs/shopping_list/shopping_list_state.dart';
import 'package:untare/exceptions/api_connection_exception.dart';
import 'package:untare/exceptions/api_exception.dart';
import 'package:untare/models/shopping_list_entry.dart';
import 'package:untare/models/supermarket_category.dart';
import 'package:untare/services/api/api_shopping_list.dart';
import 'package:untare/services/api/api_supermarket_category.dart';
import 'package:untare/services/cache/cache_shopping_list_service.dart';

class ShoppingListBloc extends Bloc<ShoppingListEvent, ShoppingListState> {
  final ApiShoppingList apiShoppingList;
  final ApiSupermarketCategory apiSupermarketCategory;
  final CacheShoppingListService cacheShoppingListService;

  ShoppingListBloc({required this.apiShoppingList, required this.apiSupermarketCategory, required this.cacheShoppingListService}) : super(ShoppingListInitial()) {
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
      List<ShoppingListEntry>? cacheShoppingListEntries = cacheShoppingListService.getShoppingListEntries(event.checked, '');

      if (cacheShoppingListEntries != null && cacheShoppingListEntries.isNotEmpty) {
        emit(ShoppingListEntriesFetchedFromCache(shoppingListEntries: cacheShoppingListEntries));
      }

      List<ShoppingListEntry> shoppingListEntries = await apiShoppingList.getShoppingListEntries(event.checked, '');
      emit(ShoppingListEntriesFetched(shoppingListEntries: shoppingListEntries));

      cacheShoppingListService.upsertShoppingListEntries(shoppingListEntries);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(ShoppingListUnauthorized());
      } else {
        emit(ShoppingListError(error: e.message ?? e.toString()));
      }
    } on ApiConnectionException catch (e) {
      // Do nothing
    } catch (e) {
      emit(ShoppingListError(error: e.toString()));
    }
  }

  Future<void> _onSyncShoppingListEntries(SyncShoppingListEntries event, Emitter<ShoppingListState> emit) async {
    try {
      List<ShoppingListEntry> shoppingListEntries = await apiShoppingList.getShoppingListEntries(event.checked, '');
      emit(ShoppingListEntriesSynced(shoppingListEntries: shoppingListEntries));

      cacheShoppingListService.upsertShoppingListEntries(shoppingListEntries);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(ShoppingListUnauthorized());
      } else {
        emit(ShoppingListError(error: e.message ?? e.toString()));
      }
    } on ApiConnectionException catch (e) {
      // Do nothing
    } catch (e) {
      emit(ShoppingListError(error: e.toString()));
    }
  }

  Future<void> _onCreateShoppingListEntry(CreateShoppingListEntry event, Emitter<ShoppingListState> emit) async {
    try {
      ShoppingListEntry shoppingListEntry = await apiShoppingList.createShoppingListEntry(event.shoppingListEntry);
      emit(ShoppingListEntryCreated(shoppingListEntry: shoppingListEntry));

      cacheShoppingListService.upsertShoppingListEntry(shoppingListEntry);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(ShoppingListUnauthorized());
      } else {
        emit(ShoppingListError(error: e.message ?? e.toString()));
      }
    } on ApiConnectionException catch (e) {
      emit(ShoppingListEntryCreated(shoppingListEntry: event.shoppingListEntry));
    } catch (e) {
      emit(ShoppingListError(error: e.toString()));
    }
  }

  Future<void> _onUpdateShoppingListEntry(UpdateShoppingListEntry event, Emitter<ShoppingListState> emit) async {
    try {
      ShoppingListEntry shoppingListEntry = await apiShoppingList.updateShoppingListEntry(event.shoppingListEntry);
      emit(ShoppingListEntryUpdated(shoppingListEntry: shoppingListEntry));

      cacheShoppingListService.upsertShoppingListEntry(shoppingListEntry);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(ShoppingListUnauthorized());
      } else {
        emit(ShoppingListError(error: e.message ?? e.toString()));
      }
    } on ApiConnectionException catch (e) {
      emit(ShoppingListEntryUpdated(shoppingListEntry: event.shoppingListEntry));
      cacheShoppingListService.upsertShoppingListEntry(event.shoppingListEntry);
    } catch (e) {
      emit(ShoppingListError(error: e.toString()));
    }
  }

  Future<void> _onUpdateShoppingListEntryChecked(UpdateShoppingListEntryChecked event, Emitter<ShoppingListState> emit) async {
    try {
      ShoppingListEntry shoppingListEntry = await apiShoppingList.patchShoppingListEntryCheckedStatus(event.shoppingListEntry);
      emit(ShoppingListEntryCheckedChanged(shoppingListEntry: shoppingListEntry));

      cacheShoppingListService.upsertShoppingListEntry(shoppingListEntry);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(ShoppingListUnauthorized());
      } else {
        emit(ShoppingListError(error: e.message ?? e.toString()));
      }
    } on ApiConnectionException catch (e) {
      emit(ShoppingListEntryCheckedChanged(shoppingListEntry: event.shoppingListEntry));
      cacheShoppingListService.upsertShoppingListEntry(event.shoppingListEntry);
    } catch (e) {
      emit(ShoppingListError(error: e.toString()));
    }
  }

  Future<void> _onDeleteShoppingListEntry(DeleteShoppingListEntry event, Emitter<ShoppingListState> emit) async {
    try {
      ShoppingListEntry shoppingListEntry = await apiShoppingList.deleteShoppingListEntry(event.shoppingListEntry);
      emit(ShoppingListEntryDeleted(shoppingListEntry: shoppingListEntry));

      cacheShoppingListService.deleteShoppingListEntry(shoppingListEntry);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(ShoppingListUnauthorized());
      } else {
        emit(ShoppingListError(error: e.message ?? e.toString()));
      }
    } on ApiConnectionException catch (e) {
      emit(ShoppingListEntryDeleted(shoppingListEntry: event.shoppingListEntry));
      cacheShoppingListService.deleteShoppingListEntry(event.shoppingListEntry);
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

      cacheShoppingListService.upsertSupermarketCategory(supermarketCategory);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(ShoppingListUnauthorized());
      } else {
        emit(ShoppingListError(error: e.message ?? e.toString()));
      }
    } on ApiConnectionException catch (e) {
      emit(ShoppingListUpdatedSupermarketCategory(supermarketCategory: event.supermarketCategory));
      cacheShoppingListService.upsertSupermarketCategory(event.supermarketCategory);
    } catch (e) {
      emit(ShoppingListError(error: e.toString()));
    }
  }
  
  Future<void> _onDeleteSupermarketCategory(DeleteSupermarketCategory event, Emitter<ShoppingListState> emit) async {
    try {
      SupermarketCategory supermarketCategory = await apiSupermarketCategory.deleteSupermarketCategory(event.supermarketCategory);
      emit(ShoppingListDeletedSupermarketCategory(supermarketCategory: supermarketCategory));

      cacheShoppingListService.deleteSupermarketCategory(supermarketCategory);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(ShoppingListUnauthorized());
      } else {
        emit(ShoppingListError(error: e.message ?? e.toString()));
      }
    } on ApiConnectionException catch (e) {
      emit(ShoppingListDeletedSupermarketCategory(supermarketCategory: event.supermarketCategory));
      cacheShoppingListService.deleteSupermarketCategory(event.supermarketCategory);
    } catch (e) {
      emit(ShoppingListError(error: e.toString()));
    }
  }
}