import 'package:food_donation_app/data/datasources/mock_food_donation_data_source.dart';
import 'package:food_donation_app/domain/entities/analytics_insight.dart';
import 'package:food_donation_app/domain/entities/community_content.dart';
import 'package:food_donation_app/domain/entities/freshness_check.dart';
import 'package:food_donation_app/domain/entities/gamification_stats.dart';
import 'package:food_donation_app/domain/entities/logistics_alert.dart';
import 'package:food_donation_app/domain/entities/volunteer_request.dart';
import 'package:food_donation_app/domain/repositories/food_donation_repository.dart';

class FoodDonationRepositoryImpl implements FoodDonationRepository {
  FoodDonationRepositoryImpl(this.dataSource);

  final MockFoodDonationDataSource dataSource;

  @override
  Future<List<LogisticsAlert>> fetchLogisticsAlerts() =>
      dataSource.fetchLogisticsAlerts();

  @override
  Future<List<FreshnessCheck>> fetchFreshnessChecklist() =>
      dataSource.fetchFreshnessChecklist();

  @override
  Future<GamificationStats> fetchGamificationStats() =>
      dataSource.fetchGamificationStats();

  @override
  Future<List<VolunteerRequest>> fetchVolunteerRequests() =>
      dataSource.fetchVolunteerRequests();

  @override
  Future<List<AnalyticsInsight>> fetchAnalyticsInsights() =>
      dataSource.fetchAnalyticsInsights();

  @override
  Future<List<ForumPost>> fetchForumPosts() => dataSource.fetchForumPosts();

  @override
  Future<List<HungerSquadAlert>> fetchHungerSquadAlerts() =>
      dataSource.fetchHungerSquadAlerts();

  @override
  Future<List<ResourceBarter>> fetchBarterListings() =>
      dataSource.fetchBarterListings();

  @override
  Future<List<FoodDriveEvent>> fetchFoodDriveEvents() =>
      dataSource.fetchFoodDriveEvents();
}

