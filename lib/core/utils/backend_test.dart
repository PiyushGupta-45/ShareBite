import 'package:http/http.dart' as http;
import 'package:food_donation_app/core/constants/api_constants.dart';

class BackendTest {
  static Future<Map<String, dynamic>> testConnection() async {
    final results = <String, dynamic>{};

    // Test 1: Root endpoint
    try {
      final response = await http
          .get(Uri.parse('https://sharebite-hst4.onrender.com'))
          .timeout(const Duration(seconds: 10));
      results['root'] = {
        'status': response.statusCode,
        'body': response.body.substring(0, 200),
      };
    } catch (e) {
      results['root'] = {'error': e.toString()};
    }

    // Test 2: Health endpoint
    try {
      final response = await http
          .get(Uri.parse('https://sharebite-hst4.onrender.com/health'))
          .timeout(const Duration(seconds: 10));
      results['health'] = {
        'status': response.statusCode,
        'body': response.body.substring(0, 200),
      };
    } catch (e) {
      results['health'] = {'error': e.toString()};
    }

    // Test 3: API test endpoint
    try {
      final response = await http
          .get(Uri.parse('${ApiConstants.baseUrl}/test'))
          .timeout(const Duration(seconds: 10));
      results['api_test'] = {
        'status': response.statusCode,
        'body': response.body.substring(0, 200),
      };
    } catch (e) {
      results['api_test'] = {'error': e.toString()};
    }

    // Test 4: Google auth endpoint (should return 400/401, not 404)
    try {
      final response = await http
          .post(
            Uri.parse(ApiConstants.googleAuth),
            headers: {'Content-Type': 'application/json'},
            body: '{}',
          )
          .timeout(const Duration(seconds: 10));
      results['google_auth'] = {
        'status': response.statusCode,
        'body': response.body.substring(0, 200),
        'url': ApiConstants.googleAuth,
      };
    } catch (e) {
      results['google_auth'] = {
        'error': e.toString(),
        'url': ApiConstants.googleAuth,
      };
    }

    return results;
  }
}

