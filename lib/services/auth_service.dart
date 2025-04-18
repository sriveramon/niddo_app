import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

class AuthService {
  // Create a logger instance
  static var logger = Logger(printer: PrettyPrinter());

  // Get the API_URL from .env, or throw an error if it's not found
  static String get baseUrl {
    final url = dotenv.env['API_URL'];
    if (url == null) {
      throw Exception('API_URL not found in .env file');
    }
    return url;
  }

  static Future<String?> login(String email, String password) async {
    logger.i('Attempting to log in with email: $email');
    logger.i('Using API URL: $baseUrl');

    final url = Uri.parse('$baseUrl/auth/login');
    logger.d('Login request URL: $url');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      logger.i('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final token = body['access_token'];
        logger.i('Login successful.');
        return token;
      } else {
        logger.e('Login failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      logger.e('Error during login: $e');
      return null;
    }
  }
}
