import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/models.dart';
import '../../data/trip_items_repository.dart';

/// Trip items list provider
final tripItemsProvider =
    FutureProvider.family<List<TripItem>, String>((ref, tripId) async {
  final repo = ref.watch(tripItemsRepositoryProvider);
  return repo.getTripItems(tripId);
});

/// Single trip item provider
final tripItemProvider =
    FutureProvider.family<TripItem?, String>((ref, itemId) async {
  final repo = ref.watch(tripItemsRepositoryProvider);
  return repo.getTripItem(itemId);
});

/// Trip item form state
class TripItemFormState {
  final bool isLoading;
  final String? error;
  final TripItem? savedItem;

  const TripItemFormState({
    this.isLoading = false,
    this.error,
    this.savedItem,
  });

  TripItemFormState copyWith({
    bool? isLoading,
    String? error,
    TripItem? savedItem,
  }) {
    return TripItemFormState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      savedItem: savedItem,
    );
  }
}

/// Trip item form notifier
class TripItemFormNotifier extends StateNotifier<TripItemFormState> {
  final TripItemsRepository _repo;
  final Ref _ref;

  TripItemFormNotifier(this._repo, this._ref) : super(const TripItemFormState());

  Future<bool> createTransportItem({
    required String tripId,
    required String title,
    String? description,
    DateTime? startTimeUtc,
    DateTime? endTimeUtc,
    String? localTz,
    String? comment,
    required TransportMode mode,
    String? carrierName,
    String? carrierCode,
    String? transportNumber,
    String? bookingReference,
    String? originCity,
    String? originCountryCode,
    String? originAirportCode,
    String? originTerminal,
    String? destinationCity,
    String? destinationCountryCode,
    String? destinationAirportCode,
    String? destinationTerminal,
    DateTime? departureLocal,
    DateTime? arrivalLocal,
    int? passengerCount,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final item = await _repo.createTransportItem(
        tripId: tripId,
        title: title,
        description: description,
        startTimeUtc: startTimeUtc,
        endTimeUtc: endTimeUtc,
        localTz: localTz,
        comment: comment,
        mode: mode,
        carrierName: carrierName,
        carrierCode: carrierCode,
        transportNumber: transportNumber,
        bookingReference: bookingReference,
        originCity: originCity,
        originCountryCode: originCountryCode,
        originAirportCode: originAirportCode,
        originTerminal: originTerminal,
        destinationCity: destinationCity,
        destinationCountryCode: destinationCountryCode,
        destinationAirportCode: destinationAirportCode,
        destinationTerminal: destinationTerminal,
        departureLocal: departureLocal,
        arrivalLocal: arrivalLocal,
        passengerCount: passengerCount,
      );

      if (item != null) {
        state = state.copyWith(isLoading: false, savedItem: item);
        _ref.invalidate(tripItemsProvider(tripId));
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to save');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> createStayItem({
    required String tripId,
    required String title,
    String? description,
    DateTime? startTimeUtc,
    DateTime? endTimeUtc,
    String? localTz,
    String? comment,
    required String accommodationName,
    String? address,
    String? city,
    String? countryCode,
    DateTime? checkinLocal,
    DateTime? checkoutLocal,
    bool hasBreakfast = false,
    String? confirmationNumber,
    String? bookingUrl,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final item = await _repo.createStayItem(
        tripId: tripId,
        title: title,
        description: description,
        startTimeUtc: startTimeUtc,
        endTimeUtc: endTimeUtc,
        localTz: localTz,
        comment: comment,
        accommodationName: accommodationName,
        address: address,
        city: city,
        countryCode: countryCode,
        checkinLocal: checkinLocal,
        checkoutLocal: checkoutLocal,
        hasBreakfast: hasBreakfast,
        confirmationNumber: confirmationNumber,
        bookingUrl: bookingUrl,
      );

      if (item != null) {
        state = state.copyWith(isLoading: false, savedItem: item);
        _ref.invalidate(tripItemsProvider(tripId));
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to save');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> createActivityItem({
    required String tripId,
    required String title,
    String? description,
    DateTime? startTimeUtc,
    DateTime? endTimeUtc,
    String? localTz,
    String? comment,
    String? category,
    String? locationName,
    String? address,
    String? city,
    String? countryCode,
    DateTime? startLocal,
    DateTime? endLocal,
    String? bookingCode,
    String? bookingUrl,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final item = await _repo.createActivityItem(
        tripId: tripId,
        title: title,
        description: description,
        startTimeUtc: startTimeUtc,
        endTimeUtc: endTimeUtc,
        localTz: localTz,
        comment: comment,
        category: category,
        locationName: locationName,
        address: address,
        city: city,
        countryCode: countryCode,
        startLocal: startLocal,
        endLocal: endLocal,
        bookingCode: bookingCode,
        bookingUrl: bookingUrl,
      );

      if (item != null) {
        state = state.copyWith(isLoading: false, savedItem: item);
        _ref.invalidate(tripItemsProvider(tripId));
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to save');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> createNoteItem({
    required String tripId,
    required String title,
    String? description,
    DateTime? startTimeUtc,
    String? localTz,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final item = await _repo.createNoteItem(
        tripId: tripId,
        title: title,
        description: description,
        startTimeUtc: startTimeUtc,
        localTz: localTz,
      );

      if (item != null) {
        state = state.copyWith(isLoading: false, savedItem: item);
        _ref.invalidate(tripItemsProvider(tripId));
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to save');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void reset() {
    state = const TripItemFormState();
  }
}

final tripItemFormProvider =
    StateNotifierProvider<TripItemFormNotifier, TripItemFormState>((ref) {
  return TripItemFormNotifier(ref.watch(tripItemsRepositoryProvider), ref);
});

/// Delete item action
final deleteTripItemProvider = Provider<Future<bool> Function(String, String)>((ref) {
  final repo = ref.watch(tripItemsRepositoryProvider);
  return (String tripId, String itemId) async {
    final success = await repo.deleteTripItem(itemId);
    if (success) {
      ref.invalidate(tripItemsProvider(tripId));
    }
    return success;
  };
});
