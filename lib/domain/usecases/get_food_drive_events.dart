import 'package:food_donation_app/domain/entities/community_content.dart';
import 'package:food_donation_app/domain/repositories/food_donation_repository.dart';

class GetFoodDriveEvents {
  const GetFoodDriveEvents(this.repository);

  final FoodDonationRepository repository;

  Future<List<FoodDriveEvent>> call() =>
      repository.fetchFoodDriveEvents();
}

