import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:food_donation_app/core/constants/api_constants.dart';
import 'package:food_donation_app/domain/entities/user.dart';

class AuthRemoteDataSource {
  // Create HTTP client with longer timeout
  final http.Client _client = http.Client();
  
  // Timeout duration
  static const Duration _timeoutDuration = Duration(seconds: 60);

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client
          .post(
        Uri.parse(ApiConstants.signIn),
        headers: {
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      )
          .timeout(
        _timeoutDuration,
        onTimeout: () {
          throw Exception('Request timeout: Backend server is not responding. Please check if the server is running at ${ApiConstants.signIn}');
        },
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'token': data['data']['token'] as String,
          'user': User.fromJson(data['data']['user'] as Map<String, dynamic>),
        };
      } else {
        throw Exception(data['message'] as String? ?? 'Sign in failed');
      }
    } on TimeoutException {
      throw Exception('Request timeout after 60 seconds. The backend server is taking too long to respond. Please check:\n1. Backend server is running (cd backend && npm run dev)\n2. Backend URL is correct: ${ApiConstants.signIn}\n3. Network connection is stable\n4. Backend is not overloaded');
    } on http.ClientException catch (e) {
      throw Exception('Connection failed: Unable to reach backend server. Make sure the backend is running at ${ApiConstants.signIn}. Error: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Invalid response from server: ${e.message}');
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('timeout') || errorMsg.contains('TimeoutException')) {
        throw Exception('Request timeout: Backend server is not responding. Please check if the server is running at ${ApiConstants.signIn}');
      }
      if (errorMsg.contains('SocketException') || errorMsg.contains('Failed host lookup') || errorMsg.contains('Connection refused')) {
        throw Exception('Cannot connect to backend server. Please check:\n1. Backend server is running\n2. API URL is correct: ${ApiConstants.signIn}\n3. Network connection is active');
      }
      throw Exception('Sign in failed: ${errorMsg.replaceFirst('Exception: ', '')}');
    }
  }

  Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client
          .post(
        Uri.parse(ApiConstants.signUp),
        headers: {
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      )
          .timeout(
        _timeoutDuration,
        onTimeout: () {
          throw Exception('Request timeout: Backend server is not responding. Please check if the server is running at ${ApiConstants.signUp}');
        },
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 && data['success'] == true) {
        return {
          'success': true,
          'token': data['data']['token'] as String,
          'user': User.fromJson(data['data']['user'] as Map<String, dynamic>),
        };
      } else {
        throw Exception(data['message'] as String? ?? 'Sign up failed');
      }
    } on TimeoutException {
      throw Exception('Request timeout after 60 seconds. The backend server is taking too long to respond. Please check:\n1. Backend server is running (cd backend && npm run dev)\n2. Backend URL is correct: ${ApiConstants.signUp}\n3. Network connection is stable\n4. Backend is not overloaded');
    } on http.ClientException catch (e) {
      throw Exception('Connection failed: Unable to reach backend server. Make sure the backend is running at ${ApiConstants.signUp}. Error: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Invalid response from server: ${e.message}');
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('timeout') || errorMsg.contains('TimeoutException')) {
        throw Exception('Request timeout: Backend server is not responding. Please check if the server is running at ${ApiConstants.signUp}');
      }
      if (errorMsg.contains('SocketException') || errorMsg.contains('Failed host lookup') || errorMsg.contains('Connection refused')) {
        throw Exception('Cannot connect to backend server. Please check:\n1. Backend server is running\n2. API URL is correct: ${ApiConstants.signUp}\n3. Network connection is active');
      }
      throw Exception('Sign up failed: ${errorMsg.replaceFirst('Exception: ', '')}');
    }
  }

  Future<Map<String, dynamic>> signInWithGoogle({
    required String tokenId,
  }) async {
    try {
      final response = await _client
          .post(
        Uri.parse(ApiConstants.googleAuth),
        headers: {
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'tokenId': tokenId,
        }),
      )
          .timeout(
        _timeoutDuration,
        onTimeout: () {
          throw Exception('Request timeout: Backend server is not responding. Please check if the server is running at ${ApiConstants.googleAuth}');
        },
      );

      // Handle 404 or route not found
      if (response.statusCode == 404) {
        throw Exception('Route not found: ${ApiConstants.googleAuth}. Please check:\n1. Backend is deployed correctly on Render\n2. Route /api/auth/google exists\n3. Backend URL is correct: ${ApiConstants.baseUrl}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if ((response.statusCode == 200 || response.statusCode == 201) && data['success'] == true) {
        return {
          'success': true,
          'token': data['data']['token'] as String,
          'user': User.fromJson(data['data']['user'] as Map<String, dynamic>),
        };
      } else {
        final errorMsg = data['message'] as String? ?? 'Google sign in failed';
        throw Exception('$errorMsg (Status: ${response.statusCode}, URL: ${ApiConstants.googleAuth})');
      }
    } on http.ClientException catch (e) {
      throw Exception('Connection failed: Unable to reach backend server. Make sure the backend is running at ${ApiConstants.googleAuth}. Error: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Invalid response from server: ${e.message}');
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('SocketException') || errorMsg.contains('Failed host lookup') || errorMsg.contains('Connection refused')) {
        throw Exception('Cannot connect to backend server. Please check:\n1. Backend server is running\n2. API URL is correct: ${ApiConstants.googleAuth}\n3. Network connection is active');
      }
      throw Exception('Google sign in failed: ${errorMsg.replaceFirst('Exception: ', '')}');
    }
  }

  Future<User> getCurrentUser(String token) async {
    try {
      final response = await _client
          .get(
        Uri.parse(ApiConstants.getCurrentUser),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      )
          .timeout(
        _timeoutDuration,
        onTimeout: () {
          throw Exception('Request timeout: Backend server is not responding. Please check if the server is running at ${ApiConstants.getCurrentUser}');
        },
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return User.fromJson(data['data']['user'] as Map<String, dynamic>);
      } else {
        throw Exception(data['message'] as String? ?? 'Failed to get user');
      }
    } catch (e) {
      throw Exception('Failed to get current user: ${e.toString()}');
    }
  }
}
