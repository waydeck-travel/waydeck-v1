import '../models/enums.dart';

/// Configuration for transport form fields based on mode
class ModeFieldConfig {
  /// Carrier/Operator section
  final String carrierLabel;
  final String carrierHint;
  final bool showCarrierCode;
  final bool showCarrier;
  
  /// Number (Flight/Train/Bus number)
  final String numberLabel;
  final String numberHint;
  final bool showNumber;
  
  /// Booking reference
  final String bookingLabel;
  final String bookingHint;
  
  /// Location fields
  final bool showLocationCode;
  final String locationCodeLabel;
  final String locationCodeHint;
  final String stationLabel;
  final String stationHint;
  final bool showStation;
  
  /// Terminal/Platform/Bay
  final String terminalLabel;
  final String terminalHint;
  final bool showTerminal;
  
  /// Coach/Seat/Cabin
  final String coachSeatLabel;
  final String coachSeatHint;
  final bool showCoachSeat;
  
  /// Vehicle model/type info (for car/bike)
  final String vehicleLabel;
  final String vehicleHint;
  final bool showVehicle;
  
  /// Vehicle registration number (for car/bike/bus)
  final String vehicleNumberLabel;
  final String vehicleNumberHint;
  final bool showVehicleNumber;
  
  /// Same location toggle (for rentals)
  final bool allowSameLocation;
  
  /// Section labels
  final String originSectionLabel;
  final String destSectionLabel;
  
  /// Passengers
  final bool showPassengers;

  const ModeFieldConfig({
    required this.carrierLabel,
    required this.carrierHint,
    this.showCarrierCode = false,
    this.showCarrier = true,
    required this.numberLabel,
    required this.numberHint,
    this.showNumber = true,
    required this.bookingLabel,
    required this.bookingHint,
    this.showLocationCode = false,
    this.locationCodeLabel = 'Code',
    this.locationCodeHint = 'PNQ',
    required this.stationLabel,
    required this.stationHint,
    this.showStation = false,
    required this.terminalLabel,
    required this.terminalHint,
    this.showTerminal = true,
    required this.coachSeatLabel,
    required this.coachSeatHint,
    this.showCoachSeat = false,
    required this.vehicleLabel,
    required this.vehicleHint,
    this.showVehicle = false,
    this.vehicleNumberLabel = 'Vehicle Number',
    this.vehicleNumberHint = 'MH12AB1234',
    this.showVehicleNumber = false,
    this.allowSameLocation = false,
    required this.originSectionLabel,
    required this.destSectionLabel,
    this.showPassengers = true,
  });

