import 'dart:convert';

import 'package:annora_survey/models/notif.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class NotifViewModel {
  
  Future<Map<String, dynamic>> getNotifications(String email) async {
    final String url = dotenv.env['GET_NOTIFICATIONS_URL'] ?? '';

    if (url.isEmpty) {
      return {'success': false, 'message': 'API URL is not available'};
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'email': email},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Raw API Response: ${response.body}");
        if (data['message'] == 'Success' && data['data'] is List) {
          List<dynamic> notifications =
              (data['data'] as List)
                  .map(
                    (result) => Notif(
                      id: result['id'],
                      email: result['email'],
                      notification: result['notification'],
                      status: result['status'],
                      date: DateTime.parse(result['date']),
                    ),
                  )
                  .toList();
          return {'success': true, 'data': notifications};
        }
      }
      print("Raw API Response: ${response.body}");
      return {'success': false, 'message': 'Failed to fetch notifications'};
      
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
