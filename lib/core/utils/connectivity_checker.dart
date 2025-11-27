import 'dart:io';
import 'package:http/http.dart' as http;

class ConnectivityChecker {
  static Future<bool> checkBackendConnection(String baseUrl) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/test'))
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<String> getConnectionStatus(String baseUrl) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/test'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return '✅ Connected to backend';
      } else {
        return '❌ Backend returned error: ${response.statusCode}';
      }
    } on SocketException catch (e) {
      return '❌ Cannot connect: ${e.message}\n\nMake sure:\n1. Backend is running (cd backend && npm run dev)\n2. Backend URL is correct: $baseUrl\n3. Firewall allows connections on port 5000';
    } catch (e) {
      return '❌ Connection failed: ${e.toString()}';
    }
  }
}

