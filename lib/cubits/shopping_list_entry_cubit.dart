import 'package:flutter_bloc/flutter_bloc.dart';

class ShoppingListEntryCubit extends Cubit<String> {
  ShoppingListEntryCubit() : super('hide');

  void hideCheckedShoppingListEntries() {
    emit('hide');
  }

  void showCheckedShoppingListEntries() {
    emit('show');
  }
}