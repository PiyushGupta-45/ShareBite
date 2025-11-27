import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:food_donation_app/core/constants/api_constants.dart';
import 'package:food_donation_app/domain/entities/ngo.dart';

class NgoRemoteDataSource {
  final http.Client _client = http.Client();
  static const Duration _timeoutDuration = Duration(seconds: 30);

  Future<List<NGO>> getAllNGOs() async {
    try {
      final response = await _client
          .get(Uri.parse('${ApiConstants.baseUrl}/ngos'))
          .timeout(_timeoutDuration);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        final ngosList = data['data']['ngos'] as List<dynamic>;
        return ngosList.map((ngoJson) => _ngoFromJson(ngoJson as Map<String, dynamic>)).toList();
      } else {
        throw Exception(data['message'] as String? ?? 'Failed to fetch NGOs');
      }
    } catch (e) {
      throw Exception('Failed to fetch NGOs: ${e.toString()}');
    }
  }

  Future<NGO> getNGOById(String id) async {
    try {
      final response = await _client
          .get(Uri.parse('${ApiConstants.baseUrl}/ngos/$id'))
          .timeout(_timeoutDuration);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return _ngoFromJson(data['data']['ngo'] as Map<String, dynamic>);
      } else {
        throw Exception(data['message'] as String? ?? 'Failed to fetch NGO');
      }
    } catch (e) {
      throw Exception('Failed to fetch NGO: ${e.toString()}');
    }
  }

  Future<NGO> createNGO({
    required String token,
    required String name,
    required String tagline,
    required String description,
    required String location,
    required String address,
    required double latitude,
    required double longitude,
    required String email,
    required String phone,
    String? website,
    String? mainImage,
    List<String>? images,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConstants.baseUrl}/ngos'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'name': name,
              'tagline': tagline,
              'description': description,
              'location': location,
              'address': address,
              'latitude': latitude,
              'longitude': longitude,
              'email': email,
              'phone': phone,
              if (website != null && website.isNotEmpty) 'website': website,
              if (mainImage != null && mainImage.isNotEmpty) 'mainImage': mainImage,
              if (images != null && images.isNotEmpty) 'images': images,
            }),
          )
          .timeout(_timeoutDuration);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 && data['success'] == true) {
        return _ngoFromJson(data['data']['ngo'] as Map<String, dynamic>);
      } else {
        throw Exception(data['message'] as String? ?? 'Failed to create NGO');
      }
    } catch (e) {
      throw Exception('Failed to create NGO: ${e.toString()}');
    }
  }

  NGO _ngoFromJson(Map<String, dynamic> json) {
    return NGO(
      id: json['id'] as String,
      name: json['name'] as String,
      tagline: json['tagline'] as String,
      mainImage: json['mainImage'] as String? ?? '',
      images: (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      description: json['description'] as String,
      location: json['location'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}

