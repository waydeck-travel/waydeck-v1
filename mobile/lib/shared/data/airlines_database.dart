/// Airline model for autocomplete
class Airline {
  final String iataCode;
  final String icaoCode;
  final String name;
  final String? country;
  final String? logo;

  const Airline({
    required this.iataCode,
    required this.icaoCode,
    required this.name,
    this.country,
    this.logo,
  });

  /// Display name with code
  String get displayName => '$name ($iataCode)';

  /// Search string for filtering
  String get searchString => '$iataCode $icaoCode $name'.toLowerCase();
}

/// Major airlines database
/// Contains popular airlines with IATA and ICAO codes
const List<Airline> airlinesDatabase = [
  // India
  Airline(iataCode: '6E', icaoCode: 'IGO', name: 'IndiGo', country: 'India'),
  Airline(iataCode: 'AI', icaoCode: 'AIC', name: 'Air India', country: 'India'),
  Airline(iataCode: 'UK', icaoCode: 'VTI', name: 'Vistara', country: 'India'),
  Airline(iataCode: 'SG', icaoCode: 'SEJ', name: 'SpiceJet', country: 'India'),
  Airline(iataCode: 'G8', icaoCode: 'GOW', name: 'Go First', country: 'India'),
  Airline(iataCode: 'IX', icaoCode: 'AXB', name: 'Air India Express', country: 'India'),
  Airline(iataCode: 'QP', icaoCode: 'AKJ', name: 'Akasa Air', country: 'India'),
  
  // Middle East
  Airline(iataCode: 'EK', icaoCode: 'UAE', name: 'Emirates', country: 'UAE'),
  Airline(iataCode: 'QR', icaoCode: 'QTR', name: 'Qatar Airways', country: 'Qatar'),
  Airline(iataCode: 'EY', icaoCode: 'ETD', name: 'Etihad Airways', country: 'UAE'),
  Airline(iataCode: 'WY', icaoCode: 'OMA', name: 'Oman Air', country: 'Oman'),
  Airline(iataCode: 'GF', icaoCode: 'GFA', name: 'Gulf Air', country: 'Bahrain'),
  Airline(iataCode: 'SV', icaoCode: 'SVA', name: 'Saudia', country: 'Saudi Arabia'),
  Airline(iataCode: 'FZ', icaoCode: 'FDB', name: 'flydubai', country: 'UAE'),
  
  // Asia
  Airline(iataCode: 'SQ', icaoCode: 'SIA', name: 'Singapore Airlines', country: 'Singapore'),
  Airline(iataCode: 'CX', icaoCode: 'CPA', name: 'Cathay Pacific', country: 'Hong Kong'),
  Airline(iataCode: 'TG', icaoCode: 'THA', name: 'Thai Airways', country: 'Thailand'),
  Airline(iataCode: 'MH', icaoCode: 'MAS', name: 'Malaysia Airlines', country: 'Malaysia'),
  Airline(iataCode: 'AK', icaoCode: 'AXM', name: 'AirAsia', country: 'Malaysia'),
  Airline(iataCode: 'GA', icaoCode: 'GIA', name: 'Garuda Indonesia', country: 'Indonesia'),
  Airline(iataCode: 'VN', icaoCode: 'HVN', name: 'Vietnam Airlines', country: 'Vietnam'),
  Airline(iataCode: 'KE', icaoCode: 'KAL', name: 'Korean Air', country: 'South Korea'),
  Airline(iataCode: 'OZ', icaoCode: 'AAR', name: 'Asiana Airlines', country: 'South Korea'),
  Airline(iataCode: 'JL', icaoCode: 'JAL', name: 'Japan Airlines', country: 'Japan'),
  Airline(iataCode: 'NH', icaoCode: 'ANA', name: 'All Nippon Airways', country: 'Japan'),
  Airline(iataCode: 'CA', icaoCode: 'CCA', name: 'Air China', country: 'China'),
  Airline(iataCode: 'MU', icaoCode: 'CES', name: 'China Eastern', country: 'China'),
  Airline(iataCode: 'CZ', icaoCode: 'CSN', name: 'China Southern', country: 'China'),
  Airline(iataCode: 'CI', icaoCode: 'CAL', name: 'China Airlines', country: 'Taiwan'),
  Airline(iataCode: 'BR', icaoCode: 'EVA', name: 'EVA Air', country: 'Taiwan'),
  Airline(iataCode: 'PR', icaoCode: 'PAL', name: 'Philippine Airlines', country: 'Philippines'),
  Airline(iataCode: '5J', icaoCode: 'CEB', name: 'Cebu Pacific', country: 'Philippines'),
  Airline(iataCode: 'UL', icaoCode: 'ALK', name: 'SriLankan Airlines', country: 'Sri Lanka'),
  Airline(iataCode: 'BG', icaoCode: 'BBC', name: 'Biman Bangladesh', country: 'Bangladesh'),
  Airline(iataCode: 'RA', icaoCode: 'RNA', name: 'Nepal Airlines', country: 'Nepal'),
  Airline(iataCode: 'PK', icaoCode: 'PIA', name: 'Pakistan International', country: 'Pakistan'),
  
  // Europe
  Airline(iataCode: 'LH', icaoCode: 'DLH', name: 'Lufthansa', country: 'Germany'),
  Airline(iataCode: 'BA', icaoCode: 'BAW', name: 'British Airways', country: 'UK'),
  Airline(iataCode: 'AF', icaoCode: 'AFR', name: 'Air France', country: 'France'),
  Airline(iataCode: 'KL', icaoCode: 'KLM', name: 'KLM Royal Dutch', country: 'Netherlands'),
  Airline(iataCode: 'IB', icaoCode: 'IBE', name: 'Iberia', country: 'Spain'),
  Airline(iataCode: 'AZ', icaoCode: 'ITY', name: 'ITA Airways', country: 'Italy'),
  Airline(iataCode: 'LX', icaoCode: 'SWR', name: 'Swiss International', country: 'Switzerland'),
  Airline(iataCode: 'OS', icaoCode: 'AUA', name: 'Austrian Airlines', country: 'Austria'),
  Airline(iataCode: 'SK', icaoCode: 'SAS', name: 'Scandinavian Airlines', country: 'Sweden'),
  Airline(iataCode: 'AY', icaoCode: 'FIN', name: 'Finnair', country: 'Finland'),
  Airline(iataCode: 'TP', icaoCode: 'TAP', name: 'TAP Air Portugal', country: 'Portugal'),
  Airline(iataCode: 'TK', icaoCode: 'THY', name: 'Turkish Airlines', country: 'Turkey'),
  Airline(iataCode: 'SU', icaoCode: 'AFL', name: 'Aeroflot', country: 'Russia'),
  Airline(iataCode: 'LO', icaoCode: 'LOT', name: 'LOT Polish Airlines', country: 'Poland'),
  Airline(iataCode: 'FR', icaoCode: 'RYR', name: 'Ryanair', country: 'Ireland'),
  Airline(iataCode: 'U2', icaoCode: 'EZY', name: 'easyJet', country: 'UK'),
  Airline(iataCode: 'W6', icaoCode: 'WZZ', name: 'Wizz Air', country: 'Hungary'),
  Airline(iataCode: 'VY', icaoCode: 'VLG', name: 'Vueling', country: 'Spain'),
  Airline(iataCode: 'EW', icaoCode: 'EWG', name: 'Eurowings', country: 'Germany'),
  
  // Americas
  Airline(iataCode: 'AA', icaoCode: 'AAL', name: 'American Airlines', country: 'USA'),
  Airline(iataCode: 'UA', icaoCode: 'UAL', name: 'United Airlines', country: 'USA'),
  Airline(iataCode: 'DL', icaoCode: 'DAL', name: 'Delta Air Lines', country: 'USA'),
  Airline(iataCode: 'WN', icaoCode: 'SWA', name: 'Southwest Airlines', country: 'USA'),
  Airline(iataCode: 'B6', icaoCode: 'JBU', name: 'JetBlue Airways', country: 'USA'),
  Airline(iataCode: 'AS', icaoCode: 'ASA', name: 'Alaska Airlines', country: 'USA'),
  Airline(iataCode: 'AC', icaoCode: 'ACA', name: 'Air Canada', country: 'Canada'),
  Airline(iataCode: 'WS', icaoCode: 'WJA', name: 'WestJet', country: 'Canada'),
  Airline(iataCode: 'AM', icaoCode: 'AMX', name: 'Aeromexico', country: 'Mexico'),
  Airline(iataCode: 'LA', icaoCode: 'LAN', name: 'LATAM Airlines', country: 'Chile'),
  Airline(iataCode: 'G3', icaoCode: 'GLO', name: 'Gol Airlines', country: 'Brazil'),
  Airline(iataCode: 'AV', icaoCode: 'AVA', name: 'Avianca', country: 'Colombia'),
  Airline(iataCode: 'CM', icaoCode: 'CMP', name: 'Copa Airlines', country: 'Panama'),
  
  // Africa & Oceania
  Airline(iataCode: 'ET', icaoCode: 'ETH', name: 'Ethiopian Airlines', country: 'Ethiopia'),
  Airline(iataCode: 'SA', icaoCode: 'SAA', name: 'South African Airways', country: 'South Africa'),
  Airline(iataCode: 'MS', icaoCode: 'MSR', name: 'EgyptAir', country: 'Egypt'),
  Airline(iataCode: 'AT', icaoCode: 'RAM', name: 'Royal Air Maroc', country: 'Morocco'),
  Airline(iataCode: 'KQ', icaoCode: 'KQA', name: 'Kenya Airways', country: 'Kenya'),
  Airline(iataCode: 'RW', icaoCode: 'RWD', name: 'RwandAir', country: 'Rwanda'),
  Airline(iataCode: 'QF', icaoCode: 'QFA', name: 'Qantas', country: 'Australia'),
  Airline(iataCode: 'NZ', icaoCode: 'ANZ', name: 'Air New Zealand', country: 'New Zealand'),
  Airline(iataCode: 'FJ', icaoCode: 'FJI', name: 'Fiji Airways', country: 'Fiji'),
  Airline(iataCode: 'JQ', icaoCode: 'JST', name: 'Jetstar', country: 'Australia'),
  Airline(iataCode: 'VA', icaoCode: 'VOZ', name: 'Virgin Australia', country: 'Australia'),
];

/// Search airlines by query (code or name)
List<Airline> searchAirlines(String query) {
  if (query.isEmpty) return [];
  
  final lowerQuery = query.toLowerCase();
  return airlinesDatabase
      .where((airline) => airline.searchString.contains(lowerQuery))
      .take(10)
      .toList();
}

/// Find airline by IATA code
Airline? findAirlineByCode(String code) {
  final upperCode = code.toUpperCase();
  try {
    return airlinesDatabase.firstWhere(
      (airline) => airline.iataCode == upperCode || airline.icaoCode == upperCode,
    );
  } catch (_) {
    return null;
  }
}
