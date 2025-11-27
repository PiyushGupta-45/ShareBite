import 'package:food_donation_app/domain/entities/analytics_insight.dart';
import 'package:food_donation_app/domain/repositories/food_donation_repository.dart';

class GetAnalyticsInsights {
  const GetAnalyticsInsights(this.repository);

  final FoodDonationRepository repository;

  Future<List<AnalyticsInsight>> call() =>
      repository.fetchAnalyticsInsights();
}

