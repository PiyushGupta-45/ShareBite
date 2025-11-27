import 'package:food_donation_app/domain/entities/gamification_stats.dart';
import 'package:food_donation_app/domain/repositories/food_donation_repository.dart';

class GetGamificationStats {
  const GetGamificationStats(this.repository);

  final FoodDonationRepository repository;

  Future<GamificationStats> call() => repository.fetchGamificationStats();
}

