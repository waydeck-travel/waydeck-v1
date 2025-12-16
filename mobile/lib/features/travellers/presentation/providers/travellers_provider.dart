import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/models.dart';
import '../../data/travellers_repository.dart';

/// Provider for all travellers
final travellersProvider = FutureProvider.autoDispose<List<Traveller>>(
  (ref) async {
    final repo = ref.watch(travellersRepositoryProvider);
    return repo.getTravellers();
  },
);

/// Provider for single traveller
final travellerProvider = FutureProvider.autoDispose.family<Traveller?, String>(
  (ref, travellerId) async {
    final repo = ref.watch(travellersRepositoryProvider);
    return repo.getTraveller(travellerId);
  },
);

/// Provider for trip travellers
final tripTravellersProvider = FutureProvider.autoDispose.family<List<TripTraveller>, String>(
  (ref, tripId) async {
    final repo = ref.watch(travellersRepositoryProvider);
    return repo.getTripTravellers(tripId);
  },
);

/// Traveller form state
class TravellerFormState {
  final bool isLoading;
  final String? error;
  final Traveller? savedTraveller;

  const TravellerFormState({
    this.isLoading = false,
    this.error,
    this.savedTraveller,
  });

  TravellerFormState copyWith({
    bool? isLoading,
    String? error,
    Traveller? savedTraveller,
  }) {
    return TravellerFormState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      savedTraveller: savedTraveller,
    );
  }
}

/// Traveller form notifier
class TravellerFormNotifier extends StateNotifier<TravellerFormState> {
  final TravellersRepository _repo;
  final Ref _ref;

  TravellerFormNotifier(this._repo, this._ref) : super(const TravellerFormState());

  Future<bool> createTraveller({
    required String fullName,
    String? email,
    String? phone,
    String? passportNumber,
    DateTime? passportExpiry,
    String? nationality,
    DateTime? dateOfBirth,
    String? notes,
    String? avatarUrl,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final traveller = await _repo.createTraveller(
        fullName: fullName,
        email: email,
        phone: phone,
        passportNumber: passportNumber,
        passportExpiry: passportExpiry,
        nationality: nationality,
        dateOfBirth: dateOfBirth,
        notes: notes,
        avatarUrl: avatarUrl,
      );

      if (traveller != null) {
        state = state.copyWith(isLoading: false, savedTraveller: traveller);
        _ref.invalidate(travellersProvider);
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to create traveller');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateTraveller({
    required String travellerId,
    String? fullName,
    String? email,
    String? phone,
    String? passportNumber,
    DateTime? passportExpiry,
    String? nationality,
    DateTime? dateOfBirth,
    String? notes,
    String? avatarUrl,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final traveller = await _repo.updateTraveller(
        travellerId: travellerId,
        fullName: fullName,
        email: email,
        phone: phone,
        passportNumber: passportNumber,
        passportExpiry: passportExpiry,
        nationality: nationality,
        dateOfBirth: dateOfBirth,
        notes: notes,
        avatarUrl: avatarUrl,
      );

      if (traveller != null) {
        state = state.copyWith(isLoading: false, savedTraveller: traveller);
        _ref.invalidate(travellersProvider);
        _ref.invalidate(travellerProvider(travellerId));
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to update traveller');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteTraveller(String travellerId) async {
    try {
      final success = await _repo.deleteTraveller(travellerId);
      if (success) {
        _ref.invalidate(travellersProvider);
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addToTrip(String tripId, String travellerId, {bool isPrimary = false}) async {
    try {
      final success = await _repo.addTravellerToTrip(
        tripId: tripId,
        travellerId: travellerId,
        isPrimary: isPrimary,
      );
      if (success) {
        _ref.invalidate(tripTravellersProvider(tripId));
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeFromTrip(String tripId, String travellerId) async {
    try {
      final success = await _repo.removeTravellerFromTrip(
        tripId: tripId,
        travellerId: travellerId,
      );
      if (success) {
        _ref.invalidate(tripTravellersProvider(tripId));
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  void reset() {
    state = const TravellerFormState();
  }
}

final travellerFormProvider = StateNotifierProvider.autoDispose<TravellerFormNotifier, TravellerFormState>(
  (ref) => TravellerFormNotifier(
    ref.watch(travellersRepositoryProvider),
    ref,
  ),
);
