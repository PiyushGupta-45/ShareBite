import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_donation_app/core/theme/app_theme.dart';
import 'package:food_donation_app/presentation/providers/app_providers.dart';
import 'package:food_donation_app/presentation/screens/community_hub_screen.dart';
import 'package:food_donation_app/presentation/screens/impact_screen.dart';
import 'package:food_donation_app/presentation/screens/login_screen.dart';
import 'package:food_donation_app/presentation/screens/ngo_home_screen.dart';
import 'package:food_donation_app/presentation/screens/profile_screen.dart';
import 'package:food_donation_app/presentation/screens/runs_screen.dart';

void main() {
  runApp(const ProviderScope(child: FoodDonationApp()));
}

class FoodDonationApp extends ConsumerWidget {
  const FoodDonationApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Share Bites',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: authState.isAuthenticated ? const HomeShell() : const LoginScreen(),
    );
  }
}

enum AppTab {
  home,
  runs,
  impact,
  community,
}

extension AppTabX on AppTab {
  String get label {
    switch (this) {
      case AppTab.home:
        return 'Share Bites';
      case AppTab.runs:
        return 'Runs';
      case AppTab.impact:
        return 'Impact';
      case AppTab.community:
        return 'Community';
    }
  }

  IconData get icon {
    switch (this) {
      case AppTab.home:
        return Icons.home;
      case AppTab.runs:
        return Icons.local_shipping;
      case AppTab.impact:
        return Icons.emoji_events;
      case AppTab.community:
        return Icons.people;
    }
  }
}

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(navIndexProvider);
    final tab = AppTab.values[index];

    final screen = switch (tab) {
      AppTab.home => const NgoHomeScreen(),
      AppTab.runs => const RunsScreen(),
      AppTab.impact => const ImpactScreen(),
      AppTab.community => const CommunityHubScreen(),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tab.label,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        toolbarHeight: 80,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 32),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
            tooltip: 'Profile',
          ),
        ],
      ),
      body: screen,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => ref.read(navIndexProvider.notifier).state = value,
        destinations: AppTab.values.map((tab) {
          return NavigationDestination(
            icon: Icon(tab.icon),
            label: tab.label,
          );
        }).toList(),
      ),
    );
  }
}
