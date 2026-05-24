import 'dart:convert';

import 'package:food_donation_app/core/constants/api_constants.dart';
import 'package:food_donation_app/domain/entities/redeemed_voucher.dart';
import 'package:food_donation_app/domain/entities/voucher.dart';
import 'package:http/http.dart' as http;

class VoucherRemoteDataSource {
  final http.Client _client = http.Client();
  static const Duration _timeoutDuration = Duration(seconds: 30);

  Future<List<Voucher>> getActiveVouchers(String token) async {
    final response = await _client
        .get(
          Uri.parse('${ApiConstants.baseUrl}/vouchers'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(_timeoutDuration);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 && data['success'] == true) {
      final vouchers = data['data']['vouchers'] as List<dynamic>;
      return vouchers
          .map((item) => Voucher.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception(data['message'] as String? ?? 'Failed to fetch vouchers');
  }

  Future<List<RedeemedVoucher>> getRedeemedVouchers(String token) async {
    final response = await _client
        .get(
          Uri.parse('${ApiConstants.baseUrl}/vouchers/my-redemptions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(_timeoutDuration);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 && data['success'] == true) {
      final vouchers = data['data']['redeemedVouchers'] as List<dynamic>;
      return vouchers
          .map((item) => RedeemedVoucher.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception(data['message'] as String? ?? 'Failed to fetch redeemed vouchers');
  }

  Future<void> redeemVoucher({
    required String token,
    required String voucherId,
  }) async {
    final response = await _client
        .post(
          Uri.parse('${ApiConstants.baseUrl}/vouchers/$voucherId/redeem'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(_timeoutDuration);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] as String? ?? 'Failed to redeem voucher');
    }
  }

  Future<void> createVoucher({
    required String token,
    required String title,
    required String code,
    required int pointsRequired,
    String? description,
    String? discountValue,
  }) async {
    final response = await _client
        .post(
          Uri.parse('${ApiConstants.baseUrl}/vouchers'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'title': title,
            'code': code,
            'pointsRequired': pointsRequired,
            if (description != null && description.isNotEmpty) 'description': description,
            if (discountValue != null && discountValue.isNotEmpty) 'discountValue': discountValue,
          }),
        )
        .timeout(_timeoutDuration);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 201 || data['success'] != true) {
      throw Exception(data['message'] as String? ?? 'Failed to create voucher');
    }
  }
}
