import 'package:food_donation_app/domain/entities/analytics_insight.dart';
import 'package:food_donation_app/domain/entities/community_content.dart';
import 'package:food_donation_app/domain/entities/freshness_check.dart';
import 'package:food_donation_app/domain/entities/gamification_stats.dart';
import 'package:food_donation_app/domain/entities/logistics_alert.dart';
import 'package:food_donation_app/domain/entities/volunteer_request.dart';

abstract class FoodDonationRepository {
  Future<List<LogisticsAlert>> fetchLogisticsAlerts();
  Future<List<FreshnessCheck>> fetchFreshnessChecklist();
  Future<GamificationStats> fetchGamificationStats();
  Future<List<VolunteerRequest>> fetchVolunteerRequests();
  Future<List<AnalyticsInsight>> fetchAnalyticsInsights();
  Future<List<ForumPost>> fetchForumPosts();
  Future<List<HungerSquadAlert>> fetchHungerSquadAlerts();
  Future<List<ResourceBarter>> fetchBarterListings();
  Future<List<FoodDriveEvent>> fetchFoodDriveEvents();
}

