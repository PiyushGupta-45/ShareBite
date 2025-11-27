import 'dart:io';

class ApiConstants {
  // Backend URL configuration
  //
  // PRODUCTION (Render):
  // - Use your Render backend URL (e.g., https://your-app.onrender.com)
  // - Make sure to include /api at the end if your backend serves API routes under /api
  //
  // DEVELOPMENT (Local):
  // - For Android Emulator: http://10.0.2.2:5000/api
  // - For Physical Device: http://YOUR_COMPUTER_IP:5000/api
  // - For iOS Simulator: http://localhost:5000/api

  // Render backend URL (PRODUCTION)
  // Remove trailing slash - it will be added by route paths
  static const String renderBaseUrl = 'https://sharebite-hst4.onrender.com';

  // Local development IP (for physical devices)
  // Update this to match your computer's actual IP address
  // Find it by running: ipconfig (Windows) or ifconfig (Mac/Linux)
  static const String computerIP = '10.63.174.107';

  // Set to true to use Render backend, false for local development
  static const bool useProductionBackend = true;

  static String get baseUrl {
    // You can override with environment variable when running:
    // flutter run --dart-define=API_BASE_URL=https://sharebite-hst4.onrender.com/api
    const customUrl = String.fromEnvironment('API_BASE_URL');
    if (customUrl.isNotEmpty) {
      return customUrl;
    }

    // Use Render backend if enabled
    if (useProductionBackend) {
      // Make sure your Render URL includes /api if needed
      // If your backend serves routes directly at root, remove /api
      return '$renderBaseUrl/api';
    }

    // Local development URLs
    if (Platform.isAndroid) {
      // For Android Emulator, use: 'http://10.0.2.2:5000/api'
      // For Physical Device, use your computer's IP
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
