import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'https://realrikisaputra.github.io/staramedia/stara.json';

  static Future<Map<String, dynamic>> fetchAllData() async {
    try {
      print('=== FETCH JSON START ===');
      print('URL: $baseUrl');

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Accept': 'application/json',
        },
      );

      print('STATUS CODE: ${response.statusCode}');
      print('HEADERS: ${response.headers}');
      print('BODY RAW: ${response.body}');

      final decoded = json.decode(response.body);

      print('DECODE TYPE: ${decoded.runtimeType}');
      print('DECODE KEYS: ${(decoded as Map).keys}');

      return Map<String, dynamic>.from(decoded);
    } catch (e, stack) {
      print('❌ ERROR FETCH JSON');
      print(e);
      print(stack);
      rethrow;
    }
  }
}
