// ignore_for_file: unused_catch_clause

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:untare/exceptions/api_connection_exception.dart';
import 'package:untare/models/space.dart';
import 'package:untare/services/api/api_space.dart';
import 'package:untare/services/cache/cache_space_service.dart';

class SpacesCubit extends Cubit<List<Space>> {
  var box = Hive.box('unTaReBox');
  final ApiSpace apiSpace;
  final CacheSpaceService cacheSpaceService;

  SpacesCubit({required this.apiSpace, required this.cacheSpaceService}) : super([]);

  void fetchSpaces() async {
    List<Space>? cacheSpaces = cacheSpaceService.getSpaces();

    if (cacheSpaces != null) {
      emit(cacheSpaces);
    }

    try {
      List<Space> spaces = await apiSpace.getSpaces();
      emit(spaces);
      box.put('spaces', spaces);

      cacheSpaceService.upsertSpaces(spaces);
    } on ApiConnectionException catch (e) {
      // Do nothing
    }

  }

  void switchActiveSpace() {

  }
}