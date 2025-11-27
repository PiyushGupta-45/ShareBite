import 'package:food_donation_app/domain/entities/freshness_check.dart';
import 'package:food_donation_app/domain/repositories/food_donation_repository.dart';

class GetFreshnessChecklist {
  const GetFreshnessChecklist(this.repository);

  final FoodDonationRepository repository;

  Future<List<FreshnessCheck>> call() =>
      repository.fetchFreshnessChecklist();
}

