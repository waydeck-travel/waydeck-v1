/// Country data for autocomplete dropdown
/// Contains common countries with their ISO 3166-1 alpha-2 codes
library;

class Country {
  final String code;
  final String name;
  final String? emoji;

  const Country({
    required this.code,
    required this.name,
    this.emoji,
  });

  @override
  String toString() => name;
}

/// List of common countries sorted alphabetically
const List<Country> countries = [
  Country(code: 'AF', name: 'Afghanistan', emoji: '🇦🇫'),
  Country(code: 'AL', name: 'Albania', emoji: '🇦🇱'),
  Country(code: 'DZ', name: 'Algeria', emoji: '🇩🇿'),
  Country(code: 'AR', name: 'Argentina', emoji: '🇦🇷'),
  Country(code: 'AU', name: 'Australia', emoji: '🇦🇺'),
  Country(code: 'AT', name: 'Austria', emoji: '🇦🇹'),
  Country(code: 'BD', name: 'Bangladesh', emoji: '🇧🇩'),
  Country(code: 'BE', name: 'Belgium', emoji: '🇧🇪'),
  Country(code: 'BR', name: 'Brazil', emoji: '🇧🇷'),
  Country(code: 'KH', name: 'Cambodia', emoji: '🇰🇭'),
  Country(code: 'CA', name: 'Canada', emoji: '🇨🇦'),
  Country(code: 'CL', name: 'Chile', emoji: '🇨🇱'),
  Country(code: 'CN', name: 'China', emoji: '🇨🇳'),
  Country(code: 'CO', name: 'Colombia', emoji: '🇨🇴'),
  Country(code: 'HR', name: 'Croatia', emoji: '🇭🇷'),
  Country(code: 'CZ', name: 'Czech Republic', emoji: '🇨🇿'),
  Country(code: 'DK', name: 'Denmark', emoji: '🇩🇰'),
  Country(code: 'EG', name: 'Egypt', emoji: '🇪🇬'),
  Country(code: 'FI', name: 'Finland', emoji: '🇫🇮'),
  Country(code: 'FR', name: 'France', emoji: '🇫🇷'),
  Country(code: 'DE', name: 'Germany', emoji: '🇩🇪'),
  Country(code: 'GR', name: 'Greece', emoji: '🇬🇷'),
  Country(code: 'HK', name: 'Hong Kong', emoji: '🇭🇰'),
  Country(code: 'HU', name: 'Hungary', emoji: '🇭🇺'),
  Country(code: 'IS', name: 'Iceland', emoji: '🇮🇸'),
  Country(code: 'IN', name: 'India', emoji: '🇮🇳'),
  Country(code: 'ID', name: 'Indonesia', emoji: '🇮🇩'),
  Country(code: 'IR', name: 'Iran', emoji: '🇮🇷'),
  Country(code: 'IE', name: 'Ireland', emoji: '🇮🇪'),
  Country(code: 'IL', name: 'Israel', emoji: '🇮🇱'),
  Country(code: 'IT', name: 'Italy', emoji: '🇮🇹'),
  Country(code: 'JP', name: 'Japan', emoji: '🇯🇵'),
  Country(code: 'JO', name: 'Jordan', emoji: '🇯🇴'),
  Country(code: 'KE', name: 'Kenya', emoji: '🇰🇪'),
  Country(code: 'KR', name: 'South Korea', emoji: '🇰🇷'),
  Country(code: 'KW', name: 'Kuwait', emoji: '🇰🇼'),
  Country(code: 'LA', name: 'Laos', emoji: '🇱🇦'),
  Country(code: 'LB', name: 'Lebanon', emoji: '🇱🇧'),
  Country(code: 'MY', name: 'Malaysia', emoji: '🇲🇾'),
  Country(code: 'MV', name: 'Maldives', emoji: '🇲🇻'),
  Country(code: 'MX', name: 'Mexico', emoji: '🇲🇽'),
  Country(code: 'MA', name: 'Morocco', emoji: '🇲🇦'),
  Country(code: 'MM', name: 'Myanmar', emoji: '🇲🇲'),
  Country(code: 'NP', name: 'Nepal', emoji: '🇳🇵'),
  Country(code: 'NL', name: 'Netherlands', emoji: '🇳🇱'),
  Country(code: 'NZ', name: 'New Zealand', emoji: '🇳🇿'),
  Country(code: 'NO', name: 'Norway', emoji: '🇳🇴'),
  Country(code: 'OM', name: 'Oman', emoji: '🇴🇲'),
  Country(code: 'PK', name: 'Pakistan', emoji: '🇵🇰'),
  Country(code: 'PE', name: 'Peru', emoji: '🇵🇪'),
  Country(code: 'PH', name: 'Philippines', emoji: '🇵🇭'),
  Country(code: 'PL', name: 'Poland', emoji: '🇵🇱'),
  Country(code: 'PT', name: 'Portugal', emoji: '🇵🇹'),
  Country(code: 'QA', name: 'Qatar', emoji: '🇶🇦'),
  Country(code: 'RO', name: 'Romania', emoji: '🇷🇴'),
  Country(code: 'RU', name: 'Russia', emoji: '🇷🇺'),
  Country(code: 'SA', name: 'Saudi Arabia', emoji: '🇸🇦'),
  Country(code: 'SG', name: 'Singapore', emoji: '🇸🇬'),
  Country(code: 'ZA', name: 'South Africa', emoji: '🇿🇦'),
  Country(code: 'ES', name: 'Spain', emoji: '🇪🇸'),
  Country(code: 'LK', name: 'Sri Lanka', emoji: '🇱🇰'),
  Country(code: 'SE', name: 'Sweden', emoji: '🇸🇪'),
  Country(code: 'CH', name: 'Switzerland', emoji: '🇨🇭'),
  Country(code: 'TW', name: 'Taiwan', emoji: '🇹🇼'),
  Country(code: 'TH', name: 'Thailand', emoji: '🇹🇭'),
  Country(code: 'TR', name: 'Turkey', emoji: '🇹🇷'),
  Country(code: 'AE', name: 'United Arab Emirates', emoji: '🇦🇪'),
  Country(code: 'GB', name: 'United Kingdom', emoji: '🇬🇧'),
  Country(code: 'US', name: 'United States', emoji: '🇺🇸'),
  Country(code: 'VN', name: 'Vietnam', emoji: '🇻🇳'),
];

/// Find a country by its code
Country? getCountryByCode(String? code) {
  if (code == null || code.isEmpty) return null;
  final upperCode = code.toUpperCase();
  try {
    return countries.firstWhere((c) => c.code == upperCode);
  } catch (e) {
    return null;
  }
}

/// Find countries matching a search query
List<Country> searchCountries(String query) {
  if (query.isEmpty) return countries;
  final lowerQuery = query.toLowerCase();
  return countries.where((c) =>
    c.name.toLowerCase().contains(lowerQuery) ||
    c.code.toLowerCase().contains(lowerQuery)
  ).toList();
}
