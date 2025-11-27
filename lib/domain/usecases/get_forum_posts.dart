import 'package:food_donation_app/domain/entities/community_content.dart';
import 'package:food_donation_app/domain/repositories/food_donation_repository.dart';

class GetForumPosts {
  const GetForumPosts(this.repository);

  final FoodDonationRepository repository;

  Future<List<ForumPost>> call() => repository.fetchForumPosts();
}

