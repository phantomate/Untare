import 'package:tare/exceptions/api_connection_exception.dart';
import 'package:tare/models/keyword.dart';
import 'package:tare/services/api/api_keyword.dart';
import 'package:tare/services/cache/cache_keyword_service.dart';

Future getKeywordsFromApiCache(String query) async {
  final CacheKeywordService _cacheKeywordService = CacheKeywordService();
  final ApiKeyword _apiKeyword = ApiKeyword();

  List<Keyword>? cacheKeywords = _cacheKeywordService.getKeywords(query, 1, 25);
print('hier hin');
  if (cacheKeywords != null) {
    return cacheKeywords;
  }
print('duduedeuded');
  try {
    Future<List<Keyword>> keywords = _apiKeyword.getKeywords(query, 1, 25);
    keywords.then((value) => _cacheKeywordService.upsertKeywords(value));
    return keywords;
  } on ApiConnectionException catch (e) {
    // Do nothing
  }
}