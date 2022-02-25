import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:inspireui/utils/logs.dart';

import '../common/config.dart';

const kWebProxy = '';
const isBuilder = false;

/// The default http GET that support Logging
Future<http.Response> httpCache(
  Uri url, {
  Map<String, String>? headers,
  bool refreshCache = false,
}) async {
  final startTime = DateTime.now();

  var uri = url;
  if (foundation.kIsWeb) {
    final proxyURL = '$kWebProxy$url';
    uri = Uri.parse(proxyURL);
  }

  if (refreshCache) {
    await DefaultCacheManager().removeFile(uri.toString());
    printLog('🔴 REMOVE CACHE:$url', startTime);
  }

  // Enable default on FluxBuilder
  if ((kAdvanceConfig['httpCache'] ?? true) || isBuilder) {
    try {
      var file = await DefaultCacheManager()
          .getSingleFile(uri.toString(), headers: headers);
      if (await file.exists()) {
        var res = await file.readAsString();

        printLog('📥 GET CACHE:$url', startTime);
        return http.Response(res, 200);
      }
      return http.Response('', 404);
    } catch (e) {
      // printLog(trace);
      printLog('CACHE ISSUE: ${e.toString()}', startTime);
    }
  }

  printLog('♻️ GET:$url', startTime);
  return await http.get(uri, headers: headers);
}
