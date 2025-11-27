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
import 'package:food_donation_app/presentation/screens/ngo_needs_screen.dart';
import 'package:food_donation_app/presentation/screens/create_demand_screen.dart';

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
  String getLabel(String? userRole) {
    switch (this) {
      case AppTab.home:
        return 'Share Bites';
      case AppTab.runs:
        if (userRole == 'restaurant') {
          return 'NGO Needs';
        } else if (userRole == 'ngo_admin') {
          return 'Create Demand';
        }
        return 'Volunteer';
      case AppTab.impact:
        return 'Activity';
      case AppTab.community:
        return 'Community';
    }
  }

  IconData get icon {
    switch (this) {
      case AppTab.home:
        return Icons.home;
      case AppTab.runs:
        return Icons.restaurant;
      case AppTab.impact:
        return Icons.history;
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
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final userRole = user?.role;

    // Determine which screen to show based on tab and user role
    final screen = switch (tab) {
      AppTab.home => const NgoHomeScreen(),
      AppTab.runs => userRole == 'restaurant'
          ? const NgoNeedsScreen()
          : userRole == 'ngo_admin'
              ? const CreateDemandScreen()
              : const RunsScreen(),
      AppTab.impact => const ImpactScreen(),
      AppTab.community => const CommunityHubScreen(),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tab.getLabel(userRole),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        toolbarHeight: 80,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                backgroundImage: user?.picture != null && user!.picture!.isNotEmpty ? NetworkImage(user.picture!) : null,
                child: user?.picture == null || (user?.picture?.isEmpty ?? true)
                    ? Icon(
                        Icons.account_circle,
                        size: 48,
                        color: AppTheme.primaryColor,
                      )
                    : null,
              ),
            ),
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
            label: tab.getLabel(userRole),
          );
        }).toList(),
      ),
    );
  }
}
