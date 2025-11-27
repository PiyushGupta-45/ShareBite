import 'dart:math';

import 'package:food_donation_app/domain/entities/analytics_insight.dart';
import 'package:food_donation_app/domain/entities/community_content.dart';
import 'package:food_donation_app/domain/entities/freshness_check.dart';
import 'package:food_donation_app/domain/entities/gamification_stats.dart';
import 'package:food_donation_app/domain/entities/logistics_alert.dart';
import 'package:food_donation_app/domain/entities/volunteer_request.dart';

class MockFoodDonationDataSource {
  Future<List<LogisticsAlert>> fetchLogisticsAlerts() async {
    final now = DateTime.now();
    final alerts = [
      LogisticsAlert(
        donorName: 'Bloom Bistro',
        location: 'CBD Cluster',
        radiusKm: 5,
        urgencyTag: 'Perishable (2h)',
        expiry: now.add(const Duration(hours: 2)),
        requiresRefrigeration: true,
      ),
      LogisticsAlert(
        donorName: 'Harvest Farm Co-op',
        location: 'North Agro Belt',
        radiusKm: 12,
        urgencyTag: 'Shelf-stable',
        expiry: now.add(const Duration(hours: 8)),
        requiresRefrigeration: false,
      ),
      LogisticsAlert(
        donorName: 'Fusion Food Labs',
        location: 'Tech Park',
        radiusKm: 3,
        urgencyTag: 'Flash Freeze',
        expiry: now.add(const Duration(hours: 1)),
        requiresRefrigeration: true,
      ),
    ];
    return Future.delayed(const Duration(milliseconds: 250), () => alerts);
  }

  Future<List<FreshnessCheck>> fetchFreshnessChecklist() async {
    const checklist = [
      FreshnessCheck(label: 'Capture donor images', isMandatory: true),
      FreshnessCheck(label: 'Temperature log (<=5°C)', isMandatory: true),
      FreshnessCheck(label: 'Smell & texture inspection', isMandatory: true),
      FreshnessCheck(label: 'Allergen labels attached', isMandatory: false),
      FreshnessCheck(label: 'Waiver acknowledgement', isMandatory: true),
    ];
    return Future.delayed(const Duration(milliseconds: 200), () => checklist);
  }

  Future<GamificationStats> fetchGamificationStats() async {
    final stats = GamificationStats(
      co2SavedKg: 428.6,
      mealsServed: 1563,
      activeStreakDays: 24,
      badges: ['Cold Chain Guardian', 'Community Ally', 'Zero-Waste Sage'],
      leaderboard: const [
        LeaderboardEntry(user: 'Nourish Ninjas', mealsServed: 1800, rank: 1),
        LeaderboardEntry(user: 'Share Bites Riders', mealsServed: 1650, rank: 2),
        LeaderboardEntry(user: 'You', mealsServed: 1563, rank: 3),
      ],
    );
    return Future.delayed(const Duration(milliseconds: 180), () => stats);
  }

  Future<List<VolunteerRequest>> fetchVolunteerRequests() async {
    final requests = [
      VolunteerRequest(
        id: 'SOS-342',
        pickupPoint: 'Greenfield Deli',
        dropOffPoint: 'Lotus Shelter',
        payloadType: 'Mixed meals (18 trays)',
        distanceKm: 4.2,
        readyBy: DateTime.now().add(const Duration(minutes: 40)),
        highPriority: true,
      ),
      VolunteerRequest(
        id: 'ADHOC-219',
        pickupPoint: 'Urban Farms Hub',
        dropOffPoint: 'Hunger Squad - Ward 7',
        payloadType: 'Fresh produce crates',
        distanceKm: 7.4,
        readyBy: DateTime.now().add(const Duration(hours: 2)),
        highPriority: false,
      ),
    ];
    return Future.delayed(const Duration(milliseconds: 220), () => requests);
  }

  Future<List<AnalyticsInsight>> fetchAnalyticsInsights() async {
    final insights = [
      AnalyticsInsight(
        metric: 'Waste Diverted',
        value: 612,
        unit: 'kg',
        trendPercent: 12,
        description: 'Upcycling surplus brunch buffets (Week-on-week).',
      ),
      AnalyticsInsight(
        metric: 'Peak Waste Window',
        value: 21,
        unit: 'hrs',
        trendPercent: -5,
        description: 'Late-night prep sees lower discard rates.',
      ),
      AnalyticsInsight(
        metric: 'CO₂ Offset',
        value: 1.9,
        unit: 't',
        trendPercent: 8,
        description: 'Linked to optimized route batching.',
      ),
    ];
    return Future.delayed(const Duration(milliseconds: 150), () => insights);
  }

  Future<List<ForumPost>> fetchForumPosts() async {
    final posts = [
      ForumPost(
        author: 'Priya · Waste Lab',
        topic: 'Zero-waste recipes',
        message: 'Fermented citrus peels work great for electrolyte drinks!',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        upvotes: 42,
      ),
      ForumPost(
        author: 'Chef Marco',
        topic: 'Buffet forecasting',
        message: 'Sharing my sheet that predicts covers vs surplus.',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        upvotes: 31,
      ),
    ];
    return Future.delayed(const Duration(milliseconds: 260), () => posts);
  }

  Future<List<HungerSquadAlert>> fetchHungerSquadAlerts() async {
    final alerts = [
      HungerSquadAlert(
        groupName: 'Hunger Squad - Riverside',
        location: 'Ward 5',
        need: '200 meals for flood relief',
        peopleImpacted: 200,
        isEmergency: true,
      ),
      HungerSquadAlert(
        groupName: 'Hunger Squad - Midtown',
        location: 'Ward 2',
        need: 'Dry ration kits for seniors',
        peopleImpacted: 60,
        isEmergency: false,
      ),
    ];
    return Future.delayed(const Duration(milliseconds: 210), () => alerts);
  }

  Future<List<ResourceBarter>> fetchBarterListings() async {
    final listings = [
      ResourceBarter(
        requester: 'Community Kitchen X',
        offer: 'Heat-safe containers',
        request: 'Need insulated cambros',
        status: 'Negotiating',
      ),
      ResourceBarter(
        requester: 'SOS Collective',
        offer: 'Volunteer hours',
        request: 'Cold-chain van for 4h',
        status: 'Open',
      ),
    ];
    return Future.delayed(const Duration(milliseconds: 230), () => listings);
  }

  Future<List<FoodDriveEvent>> fetchFoodDriveEvents() async {
    final random = Random();
    final events = [
      FoodDriveEvent(
        title: 'Full Moon Food Drive',
        date: DateTime.now().add(const Duration(days: 2)),
        location: 'Seaside Promenade',
        description: 'Hyper-local pop-up with live impact feed.',
        registeredVolunteers: 38 + random.nextInt(10),
      ),
      FoodDriveEvent(
        title: 'Hunger Squad SOS Rally',
        date: DateTime.now().add(const Duration(days: 5)),
        location: 'Civic Center',
        description: 'Rapid response packaging sprint.',
        registeredVolunteers: 52 + random.nextInt(6),
      ),
    ];
    return Future.delayed(const Duration(milliseconds: 300), () => events);
  }
}

