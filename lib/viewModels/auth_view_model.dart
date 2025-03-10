import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:annora_survey/models/user.dart';

class LoginViewModel {
  Future<Map<String, dynamic>> login(String username, String password) async {
    User? currentUser;
    final String loginUrl = dotenv.env['LOGIN_URL'] ?? '';

    if (loginUrl.isEmpty) {
      return {'success': false, 'message': 'API URL not set in .env'};
    }

    String rawJson = '{"email": "$username", "password": "$password"}';

    try {
      final response = await http.post(Uri.parse(loginUrl), body: rawJson);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          currentUser = User(
            id: int.parse(data['data']['id']),
            name: (data['data']['name']),
            email: (data['data']['email']),
            phone: (data['data']['phone']),
            region: (data['data']['region']),
            token: (data['data']['token']),
          );
          print(currentUser.token);
        }
        return {'success': true, 'data': currentUser};
      } else {
        return {'success': false, 'message': 'Login failed: ${response.body}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
