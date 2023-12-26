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
}
