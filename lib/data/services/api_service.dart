import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'https://stara-media-default-rtdb.asia-southeast1.firebasedatabase.app/staramedia.json';

  static Future<Map<String, dynamic>> fetchAllData() async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    final decoded = json.decode(response.body);
    return Map<String, dynamic>.from(decoded);
  }
}
