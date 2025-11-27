import 'dart:io';

class ApiConstants {
  // Backend URL configuration for PHYSICAL DEVICE
  //
  // IMPORTANT:
  // - 10.0.2.2 ONLY works inside Android Emulator (NOT on physical devices!)
  // - For physical devices, you MUST use your computer's IP address
  // - Make sure your phone and computer are on the same WiFi network
  //
  // Your computer's IP address: 192.168.1.11
  // Update this if your IP changes or if you use a different network

  // Computer's IP address on your WiFi network
  // Update this to match your computer's actual IP address
  // Find it by running: ipconfig (Windows) or ifconfig (Mac/Linux)
  // Look for the IP under your WiFi adapter (usually starts with 192.168.x.x or 10.x.x.x)
  static const String computerIP = '10.63.174.107'; // Update this to your actual WiFi IP

  static String get baseUrl {
    // You can override with environment variable when running:
    // flutter run --dart-define=API_BASE_URL=http://192.168.1.11:5000/api
    const customUrl = String.fromEnvironment('API_BASE_URL');
    if (customUrl.isNotEmpty) {
      return customUrl;
    }

    // Default URLs for development
    if (Platform.isAndroid) {
      // Using computer IP for physical device
      // If you want to use emulator, change to: 'http://10.0.2.2:5000/api'
      return 'http://$computerIP:5000/api';
    } else if (Platform.isIOS) {
      // iOS simulator can use localhost
      return 'http://localhost:5000/api';
    } else {
      // Web, desktop, etc.
      return 'http://localhost:5000/api';
    }
  }

  static String get authBase => '$baseUrl/auth';

  static String get signIn => '$authBase/signin';
  static String get signUp => '$authBase/signup';
  static String get googleAuth => '$authBase/google';
  static String get getCurrentUser => '$authBase/me';
  static String get verifyToken => '$authBase/verify';
}
