import 'dart:convert';
import 'package:http/http.dart' as http;

class RequestHelper {
  static Future<dynamic> getRequest(String url) async {
    http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      String data = response.body;
      return jsonDecode(data);
    } else {
      throw Exception('Failed to load data');
    }
  }

  static Future<dynamic> postRequest(
      String url, Map<String, dynamic> data) async {
    http.Response response = await http.post(Uri.parse(url), body: data);

    if (response.statusCode == 200) {
      String data = response.body;
      return jsonDecode(data);
    } else {
      throw Exception('Failed to post data');
    }
  }

  static Future<dynamic> putRequest(
      String url, Map<String, dynamic> data) async {
    http.Response response = await http.put(Uri.parse(url), body: data);

    if (response.statusCode == 200) {
      String data = response.body;
      return jsonDecode(data);
    } else {
      throw Exception('Failed to put data');
    }
  }

  static Future<dynamic> deleteRequest(String url) async {
    http.Response response = await http.delete(Uri.parse(url));

    if (response.statusCode == 200) {
      String data = response.body;
      return jsonDecode(data);
    } else {
      throw Exception('Failed to delete data');
    }
  }
}
