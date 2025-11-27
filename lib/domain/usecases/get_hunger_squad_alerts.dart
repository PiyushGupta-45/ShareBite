import 'package:food_donation_app/domain/entities/community_content.dart';
import 'package:food_donation_app/domain/repositories/food_donation_repository.dart';

class GetHungerSquadAlerts {
  const GetHungerSquadAlerts(this.repository);

  final FoodDonationRepository repository;

  Future<List<HungerSquadAlert>> call() =>
      repository.fetchHungerSquadAlerts();
}