  /// Get configuration for a specific transport mode
  static ModeFieldConfig forMode(TransportMode mode) {
    switch (mode) {
      case TransportMode.flight:
        return const ModeFieldConfig(
          carrierLabel: 'Airline',
          carrierHint: 'IndiGo, Air India, etc.',
          showCarrierCode: true,
          numberLabel: 'Flight Number',
          numberHint: '6E 5102',
          bookingLabel: 'PNR / Booking Ref',
          bookingHint: 'ABC123',
          showLocationCode: true,
          locationCodeLabel: 'Airport Code',
          locationCodeHint: 'PNQ',
          stationLabel: 'Airport',
          stationHint: 'Airport name',
          showStation: false,
          terminalLabel: 'Terminal',
          terminalHint: 'T1',
          showTerminal: true,
          coachSeatLabel: 'Seat',
          coachSeatHint: '12A',
          showCoachSeat: false,
          vehicleLabel: '',
          vehicleHint: '',
          showVehicle: false,
          originSectionLabel: 'Origin',
          destSectionLabel: 'Destination',
          showPassengers: true,
        );

      case TransportMode.train:
        return const ModeFieldConfig(
          carrierLabel: 'Railway / Operator',
          carrierHint: 'Indian Railways, Amtrak, etc.',
          showCarrierCode: false,
          numberLabel: 'Train Name / Number',
          numberHint: 'Shatabdi Express 12027',
          bookingLabel: 'PNR / Ticket Number',
          bookingHint: '123-4567890',
          showLocationCode: false,
          stationLabel: 'Station',
          stationHint: 'Pune Junction',
          showStation: true,
          terminalLabel: 'Platform',
          terminalHint: 'Platform 1',
          showTerminal: true,
          coachSeatLabel: 'Coach & Seat',
          coachSeatHint: 'C5, Seat 42',
          showCoachSeat: true,
          vehicleLabel: '',
          vehicleHint: '',
          showVehicle: false,
          originSectionLabel: 'Departure Station',
          destSectionLabel: 'Arrival Station',
          showPassengers: true,
        );

      case TransportMode.bus:
        return const ModeFieldConfig(
          carrierLabel: 'Bus Operator',
          carrierHint: 'Greyhound, RedBus, VRL, etc.',
          showCarrierCode: false,
          numberLabel: 'Bus Number / Type',
          numberHint: 'Volvo AC Sleeper',
          bookingLabel: 'Ticket Number',
          bookingHint: 'BUS123456',
          showLocationCode: false,
          stationLabel: 'Bus Stop / Stand',
          stationHint: 'Shivajinagar Bus Stand',
          showStation: true,
          terminalLabel: 'Bay / Platform',
          terminalHint: 'Bay 5',
          showTerminal: true,
          coachSeatLabel: 'Seat Number',
          coachSeatHint: '12A',
          showCoachSeat: true,
          vehicleLabel: '',
          vehicleHint: '',
          showVehicle: false,
          vehicleNumberLabel: 'Bus Registration',
          vehicleNumberHint: 'MH12AB1234',
          showVehicleNumber: true,
          originSectionLabel: 'Departure Stop',
          destSectionLabel: 'Arrival Stop',
          showPassengers: true,
        );

      case TransportMode.car:
        return const ModeFieldConfig(
          carrierLabel: 'Rental Company',
          carrierHint: 'Hertz, Zoomcar, or "Personal"',
          showCarrierCode: false,
          numberLabel: '',
          numberHint: '',
          showNumber: false,
          bookingLabel: 'Confirmation Number',
          bookingHint: 'CONF123',
          showLocationCode: false,
          stationLabel: 'Location / Address',
          stationHint: 'Airport, Hotel, etc.',
          showStation: true,
          terminalLabel: '',
          terminalHint: '',
          showTerminal: false,
          coachSeatLabel: '',
          coachSeatHint: '',
          showCoachSeat: false,
          vehicleLabel: 'Car Model',
          vehicleHint: 'Toyota Camry',
          showVehicle: true,
          vehicleNumberLabel: 'Registration / License Plate',
          vehicleNumberHint: 'MH12AB1234',
          showVehicleNumber: true,
          allowSameLocation: true,
          originSectionLabel: 'Pickup',
          destSectionLabel: 'Dropoff',
          showPassengers: true,
        );

      case TransportMode.bike:
        return const ModeFieldConfig(
          carrierLabel: 'Rental Company',
          carrierHint: 'Bounce, Yulu, or "Personal"',
          showCarrierCode: false,
          numberLabel: '',
          numberHint: '',
          showNumber: false,
          bookingLabel: 'Confirmation Number',
          bookingHint: 'CONF123',
          showLocationCode: false,
          stationLabel: 'Location',
          stationHint: 'Pickup/Dropoff point',
          showStation: true,
          terminalLabel: '',
          terminalHint: '',
          showTerminal: false,
          coachSeatLabel: '',
          coachSeatHint: '',
          showCoachSeat: false,
          vehicleLabel: 'Bike Type',
          vehicleHint: 'Scooter, Motorcycle, Bicycle',
          showVehicle: true,
          vehicleNumberLabel: 'Registration / License Plate',
          vehicleNumberHint: 'MH12AB1234',
          showVehicleNumber: true,
          allowSameLocation: true,
          originSectionLabel: 'Pickup',
          destSectionLabel: 'Dropoff',
          showPassengers: false,
        );

      case TransportMode.cruise:
        return const ModeFieldConfig(
          carrierLabel: 'Cruise Line',
          carrierHint: 'Royal Caribbean, Carnival, etc.',
          showCarrierCode: false,
          numberLabel: 'Ship Name',
          numberHint: 'Symphony of the Seas',
          bookingLabel: 'Booking Reference',
          bookingHint: 'CRU123456',
          showLocationCode: false,
          stationLabel: 'Port Name',
          stationHint: 'Port of Miami',
          showStation: true,
          terminalLabel: 'Pier / Terminal',
          terminalHint: 'Pier 5',
          showTerminal: true,
          coachSeatLabel: 'Cabin Number',
          coachSeatHint: 'D450',
          showCoachSeat: true,
          vehicleLabel: '',
          vehicleHint: '',
          showVehicle: false,
          originSectionLabel: 'Embarkation Port',
          destSectionLabel: 'Disembarkation Port',
          showPassengers: true,
        );

      case TransportMode.metro:
        return const ModeFieldConfig(
          carrierLabel: '',
          carrierHint: '',
          showCarrier: false,
          showCarrierCode: false,
          numberLabel: 'Line Name / Number',
          numberHint: 'Purple Line, L1',
          bookingLabel: '',
          bookingHint: '',
          showLocationCode: false,
          stationLabel: 'Station',
          stationHint: 'Station name',
          showStation: true,
          terminalLabel: '',
          terminalHint: '',
          showTerminal: false,
          coachSeatLabel: '',
          coachSeatHint: '',
          showCoachSeat: false,
          vehicleLabel: '',
          vehicleHint: '',
          showVehicle: false,
          originSectionLabel: 'From Station',
          destSectionLabel: 'To Station',
          showPassengers: false,
        );

      case TransportMode.ferry:
        return const ModeFieldConfig(
          carrierLabel: 'Ferry Operator',
          carrierHint: 'BC Ferries, etc.',
          showCarrierCode: false,
          numberLabel: 'Ferry Name / Route',
          numberHint: 'Spirit of British Columbia',
          bookingLabel: 'Booking Reference',
          bookingHint: 'FERRY123',
          showLocationCode: false,
          stationLabel: 'Port Name',
          stationHint: 'Horseshoe Bay',
          showStation: true,
          terminalLabel: 'Pier / Terminal',
          terminalHint: 'Terminal 1',
          showTerminal: true,
          coachSeatLabel: 'Deck / Cabin',
          coachSeatHint: 'Deck 3 or Cabin A12',
          showCoachSeat: true,
          vehicleLabel: '',
          vehicleHint: '',
          showVehicle: false,
          originSectionLabel: 'Origin Port',
          destSectionLabel: 'Destination Port',
          showPassengers: true,
        );

      case TransportMode.other:
        return const ModeFieldConfig(
          carrierLabel: 'Operator / Company',
          carrierHint: 'Company name',
          showCarrierCode: false,
          numberLabel: 'Number / Name',
          numberHint: 'Vehicle number',
          bookingLabel: 'Booking Reference',
          bookingHint: 'Ref number',
          showLocationCode: false,
          stationLabel: 'Location',
          stationHint: 'Address or place',
          showStation: true,
          terminalLabel: '',
          terminalHint: '',
          showTerminal: false,
          coachSeatLabel: '',
          coachSeatHint: '',
          showCoachSeat: false,
          vehicleLabel: 'Vehicle Info',
          vehicleHint: 'Vehicle details',
          showVehicle: true,
          originSectionLabel: 'Origin',
          destSectionLabel: 'Destination',
          showPassengers: true,
        );
    }
  }
}
