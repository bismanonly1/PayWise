import 'dart:convert';

import 'package:http/http.dart' as http;

class HealthRepository {
  final http.Client client;

  HealthRepository(this.client);

  Future<String> checkHealth() async {
    final response = await client.get(
      Uri.parse('http://127.0.0.1:8000/health'),
    );

    if (response.statusCode != 200) {
      throw Exception('Backend error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['status'] as String;
  }
}
