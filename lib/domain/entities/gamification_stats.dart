class GamificationStats {
  const GamificationStats({
    required this.co2SavedKg,
    required this.mealsServed,
    required this.activeStreakDays,
    required this.badges,
    required this.leaderboard,
  });

  final double co2SavedKg;
  final int mealsServed;
  final int activeStreakDays;
  final List<String> badges;
  final List<LeaderboardEntry> leaderboard;
}

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.user,
    required this.mealsServed,
    required this.rank,
  });

  final String user;
  final int mealsServed;
  final int rank;
}

