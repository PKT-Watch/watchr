//import 'dart:math';
import 'dart:convert';

import 'package:http/http.dart' as http;
import '../../globals/globals.dart' as globals;

class API {
  static Future<http.Response> makeRequest(String endPoint) async {
    final response = await http.get(Uri.parse('${API.getUrl()}$endPoint'));
    return response;
  }

  static String getUrl({bool fallback = false}) {
    if (fallback) {
      return globals.explorerAPIs[1];
    }

    return globals.explorerAPIs[0];
  }

  static Future<void> getPrice() async {
    final response = await http.get(Uri.parse('https://api.pkt.watch/v1/network/price'));
    if (response.statusCode == 200) {
      globals.pricePkt = json.decode(response.body)['pkt'];
    }
  }
}
