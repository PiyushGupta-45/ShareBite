import 'dart:convert';
import 'package:food_donation_app/data/datasources/auth_remote_datasource.dart';
import 'package:food_donation_app/domain/entities/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepositoryImpl {
  final AuthRemoteDataSource _remoteDataSource;
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  AuthRepositoryImpl(this._remoteDataSource);

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    final result = await _remoteDataSource.signIn(
      email: email,
      password: password,
    );
    
    // Save token and user data
    await _saveAuthData(
      result['token'] as String,
      result['user'] as User,
    );
    
    return result;
  }

  Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final result = await _remoteDataSource.signUp(
      name: name,
      email: email,
      password: password,
    );
    
    // Save token and user data
    await _saveAuthData(
      result['token'] as String,
      result['user'] as User,
    );
    
    return result;
  }

  Future<Map<String, dynamic>> signInWithGoogle({
    required String tokenId,
  }) async {
    final result = await _remoteDataSource.signInWithGoogle(
      tokenId: tokenId,
    );
    
    // Save token and user data
    await _saveAuthData(
      result['token'] as String,
      result['user'] as User,
    );
    
    return result;
  }

  Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<User?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJsonString = prefs.getString(_userKey);
    if (userJsonString != null) {
      try {
        final userJson = jsonDecode(userJsonString) as Map<String, dynamic>;
        return User.fromJson(userJson);
      } catch (e) {
        // If stored data is invalid, fetch from API
        final token = await getStoredToken();
        if (token != null) {
          try {
            return await _remoteDataSource.getCurrentUser(token);
          } catch (e) {
            return null;
          }
        }
      }
    } else {
      // If no stored user, try fetching from API if token exists
      final token = await getStoredToken();
      if (token != null) {
        try {
          return await _remoteDataSource.getCurrentUser(token);
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<void> _saveAuthData(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    // Store user as JSON string
    final userJsonString = jsonEncode(user.toJson());
    await prefs.setString(_userKey, userJsonString);
  }
}

