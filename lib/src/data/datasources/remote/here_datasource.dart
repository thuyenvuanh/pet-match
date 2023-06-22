import 'dart:convert';
import 'dart:developer' show log;

import 'package:pet_match/src/api/here_map_api.dart';
import 'package:http/http.dart' show get;

class HereDatasource {
  static const hereMapApiEndpoint =
      "https://geocode.search.hereapi.com/v1/geocode";
  static final defaultUri = Uri(
    scheme: 'https',
    host: 'geocode.search.hereapi.com',
    path: '/v1/geocode',
  );

  static final params = {
    "apiKey": "wlVxZlE7p6moApTUf6ietgTA3k4Dc87HNfJDJSKJxB0",
    "limit": "10",
  };

  Future<List<HereMapResponse>> getAddressData(String address) async {
    try {
      var newParams = Map<String, dynamic>.from(params)..addAll({"q": address});
      var uri = defaultUri.replace(queryParameters: newParams);
      final res = await get(uri);
      if (res.statusCode == 200) {
        String uniDecode = utf8.decode(res.bodyBytes);
        List<Map<String, dynamic>> decodedAddressMap =
            List.from(json.decode(uniDecode)['items']);
        return decodedAddressMap
            .map((e) => HereMapResponse.fromJson(e))
            .toList();
      } else {
        log('[Here_data] request get failed with status code ${res.statusCode}');
        throw Exception('Status code error: ${res.body}');
      }
    } catch (e) {
      log('[Here_data] cannot get response from Here Map. ${e.runtimeType.toString()}');
      rethrow;
    }
  }
}
