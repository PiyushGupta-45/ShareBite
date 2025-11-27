import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_donation_app/data/datasources/auth_remote_datasource.dart';
import 'package:food_donation_app/data/datasources/mock_food_donation_data_source.dart';
import 'package:food_donation_app/data/datasources/mock_ngo_data_source.dart';
import 'package:food_donation_app/data/datasources/ngo_remote_datasource.dart';
import 'package:food_donation_app/data/repositories/auth_repository_impl.dart';
import 'package:food_donation_app/data/repositories/food_donation_repository_impl.dart';
import 'package:food_donation_app/domain/entities/freshness_check.dart';
import 'package:food_donation_app/domain/entities/user.dart';
import 'package:food_donation_app/domain/repositories/food_donation_repository.dart';
import 'package:food_donation_app/domain/usecases/get_analytics_insights.dart';
import 'package:food_donation_app/domain/usecases/get_food_drive_events.dart';
import 'package:food_donation_app/domain/usecases/get_forum_posts.dart';
import 'package:food_donation_app/domain/usecases/get_freshness_checklist.dart';
import 'package:food_donation_app/domain/usecases/get_gamification_stats.dart';
import 'package:food_donation_app/domain/usecases/get_hunger_squad_alerts.dart';
import 'package:food_donation_app/domain/usecases/get_logistics_alerts.dart';
import 'package:food_donation_app/domain/usecases/get_resource_barters.dart';
import 'package:food_donation_app/domain/usecases/get_volunteer_requests.dart';

final mockDataSourceProvider = Provider((ref) => MockFoodDonationDataSource());

final foodDonationRepositoryProvider =
    Provider<FoodDonationRepository>((ref) {
  return FoodDonationRepositoryImpl(ref.watch(mockDataSourceProvider));
});

final getLogisticsAlertsProvider = Provider(
  (ref) => GetLogisticsAlerts(ref.watch(foodDonationRepositoryProvider)),
);
final getFreshnessChecklistProvider = Provider(
  (ref) => GetFreshnessChecklist(ref.watch(foodDonationRepositoryProvider)),
);
final getGamificationStatsProvider = Provider(
  (ref) => GetGamificationStats(ref.watch(foodDonationRepositoryProvider)),
);
final getVolunteerRequestsProvider = Provider(
  (ref) => GetVolunteerRequests(ref.watch(foodDonationRepositoryProvider)),
);
final getAnalyticsInsightsProvider = Provider(
  (ref) => GetAnalyticsInsights(ref.watch(foodDonationRepositoryProvider)),
);
final getForumPostsProvider = Provider(
  (ref) => GetForumPosts(ref.watch(foodDonationRepositoryProvider)),
);
final getHungerSquadAlertsProvider = Provider(
  (ref) => GetHungerSquadAlerts(ref.watch(foodDonationRepositoryProvider)),
);
final getResourceBartersProvider = Provider(
  (ref) => GetResourceBarters(ref.watch(foodDonationRepositoryProvider)),
);
final getFoodDriveEventsProvider = Provider(
  (ref) => GetFoodDriveEvents(ref.watch(foodDonationRepositoryProvider)),
);

final logisticsAlertsProvider = FutureProvider(
  (ref) => ref.watch(getLogisticsAlertsProvider).call(),
);
final freshnessChecklistProvider = FutureProvider(
  (ref) => ref.watch(getFreshnessChecklistProvider).call(),
);
final gamificationStatsProvider = FutureProvider(
  (ref) => ref.watch(getGamificationStatsProvider).call(),
);
final volunteerRequestsProvider = FutureProvider(
  (ref) => ref.watch(getVolunteerRequestsProvider).call(),
);
final analyticsInsightsProvider = FutureProvider(
  (ref) => ref.watch(getAnalyticsInsightsProvider).call(),
);
final forumPostsProvider = FutureProvider(
  (ref) => ref.watch(getForumPostsProvider).call(),
);
final hungerSquadAlertsProvider = FutureProvider(
  (ref) => ref.watch(getHungerSquadAlertsProvider).call(),
);
final resourceBartersProvider = FutureProvider(
  (ref) => ref.watch(getResourceBartersProvider).call(),
);
final foodDriveEventsProvider = FutureProvider(
  (ref) => ref.watch(getFoodDriveEventsProvider).call(),
);

