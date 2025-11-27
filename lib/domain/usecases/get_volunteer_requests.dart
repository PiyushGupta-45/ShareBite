import 'package:food_donation_app/domain/entities/volunteer_request.dart';
import 'package:food_donation_app/domain/repositories/food_donation_repository.dart';

class GetVolunteerRequests {
  const GetVolunteerRequests(this.repository);

  final FoodDonationRepository repository;

  Future<List<VolunteerRequest>> call() =>
      repository.fetchVolunteerRequests();
}

