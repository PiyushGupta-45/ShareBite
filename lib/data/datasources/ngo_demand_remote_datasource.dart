import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:food_donation_app/core/constants/api_constants.dart';
import 'package:food_donation_app/domain/entities/ngo_demand.dart';

class NgoDemandRemoteDataSource {
  final http.Client _client = http.Client();
  static const Duration _timeoutDuration = Duration(seconds: 30);

  Future<List<NGODemand>> getAllDemands(String token) async {
    try {
      final response = await _client
          .get(
            Uri.parse('${ApiConstants.baseUrl}/ngo-demands'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(_timeoutDuration);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        final demandsList = data['data']['demands'] as List<dynamic>;
        return demandsList
            .map((demandJson) => NGODemand.fromJson(demandJson as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(data['message'] as String? ?? 'Failed to fetch demands');
      }
    } catch (e) {
      throw Exception('Failed to fetch demands: ${e.toString()}');
    }
  }

  Future<List<NGODemand>> getDemandsByNGO(String token, String ngoId) async {
    try {
      final response = await _client
          .get(
            Uri.parse('${ApiConstants.baseUrl}/ngo-demands/ngo/$ngoId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(_timeoutDuration);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        final demandsList = data['data']['demands'] as List<dynamic>;
        return demandsList
            .map((demandJson) => NGODemand.fromJson(demandJson as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(data['message'] as String? ?? 'Failed to fetch demands');
      }
    } catch (e) {
      throw Exception('Failed to fetch demands: ${e.toString()}');
    }
  }

  Future<NGODemand> createDemand({
    required String token,
    required String ngoId,
    required int amount,
    required String unit,
    required DateTime requiredBy,
    String? description,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConstants.baseUrl}/ngo-demands'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'ngoId': ngoId,
              'amount': amount,
              'unit': unit,
              'requiredBy': requiredBy.toIso8601String(),
              if (description != null && description.isNotEmpty) 'description': description,
            }),
          )
          .timeout(_timeoutDuration);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 && data['success'] == true) {
        return NGODemand.fromJson(data['data']['demand'] as Map<String, dynamic>);
      } else {
        throw Exception(data['message'] as String? ?? 'Failed to create demand');
      }
    } catch (e) {
      throw Exception('Failed to create demand: ${e.toString()}');
    }
  }

  Future<void> acceptDemand(String token, String demandId) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConstants.baseUrl}/ngo-demands/$demandId/accept'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(_timeoutDuration);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200 || data['success'] != true) {
        throw Exception(data['message'] as String? ?? 'Failed to accept demand');
      }
    } catch (e) {
      throw Exception('Failed to accept demand: ${e.toString()}');
    }
  }

  Future<void> ignoreDemand(String token, String demandId) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConstants.baseUrl}/ngo-demands/$demandId/ignore'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(_timeoutDuration);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200 || data['success'] != true) {
        throw Exception(data['message'] as String? ?? 'Failed to ignore demand');
      }
    } catch (e) {
      throw Exception('Failed to ignore demand: ${e.toString()}');
    }
  }

  Future<NGODemand> updateDemand({
    required String token,
    required String demandId,
    int? amount,
    String? unit,
    DateTime? requiredBy,
    String? description,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (amount != null) body['amount'] = amount;
      if (unit != null) body['unit'] = unit;
      if (requiredBy != null) body['requiredBy'] = requiredBy.toIso8601String();
      if (description != null) body['description'] = description;

      final response = await _client
          .put(
            Uri.parse('${ApiConstants.baseUrl}/ngo-demands/$demandId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(_timeoutDuration);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return NGODemand.fromJson(data['data']['demand'] as Map<String, dynamic>);
      } else {
        throw Exception(data['message'] as String? ?? 'Failed to update demand');
      }
    } catch (e) {
      throw Exception('Failed to update demand: ${e.toString()}');
    }
  }

  Future<void> deleteDemand(String token, String demandId) async {
    try {
      final response = await _client
          .delete(
            Uri.parse('${ApiConstants.baseUrl}/ngo-demands/$demandId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(_timeoutDuration);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200 || data['success'] != true) {
        throw Exception(data['message'] as String? ?? 'Failed to delete demand');
      }
    } catch (e) {
      throw Exception('Failed to delete demand: ${e.toString()}');
    }
  }

  Future<List<NGODemand>> getAcceptedDemandsForVolunteers(String token) async {
    try {
      final response = await _client
          .get(
            Uri.parse('${ApiConstants.baseUrl}/ngo-demands/accepted-for-volunteers'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(_timeoutDuration);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        final demandsList = data['data']['demands'] as List<dynamic>;
        return demandsList
            .map((demandJson) => NGODemand.fromJson(demandJson as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(data['message'] as String? ?? 'Failed to fetch accepted demands');
      }
    } catch (e) {
      throw Exception('Failed to fetch accepted demands: ${e.toString()}');
    }
  }
}

