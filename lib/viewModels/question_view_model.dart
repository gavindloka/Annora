import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class QuestionViewModel {
  Future<Map<String, dynamic>> getSurveyProjectForm(String projectID) async {
    final String getSurveyUrl = dotenv.env['GET_SURVEY_PROJECT_FORM_URL'] ?? '';
    if (getSurveyUrl.isEmpty) {
      return {'success': false, 'message': 'API URL is not available'};
    }

    try {
      final response = await http.post(
        Uri.parse(getSurveyUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'project_id': projectID},
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
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

  Future<Map<String, dynamic>> addSurveyResult(
    Map<String, dynamic> surveyData,
  ) async {
    final String apiUrl = dotenv.env['ADD_RESULT_URL'] ?? '';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode(surveyData),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {
          'success': false,
          'message': 'Failed to add survey result: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
