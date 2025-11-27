import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:food_donation_app/core/constants/api_constants.dart';
import 'package:food_donation_app/domain/entities/delivery_run.dart';

class DeliveryRunRemoteDataSource {
  final http.Client _client = http.Client();
  static const Duration _timeoutDuration = Duration(seconds: 30);

  Future<List<DeliveryRun>> getUserDeliveryRuns({String? status}) async {
    try {
      final url = status != null
          ? '${ApiConstants.baseUrl}/delivery-runs?status=$status'
          : '${ApiConstants.baseUrl}/delivery-runs';
      
      final response = await _client
          .get(Uri.parse(url))
          .timeout(_timeoutDuration);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        final runsList = data['data']['deliveryRuns'] as List<dynamic>;
        return runsList
            .map((runJson) => _deliveryRunFromJson(runJson as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(data['message'] as String? ?? 'Failed to fetch delivery runs');
      }
    } catch (e) {
      throw Exception('Failed to fetch delivery runs: ${e.toString()}');
    }
  }

  Future<DeliveryRun> acceptDeliveryRun({
    required String token,
    required String restaurantId,
    required String ngoId,
    required DateTime pickupTime,
    required DateTime deliveryTime,
    required int numberOfMeals,
    String? description,
    String? urgencyTag,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConstants.baseUrl}/delivery-runs/accept'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'restaurantId': restaurantId,
              'ngoId': ngoId,
              'pickupTime': pickupTime.toIso8601String(),
              'deliveryTime': deliveryTime.toIso8601String(),
              'numberOfMeals': numberOfMeals,
              if (description != null && description.isNotEmpty) 'description': description,
              if (urgencyTag != null && urgencyTag.isNotEmpty) 'urgencyTag': urgencyTag,
            }),
          )
          .timeout(_timeoutDuration);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 && data['success'] == true) {
        return _deliveryRunFromJson(data['data']['deliveryRun'] as Map<String, dynamic>);
      } else {
        throw Exception(data['message'] as String? ?? 'Failed to accept delivery run');
      }
    } catch (e) {
      throw Exception('Failed to accept delivery run: ${e.toString()}');
    }
  }

  Future<DeliveryRun> updateDeliveryRunStatus({
    required String token,
    required String runId,
    required String status,
  }) async {
    try {
      final response = await _client
          .put(
            Uri.parse('${ApiConstants.baseUrl}/delivery-runs/$runId/status'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'status': status,
            }),
          )
          .timeout(_timeoutDuration);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return _deliveryRunFromJson(data['data']['deliveryRun'] as Map<String, dynamic>);
      } else {
        throw Exception(data['message'] as String? ?? 'Failed to update delivery run status');
      }
    } catch (e) {
      throw Exception('Failed to update delivery run status: ${e.toString()}');
    }
  }

  DeliveryRun _deliveryRunFromJson(Map<String, dynamic> json) {
    final restaurant = json['restaurant'] as Map<String, dynamic>;
    final ngo = json['ngo'] as Map<String, dynamic>;

    return DeliveryRun(
      id: json['id'] as String,
      restaurantId: restaurant['id'] as String,
      restaurantName: restaurant['name'] as String,
      restaurantLocation: restaurant['location'] as String,
      restaurantAddress: restaurant['address'] as String,
      restaurantLatitude: (restaurant['latitude'] as num).toDouble(),
      restaurantLongitude: (restaurant['longitude'] as num).toDouble(),
      restaurantPhone: restaurant['phone'] as String,
      ngoId: ngo['id'] as String,
      ngoName: ngo['name'] as String,
      ngoLocation: ngo['location'] as String,
      ngoAddress: ngo['address'] as String,
      ngoLatitude: (ngo['latitude'] as num).toDouble(),
      ngoLongitude: (ngo['longitude'] as num).toDouble(),
      ngoPhone: ngo['phone'] as String,
      pickupTime: DateTime.parse(json['pickupTime'] as String),
      deliveryTime: DateTime.parse(json['deliveryTime'] as String),
      numberOfMeals: json['numberOfMeals'] as int,
      status: json['status'] as String,
      description: json['description'] as String?,
      urgencyTag: json['urgencyTag'] as String?,
    );
  }
}

