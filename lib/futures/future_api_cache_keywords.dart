// ignore_for_file: unused_catch_clause

import 'package:untare/exceptions/api_connection_exception.dart';
import 'package:untare/models/keyword.dart';
import 'package:untare/services/api/api_keyword.dart';
import 'package:untare/services/cache/cache_keyword_service.dart';

Future getKeywordsFromApiCache(String query) async {
  final CacheKeywordService cacheKeywordService = CacheKeywordService();
  final ApiKeyword apiKeyword = ApiKeyword();

  List<Keyword>? cacheKeywords = cacheKeywordService.getKeywords(query, 1, 25);

  if (cacheKeywords != null && cacheKeywords.isNotEmpty) {
    return cacheKeywords;
  }

  try {
    Future<List<Keyword>> keywords = apiKeyword.getKeywords(query, 1, 25);
    keywords.then((value) => cacheKeywordService.upsertKeywords(value));
    return keywords;
  } on ApiConnectionException catch (e) {
    // Do nothing
  }
}