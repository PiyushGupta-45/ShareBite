import 'package:food_donation_app/domain/entities/logistics_alert.dart';
import 'package:food_donation_app/domain/repositories/food_donation_repository.dart';

class GetLogisticsAlerts {
  const GetLogisticsAlerts(this.repository);

  final FoodDonationRepository repository;

  Future<List<LogisticsAlert>> call() => repository.fetchLogisticsAlerts();
}

