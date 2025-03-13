import 'dart:convert';
import 'package:annora_survey/models/task.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class TaskViewModel {
  Future<Map<String, dynamic>> getTasks(String email, bool isNew) async {
    List<Task> tasks = [];
    final String taskUrl = isNew 
    ? dotenv.env['GET_NEW_TASK_URL'] ?? '' 
    : dotenv.env['GET_ALL_TASK_URL'] ?? '';


    if (taskUrl.isEmpty) {
      return {'success': false, 'message': 'API URL is not available'};
    }

    try {
      final response = await http.post(
        Uri.parse(taskUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'email': email},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['message'] == 'Success' && data['data'] != null) {
          if (data['data'] is List) {
            tasks =
                (data['data'] as List).map((taskData) {
                  return Task(
                    projectID:
                        int.tryParse(
                          taskData['project_id']?.toString() ?? '0',
                        ) ??
                        0,
                    woID:
                        int.tryParse(
                          taskData['project_id']?.toString() ?? '0',
                        ) ??
                        0,
                    startDate:
                        DateTime.tryParse(taskData['start_date'] ?? '') ??
                        DateTime.now(),
                    targetDate:
                        DateTime.tryParse(taskData['target_date'] ?? '') ??
                        DateTime.now(),
                    nameProject: taskData['nmproject'] ?? 'Unknown Project',
                    company: taskData['company'] ?? 'Unknown Company',
                    customerName:
                        taskData['customer_name'] ?? 'Unknown Customer',
                    address: taskData['address'] ?? 'Unknown Address',
                    category: taskData['category'] ?? 'Unknown Category',
                    surveyType:
                        taskData['survey_type'] ?? 'Unknown Survey Type',
                    surveyorName:
                        taskData['surveyor_name'] ?? 'Unknown Surveyor',
                    surveyorEmail:
                        taskData['surveyor_email'] ?? 'Unknown Email',
                    progress:
                        int.tryParse(taskData['progress']?.toString() ?? '0') ??
                        0,
                    status: taskData['status'] ?? 'Unknown Status',
                  );
                }).toList();
          } else {
            return {
              'success': false,
              'message': 'Invalid data format received',
            };
          }
        }
        return {'success': true, 'data': tasks};
      } else {
        return {
          'success': false,
          'message': 'Fetching tasks failed: ${response.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
