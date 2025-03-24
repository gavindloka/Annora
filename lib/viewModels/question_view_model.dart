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

  Future<Map<String,dynamic>> getTitlePhoto(String formID)async{
    final String url = dotenv.env['GET_TITLE_PHOTO_URL']??'';
    if(url.isEmpty){
      return {'success': false, 'message': 'API URL is not available'};
    }
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'form_id': formID},
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

  Future<Map<String, dynamic>> addCoordinate(
    String projectID,
    String latitude,
    String longitude,
  ) async {
    final String url = dotenv.env['ADD_COORDINATE_SURVEY_URL'] ?? '';
    final Map<String, dynamic> payload = {
      'project_id': projectID,
      'coordinate_survey': {'lat': latitude, 'long': longitude},
    };
    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(payload),
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {
          'success': false,
          'message': 'Failed to add coordinate: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> addPhoto(
    String projectID,
    String title,
    String photo,
    String coordinate,
  ) async {
    final String url = dotenv.env['ADD_PHOTO_URL'] ?? '';
    try {
      final Map<String, dynamic> payload = {
        'id_project': projectID,
        'title': title,
        'photo': photo,
        'coordinate': coordinate,
      };
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {
          'success': false,
          'message': 'Failed to add photo: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> getSurveyResult(String projectID) async {
    final String url = dotenv.env['GET_PROJECT_RESULT_URL'] ?? '';

    if (url.isEmpty) {
      return {'success': false, 'message': 'API URL is not available'};
    }
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'id_project': projectID},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['message'] == 'Success' && data['data'] != null) {
          List<dynamic> surveyResults = data['data']['survey_results'];
          List<Map<String, dynamic>> formattedResults =
              surveyResults
                  .map(
                    (result) => {
                      'question': result['pertanyaan'],
                      'answer': result['jawaban'],
                      'question_id': result['id_pertanyaan'],
                    },
                  )
                  .toList();

          String lat = data['data']['coordinate_survey']['lat'];
          String long = data['data']['coordinate_survey']['long'];
          return {
            'success': true,
            'message': 'Survey results fetched successfully',
            'results': formattedResults,
            'latitude': lat,
            'longitude': long,
          };
        } else {
          return {
            'success': false,
            'message': 'Failed to get survey result: ${data['message']}',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Failed to get survey result: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> getSurveyPhoto(String projectID) async {
    final String url = dotenv.env['GET_PROJECT_PHOTO_URL'] ?? '';

    if (url.isEmpty) {
      return {'success': false, 'message': 'API URL is not available'};
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'id_project': projectID},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['message'] == 'Success' && data['results'] != null) {
          List<dynamic> surveyResults = data['results'];
          List<Map<String, dynamic>> formattedResults =
              surveyResults
                  .map(
                    (result) => {
                      'id': result['id'],
                      'id_project': result['id_project'],
                      'title': result['title'],
                      'photo': result['photo'],
                      'coordinate': result['coordinate'],
                      'datetime': result['datetime'],
                    },
                  )
                  .toList();
          return {
            'success': true,
            'message': 'Survey photos fetched successfully',
            'results': formattedResults,
          };
        } else {
          return {
            'success': false,
            'message': 'Failed to get survey photo: ${data['message']}',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Failed to get survey result: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

}
