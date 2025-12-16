import 'package:flutter_test/flutter_test.dart';
import 'package:waydeck/shared/models/models.dart';
import 'package:waydeck/shared/services/timeline_service.dart';

void main() {
  late TimelineService service;

  setUp(() {
    service = const TimelineService();
  });

  group('TimelineService', () {
    group('buildTimeline', () {
      test('returns empty list for empty input', () {
        final result = service.buildTimeline([]);
        expect(result, isEmpty);
      });

      test('groups items by day', () {
        final items = [
          _createTripItem(
            id: '1',
            type: TripItemType.transport,
            startTime: DateTime(2025, 12, 1, 8, 0),
          ),
          _createTripItem(
            id: '2',
            type: TripItemType.stay,
            startTime: DateTime(2025, 12, 1, 14, 0),
          ),
          _createTripItem(
            id: '3',
            type: TripItemType.activity,
            startTime: DateTime(2025, 12, 2, 9, 0),
          ),
        ];

        final result = service.buildTimeline(items);

        expect(result.length, 2); // 2 days
        expect(result[0].entries.length, 2); // 2 items on day 1
        expect(result[1].entries.length, 1); // 1 item on day 2
      });

      test('sorts items within a day', () {
        final items = [
          _createTripItem(
            id: '2',
            type: TripItemType.stay,
            startTime: DateTime(2025, 12, 1, 14, 0),
          ),
          _createTripItem(
            id: '1',
            type: TripItemType.transport,
            startTime: DateTime(2025, 12, 1, 8, 0),
          ),
        ];

        final result = service.buildTimeline(items);

        expect(result.length, 1);
        final entries = result[0].entries;
        expect(entries.length, 2);
        
        // First entry should be the earlier one (8:00)
        expect((entries[0] as TripItemEntry).item.id, '1');
        expect((entries[1] as TripItemEntry).item.id, '2');
      });
    });

    group('computeLayover', () {
      test('returns null for non-transport items', () {
        final itemA = _createTripItem(
          id: '1',
          type: TripItemType.stay,
          startTime: DateTime(2025, 12, 1, 8, 0),
        );
        final itemB = _createTripItem(
          id: '2',
          type: TripItemType.transport,
          startTime: DateTime(2025, 12, 1, 12, 0),
        );

        final result = service.computeLayover(itemA, itemB);
        expect(result, isNull);
      });

      test('returns null for different cities', () {
        final itemA = _createTransportItem(
          id: '1',
          startTime: DateTime(2025, 12, 1, 8, 0),
          endTime: DateTime(2025, 12, 1, 9, 0),
          originCity: 'Pune',
          destinationCity: 'Mumbai',
          arrivalLocal: DateTime(2025, 12, 1, 9, 0),
        );
        final itemB = _createTransportItem(
          id: '2',
          startTime: DateTime(2025, 12, 1, 13, 0),
          endTime: DateTime(2025, 12, 1, 18, 0),
          originCity: 'Delhi', // Different from Mumbai
          destinationCity: 'Bangkok',
          departureLocal: DateTime(2025, 12, 1, 13, 0),
        );

        final result = service.computeLayover(itemA, itemB);
        expect(result, isNull);
      });

      test('calculates correct layover duration for matching cities', () {
        final itemA = _createTransportItem(
          id: '1',
          startTime: DateTime(2025, 12, 1, 8, 0),
          endTime: DateTime(2025, 12, 1, 9, 0),
          originCity: 'Pune',
          destinationCity: 'Mumbai',
          arrivalLocal: DateTime(2025, 12, 1, 9, 0),
        );
        final itemB = _createTransportItem(
          id: '2',
          startTime: DateTime(2025, 12, 1, 13, 30),
          endTime: DateTime(2025, 12, 1, 18, 0),
          originCity: 'Mumbai', // Matches destination of A
          destinationCity: 'Bangkok',
          departureLocal: DateTime(2025, 12, 1, 13, 30),
        );

        final result = service.computeLayover(itemA, itemB);

        expect(result, isNotNull);
        expect(result!.duration, const Duration(hours: 4, minutes: 30));
        expect(result.durationString, '4h 30m');
      });

      test('case-insensitive city matching', () {
        final itemA = _createTransportItem(
          id: '1',
          startTime: DateTime(2025, 12, 1, 8, 0),
          endTime: DateTime(2025, 12, 1, 9, 0),
          originCity: 'Pune',
          destinationCity: 'MUMBAI', // Uppercase
          arrivalLocal: DateTime(2025, 12, 1, 9, 0),
        );
        final itemB = _createTransportItem(
          id: '2',
          startTime: DateTime(2025, 12, 1, 11, 0),
          endTime: DateTime(2025, 12, 1, 18, 0),
          originCity: 'mumbai', // Lowercase
          destinationCity: 'Bangkok',
          departureLocal: DateTime(2025, 12, 1, 11, 0),
        );

        final result = service.computeLayover(itemA, itemB);
        expect(result, isNotNull);
        expect(result!.duration, const Duration(hours: 2));
      });

      test('returns null when departure is before arrival', () {
        final itemA = _createTransportItem(
          id: '1',
          startTime: DateTime(2025, 12, 1, 8, 0),
          endTime: DateTime(2025, 12, 1, 14, 0), // Arrives at 14:00
          originCity: 'Pune',
          destinationCity: 'Mumbai',
          arrivalLocal: DateTime(2025, 12, 1, 14, 0),
        );
        final itemB = _createTransportItem(
          id: '2',
          startTime: DateTime(2025, 12, 1, 12, 0), // Departs at 12:00 (before arrival!)
          endTime: DateTime(2025, 12, 1, 18, 0),
          originCity: 'Mumbai',
          destinationCity: 'Bangkok',
          departureLocal: DateTime(2025, 12, 1, 12, 0),
        );

        final result = service.computeLayover(itemA, itemB);
        expect(result, isNull);
      });
    });

    group('getTotalLayoverDuration', () {
      test('sums layovers across multiple segments', () {
        final items = [
          _createTransportItem(
            id: '1',
            startTime: DateTime(2025, 12, 1, 8, 0),
            endTime: DateTime(2025, 12, 1, 9, 0),
            originCity: 'Pune',
            destinationCity: 'Mumbai',
            arrivalLocal: DateTime(2025, 12, 1, 9, 0),
          ),
          _createTransportItem(
            id: '2',
            startTime: DateTime(2025, 12, 1, 11, 0),
            endTime: DateTime(2025, 12, 1, 15, 0),
            originCity: 'Mumbai',
            destinationCity: 'Bangkok',
            departureLocal: DateTime(2025, 12, 1, 11, 0),
            arrivalLocal: DateTime(2025, 12, 1, 15, 0),
          ),
          _createTransportItem(
            id: '3',
            startTime: DateTime(2025, 12, 1, 17, 0),
            endTime: DateTime(2025, 12, 1, 18, 30),
            originCity: 'Bangkok',
            destinationCity: 'Da Nang',
            departureLocal: DateTime(2025, 12, 1, 17, 0),
          ),
        ];

        final result = service.getTotalLayoverDuration(items);

        // Layover 1: 9:00 to 11:00 = 2h
        // Layover 2: 15:00 to 17:00 = 2h
        // Total = 4h
        expect(result, const Duration(hours: 4));
      });
    });
  });
}

/// Helper to create a basic TripItem for testing
TripItem _createTripItem({
  required String id,
  required TripItemType type,
  DateTime? startTime,
  DateTime? endTime,
}) {
  return TripItem(
    id: id,
    tripId: 'test-trip',
    type: type,
    title: 'Test Item $id',
    startTimeUtc: startTime,
    endTimeUtc: endTime,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

/// Helper to create a transport TripItem for testing
TripItem _createTransportItem({
  required String id,
  required DateTime startTime,
  required DateTime endTime,
  required String originCity,
  required String destinationCity,
  DateTime? departureLocal,
  DateTime? arrivalLocal,
  String? originAirportCode,
  String? destinationAirportCode,
}) {
  return TripItem(
    id: id,
    tripId: 'test-trip',
    type: TripItemType.transport,
    title: 'Transport $originCity to $destinationCity',
    startTimeUtc: startTime,
    endTimeUtc: endTime,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    transportDetails: TransportItemDetails(
      mode: TransportMode.flight,
      originCity: originCity,
      destinationCity: destinationCity,
      originAirportCode: originAirportCode,
      destinationAirportCode: destinationAirportCode,
      departureLocal: departureLocal,
      arrivalLocal: arrivalLocal,
    ),
  );
}
