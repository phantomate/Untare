import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class RecipeLayoutCubit extends Cubit<String> {
  var box = Hive.box('appBox');

  RecipeLayoutCubit() : super('card');

  void initLayout(String? layout) async {
    if (layout != null) {
      emit(layout);
    }
  }

  void changeLayoutToList() {
    box.put('layout', 'list');
    emit('list');
  }

  void changeLayoutToCard() {
    box.put('layout', 'card');
    emit('card');
  }
}