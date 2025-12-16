import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/models.dart';
import '../../data/trips_repository.dart';

/// Trips repository provider
final tripsRepositoryProvider = Provider<TripsRepository>((ref) {
  return TripsRepository();
});

/// Trips list provider
final tripsListProvider = FutureProvider<List<Trip>>((ref) async {
  final repo = ref.watch(tripsRepositoryProvider);
  return repo.getTrips();
});

/// Single trip provider
final tripProvider = FutureProvider.family<Trip?, String>((ref, tripId) async {
  final repo = ref.watch(tripsRepositoryProvider);
  return repo.getTrip(tripId);
});

/// Trip form state
class TripFormState {
  final bool isLoading;
  final String? error;
  final Trip? savedTrip;

  const TripFormState({
    this.isLoading = false,
    this.error,
    this.savedTrip,
  });

  TripFormState copyWith({
    bool? isLoading,
    String? error,
    Trip? savedTrip,
  }) {
    return TripFormState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      savedTrip: savedTrip,
    );
  }
}

/// Trip form notifier for create/edit
class TripFormNotifier extends StateNotifier<TripFormState> {
  final TripsRepository _repo;
  final Ref _ref;

  TripFormNotifier(this._repo, this._ref) : super(const TripFormState());

  Future<bool> createTrip({
    required String name,
    String? originCity,
    String? originCountryCode,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final trip = await _repo.createTrip(
        name: name,
        originCity: originCity,
        originCountryCode: originCountryCode,
        startDate: startDate,
        endDate: endDate,
        notes: notes,
      );

      if (trip != null) {
        state = state.copyWith(isLoading: false, savedTrip: trip);
        // Refresh trips list
        _ref.invalidate(tripsListProvider);
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to create trip');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateTrip({
    required String tripId,
    String? name,
    String? originCity,
    String? originCountryCode,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final trip = await _repo.updateTrip(
        tripId: tripId,
        name: name,
        originCity: originCity,
        originCountryCode: originCountryCode,
        startDate: startDate,
        endDate: endDate,
        notes: notes,
      );

      if (trip != null) {
        state = state.copyWith(isLoading: false, savedTrip: trip);
        // Refresh trips list and single trip
        _ref.invalidate(tripsListProvider);
        _ref.invalidate(tripProvider(tripId));
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to update trip');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void reset() {
    state = const TripFormState();
  }
}

final tripFormProvider =
    StateNotifierProvider<TripFormNotifier, TripFormState>((ref) {
  return TripFormNotifier(ref.watch(tripsRepositoryProvider), ref);
});

/// Trip actions (archive, delete)
class TripActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final TripsRepository _repo;
  final Ref _ref;

  TripActionsNotifier(this._repo, this._ref) : super(const AsyncValue.data(null));

  Future<bool> archiveTrip(String tripId) async {
    state = const AsyncValue.loading();
    try {
      final success = await _repo.archiveTrip(tripId);
      if (success) {
        _ref.invalidate(tripsListProvider);
        state = const AsyncValue.data(null);
        return true;
      }
      state = AsyncValue.error('Failed to archive trip', StackTrace.current);
      return false;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteTrip(String tripId) async {
    state = const AsyncValue.loading();
    try {
      final success = await _repo.deleteTrip(tripId);
      if (success) {
        _ref.invalidate(tripsListProvider);
        state = const AsyncValue.data(null);
        return true;
      }
      state = AsyncValue.error('Failed to delete trip', StackTrace.current);
      return false;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> startTrip(String tripId) async {
    state = const AsyncValue.loading();
    try {
      final success = await _repo.startTrip(tripId);
      if (success) {
        _ref.invalidate(tripsListProvider);
        _ref.invalidate(tripProvider(tripId));
        state = const AsyncValue.data(null);
        return true;
      }
      state = AsyncValue.error('Failed to start trip', StackTrace.current);
      return false;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> completeTrip(String tripId) async {
    state = const AsyncValue.loading();
    try {
      final success = await _repo.completeTrip(tripId);
      if (success) {
        _ref.invalidate(tripsListProvider);
        _ref.invalidate(tripProvider(tripId));
        state = const AsyncValue.data(null);
        return true;
      }
      state = AsyncValue.error('Failed to complete trip', StackTrace.current);
      return false;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> revertToPlanned(String tripId) async {
    state = const AsyncValue.loading();
    try {
      final success = await _repo.revertTripToPlanned(tripId);
      if (success) {
        _ref.invalidate(tripsListProvider);
        _ref.invalidate(tripProvider(tripId));
        state = const AsyncValue.data(null);
        return true;
      }
      state = AsyncValue.error('Failed to revert trip', StackTrace.current);
      return false;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final tripActionsProvider =
    StateNotifierProvider<TripActionsNotifier, AsyncValue<void>>((ref) {
  return TripActionsNotifier(ref.watch(tripsRepositoryProvider), ref);
});
