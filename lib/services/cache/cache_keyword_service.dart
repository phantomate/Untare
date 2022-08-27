// ignore_for_file: annotate_overrides, overridden_fields

import 'package:hive/hive.dart';
import 'package:untare/models/keyword.dart';
import 'package:untare/services/cache/cache_service.dart';

class CacheKeywordService extends CacheService {
  var box = Hive.box('unTaReBox');

  List<Keyword>? getKeywords(String query, int page, int pageSize) {
    List<dynamic>? keywords = getQueryablePaginatedList(query, page, pageSize, 'keywords');

    if (keywords != null) {
      return keywords.cast<Keyword>();
    }

    return null;
  }

  upsertKeywords(List<Keyword> keywords) {
    upsertEntityList(keywords, 'keywords');
  }
}