// NGO Providers
final mockNgoDataSourceProvider = Provider((ref) => MockNgoDataSource());

final ngoListProvider = FutureProvider((ref) async {
  try {
    final ngoDataSource = NgoRemoteDataSource();
    return await ngoDataSource.getAllNGOs();
  } catch (e) {
    // Fallback to mock data if backend fails
    print('Error fetching NGOs from backend: $e');
    final dataSource = ref.watch(mockNgoDataSourceProvider);
    return await dataSource.fetchNGOs();
  }
});

final navIndexProvider = StateProvider<int>((ref) => 0);

class ChecklistNotifier extends StateNotifier<Map<String, bool>> {
  ChecklistNotifier() : super(const {});

  void toggle(FreshnessCheck item, bool value) {
    state = {...state, item.label: value};
  }

  bool isChecked(FreshnessCheck item) => state[item.label] ?? item.completed;
}

final checklistStateProvider =
    StateNotifierProvider<ChecklistNotifier, Map<String, bool>>(
  (ref) => ChecklistNotifier(),
);

class HandshakeState {
  const HandshakeState({
    this.waiverSigned = false,
    this.generatedOtp,
    this.otpVerified = false,
  });

  final bool waiverSigned;
  final String? generatedOtp;
  final bool otpVerified;

  HandshakeState copyWith({
    bool? waiverSigned,
    String? generatedOtp,
    bool resetOtp = false,
    bool? otpVerified,
  }) {
    return HandshakeState(
      waiverSigned: waiverSigned ?? this.waiverSigned,
      generatedOtp: resetOtp ? null : generatedOtp ?? this.generatedOtp,
      otpVerified: otpVerified ?? this.otpVerified,
    );
  }
}

class HandshakeNotifier extends StateNotifier<HandshakeState> {
  HandshakeNotifier() : super(const HandshakeState());

  void signWaiver() {
    state = state.copyWith(waiverSigned: true, otpVerified: false);
  }

  void generateOtp() {
    final code = (Random().nextInt(9000) + 1000).toString();
    state = state.copyWith(generatedOtp: code, otpVerified: false);
  }

  void verifyOtp(String input) {
    final isValid = state.generatedOtp != null && state.generatedOtp == input;
    state = state.copyWith(otpVerified: isValid);
  }

  void reset() {
    state = const HandshakeState();
  }
}

final handshakeProvider =
    StateNotifierProvider<HandshakeNotifier, HandshakeState>(
  (ref) => HandshakeNotifier(),
);

final pickedImagePathProvider = StateProvider<String?>((ref) => null);

class AcceptedRequestsNotifier extends StateNotifier<Set<String>> {
  AcceptedRequestsNotifier() : super({});

  void toggle(String id) {
    if (state.contains(id)) {
      state = {...state}..remove(id);
    } else {
      state = {...state, id};
    }
  }
}

final acceptedRequestsProvider =
    StateNotifierProvider<AcceptedRequestsNotifier, Set<String>>(
  (ref) => AcceptedRequestsNotifier(),
);

// Auth providers
final authRemoteDataSourceProvider = Provider((ref) => AuthRemoteDataSource());

final authRepositoryProvider = Provider((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

class AuthState {
  const AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  final User? user;
  final String? token;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  AuthState copyWith({
    User? user,
    String? token,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authRepository) : super(const AuthState()) {
    _loadStoredAuth();
  }

  final AuthRepositoryImpl _authRepository;

  Future<void> _loadStoredAuth() async {
    state = state.copyWith(isLoading: true);
    try {
      final token = await _authRepository.getStoredToken();
      if (token != null) {
        final user = await _authRepository.getStoredUser();
        if (user != null) {
          state = state.copyWith(
            user: user,
            token: token,
            isAuthenticated: true,
            isLoading: false,
          );
          return;
        }
      }
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load stored auth',
      );
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _authRepository.signIn(
        email: email,
        password: password,
      );
      state = state.copyWith(
        user: result['user'] as User,
        token: result['token'] as String,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _authRepository.signUp(
        name: name,
        email: email,
        password: password,
      );
      state = state.copyWith(
        user: result['user'] as User,
        token: result['token'] as String,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> signInWithGoogle({required String tokenId}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _authRepository.signInWithGoogle(tokenId: tokenId);
      state = state.copyWith(
        user: result['user'] as User,
        token: result['token'] as String,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

