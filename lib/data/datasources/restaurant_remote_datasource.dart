import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:food_donation_app/core/constants/api_constants.dart';
import 'package:food_donation_app/domain/entities/restaurant.dart';

class RestaurantRemoteDataSource {
  final http.Client _client = http.Client();
  static const Duration _timeoutDuration = Duration(seconds: 30);

  Future<List<Restaurant>> getAllRestaurants() async {
    try {
      final response = await _client
          .get(Uri.parse('${ApiConstants.baseUrl}/restaurants'))
          .timeout(_timeoutDuration);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        final restaurantsList = data['data']['restaurants'] as List<dynamic>;
        return restaurantsList
            .map((restaurantJson) => _restaurantFromJson(restaurantJson as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(data['message'] as String? ?? 'Failed to fetch restaurants');
      }
    } catch (e) {
      throw Exception('Failed to fetch restaurants: ${e.toString()}');
    }
  }

  Future<Restaurant> getRestaurantById(String id) async {
    try {
      final response = await _client
          .get(Uri.parse('${ApiConstants.baseUrl}/restaurants/$id'))
          .timeout(_timeoutDuration);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return _restaurantFromJson(data['data']['restaurant'] as Map<String, dynamic>);
      } else {
        throw Exception(data['message'] as String? ?? 'Failed to fetch restaurant');
      }
    } catch (e) {
      throw Exception('Failed to fetch restaurant: ${e.toString()}');
    }
  }

  Future<Restaurant> createRestaurant({
    required String token,
    required String name,
    required String location,
    required String address,
    required double latitude,
    required double longitude,
    required String email,
    required String phone,
    String? description,
    String? website,
    String? image,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConstants.baseUrl}/restaurants'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'name': name,
              'location': location,
              'address': address,
              'latitude': latitude,
              'longitude': longitude,
              'email': email,
              'phone': phone,
              if (description != null && description.isNotEmpty) 'description': description,
              if (website != null && website.isNotEmpty) 'website': website,
              if (image != null && image.isNotEmpty) 'image': image,
            }),
          )
          .timeout(_timeoutDuration);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 && data['success'] == true) {
        return _restaurantFromJson(data['data']['restaurant'] as Map<String, dynamic>);
      } else {
        throw Exception(data['message'] as String? ?? 'Failed to create restaurant');
      }
    } catch (e) {
      throw Exception('Failed to create restaurant: ${e.toString()}');
    }
  }

  Restaurant _restaurantFromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      image: json['image'] as String?,
      description: json['description'] as String?,
      website: json['website'] as String?,
    );
  }
}

