import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/models/work_shift.dart';

class ShiftRepository {
  ShiftRepository(this.client);
  final http.Client client;
  static const String baseUrl = 'http://127.0.0.1:8000';

  Future<Map<String, dynamic>> saveShift(WorkShift shift) async {
    final response = await client.post(
      Uri.parse('$baseUrl/shifts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'location': shift.location,
        'start_time': shift.startTime.toIso8601String(),
        'end_time': shift.endTime.toIso8601String(),
        'unpaid_break_minutes': shift.unpaidBreakMinutes,
        'hourly_rate': shift.hourlyRate,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception(
        'Unable to save shift: ${response.statusCode} ${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getShifts() async {
    final response = await client.get(Uri.parse('$baseUrl/shifts'));

    if (response.statusCode != 200) {
      throw Exception('Unable to load shifts: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as List<dynamic>;

    return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }
}
