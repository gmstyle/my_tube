import 'dart:convert';

import 'package:http/http.dart' as http;

class BaseProvider {
  Future<String> getCountryCode() async {
    try {
      final response = await http.get(Uri.parse('https://api.country.is'));
      final json = jsonDecode(response.body);
      return json['country'];
    } catch (error) {
      return Future.error('Error: $error');
    }
  }

  //get an image from the url and return it as base64
  Future<String> getBase64Image(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      final bytes = response.bodyBytes;
      return base64Encode(bytes);
    } catch (error) {
      return Future.error('Error: $error');
    }
  }
}
