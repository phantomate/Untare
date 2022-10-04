// ignore_for_file: annotate_overrides, overridden_fields

import 'package:hive/hive.dart';
import 'package:untare/models/space.dart';
import 'package:untare/services/cache/cache_service.dart';

class CacheSpaceService extends CacheService {
  var box = Hive.box('unTaReBox');

  List<Space>? getSpaces() {
    List<dynamic>? spaces = box.get('spaces');

    if (spaces != null) {
      return spaces.cast<Space>();
    }

    return null;
  }

  upsertSpaces(List<Space> spaces) {
    upsertEntityList(spaces, 'spaces');
  }
}