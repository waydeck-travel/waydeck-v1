export interface Airline {
    iataCode: string;
    icaoCode: string;
    name: string;
    country?: string;
}

export const AIRLINES: Airline[] = [
    // India
    { iataCode: '6E', icaoCode: 'IGO', name: 'IndiGo', country: 'India' },
    { iataCode: 'AI', icaoCode: 'AIC', name: 'Air India', country: 'India' },
    { iataCode: 'UK', icaoCode: 'VTI', name: 'Vistara', country: 'India' },
    { iataCode: 'SG', icaoCode: 'SEJ', name: 'SpiceJet', country: 'India' },
    { iataCode: 'G8', icaoCode: 'GOW', name: 'Go First', country: 'India' },
    { iataCode: 'IX', icaoCode: 'AXB', name: 'Air India Express', country: 'India' },
    { iataCode: 'QP', icaoCode: 'AKJ', name: 'Akasa Air', country: 'India' },

    // Middle East
    { iataCode: 'EK', icaoCode: 'UAE', name: 'Emirates', country: 'UAE' },
    { iataCode: 'QR', icaoCode: 'QTR', name: 'Qatar Airways', country: 'Qatar' },
    { iataCode: 'EY', icaoCode: 'ETD', name: 'Etihad Airways', country: 'UAE' },
    { iataCode: 'WY', icaoCode: 'OMA', name: 'Oman Air', country: 'Oman' },
    { iataCode: 'GF', icaoCode: 'GFA', name: 'Gulf Air', country: 'Bahrain' },
    { iataCode: 'SV', icaoCode: 'SVA', name: 'Saudia', country: 'Saudi Arabia' },
    { iataCode: 'FZ', icaoCode: 'FDB', name: 'flydubai', country: 'UAE' },

    // Asia
    { iataCode: 'SQ', icaoCode: 'SIA', name: 'Singapore Airlines', country: 'Singapore' },
    { iataCode: 'CX', icaoCode: 'CPA', name: 'Cathay Pacific', country: 'Hong Kong' },
    { iataCode: 'TG', icaoCode: 'THA', name: 'Thai Airways', country: 'Thailand' },
    { iataCode: 'MH', icaoCode: 'MAS', name: 'Malaysia Airlines', country: 'Malaysia' },
    { iataCode: 'AK', icaoCode: 'AXM', name: 'AirAsia', country: 'Malaysia' },
    { iataCode: 'GA', icaoCode: 'GIA', name: 'Garuda Indonesia', country: 'Indonesia' },
    { iataCode: 'VN', icaoCode: 'HVN', name: 'Vietnam Airlines', country: 'Vietnam' },
    { iataCode: 'KE', icaoCode: 'KAL', name: 'Korean Air', country: 'South Korea' },
    { iataCode: 'OZ', icaoCode: 'AAR', name: 'Asiana Airlines', country: 'South Korea' },
    { iataCode: 'JL', icaoCode: 'JAL', name: 'Japan Airlines', country: 'Japan' },
    { iataCode: 'NH', icaoCode: 'ANA', name: 'All Nippon Airways', country: 'Japan' },
    { iataCode: 'CA', icaoCode: 'CCA', name: 'Air China', country: 'China' },
    { iataCode: 'MU', icaoCode: 'CES', name: 'China Eastern', country: 'China' },
    { iataCode: 'CZ', icaoCode: 'CSN', name: 'China Southern', country: 'China' },
    { iataCode: 'CI', icaoCode: 'CAL', name: 'China Airlines', country: 'Taiwan' },
    { iataCode: 'BR', icaoCode: 'EVA', name: 'EVA Air', country: 'Taiwan' },
    { iataCode: 'PR', icaoCode: 'PAL', name: 'Philippine Airlines', country: 'Philippines' },
    { iataCode: '5J', icaoCode: 'CEB', name: 'Cebu Pacific', country: 'Philippines' },
    { iataCode: 'UL', icaoCode: 'ALK', name: 'SriLankan Airlines', country: 'Sri Lanka' },
    { iataCode: 'BG', icaoCode: 'BBC', name: 'Biman Bangladesh', country: 'Bangladesh' },
    { iataCode: 'RA', icaoCode: 'RNA', name: 'Nepal Airlines', country: 'Nepal' },
    { iataCode: 'PK', icaoCode: 'PIA', name: 'Pakistan International', country: 'Pakistan' },

    // Europe
    { iataCode: 'LH', icaoCode: 'DLH', name: 'Lufthansa', country: 'Germany' },
    { iataCode: 'BA', icaoCode: 'BAW', name: 'British Airways', country: 'UK' },
    { iataCode: 'AF', icaoCode: 'AFR', name: 'Air France', country: 'France' },
    { iataCode: 'KL', icaoCode: 'KLM', name: 'KLM Royal Dutch', country: 'Netherlands' },
    { iataCode: 'IB', icaoCode: 'IBE', name: 'Iberia', country: 'Spain' },
    { iataCode: 'AZ', icaoCode: 'ITY', name: 'ITA Airways', country: 'Italy' },
    { iataCode: 'LX', icaoCode: 'SWR', name: 'Swiss International', country: 'Switzerland' },
    { iataCode: 'OS', icaoCode: 'AUA', name: 'Austrian Airlines', country: 'Austria' },
    { iataCode: 'SK', icaoCode: 'SAS', name: 'Scandinavian Airlines', country: 'Sweden' },
    { iataCode: 'AY', icaoCode: 'FIN', name: 'Finnair', country: 'Finland' },
    { iataCode: 'TP', icaoCode: 'TAP', name: 'TAP Air Portugal', country: 'Portugal' },
    { iataCode: 'TK', icaoCode: 'THY', name: 'Turkish Airlines', country: 'Turkey' },
    { iataCode: 'SU', icaoCode: 'AFL', name: 'Aeroflot', country: 'Russia' },
    { iataCode: 'LO', icaoCode: 'LOT', name: 'LOT Polish Airlines', country: 'Poland' },
    { iataCode: 'FR', icaoCode: 'RYR', name: 'Ryanair', country: 'Ireland' },
    { iataCode: 'U2', icaoCode: 'EZY', name: 'easyJet', country: 'UK' },
    { iataCode: 'W6', icaoCode: 'WZZ', name: 'Wizz Air', country: 'Hungary' },
    { iataCode: 'VY', icaoCode: 'VLG', name: 'Vueling', country: 'Spain' },
    { iataCode: 'EW', icaoCode: 'EWG', name: 'Eurowings', country: 'Germany' },

    // Americas
    { iataCode: 'AA', icaoCode: 'AAL', name: 'American Airlines', country: 'USA' },
    { iataCode: 'UA', icaoCode: 'UAL', name: 'United Airlines', country: 'USA' },
    { iataCode: 'DL', icaoCode: 'DAL', name: 'Delta Air Lines', country: 'USA' },
    { iataCode: 'WN', icaoCode: 'SWA', name: 'Southwest Airlines', country: 'USA' },
    { iataCode: 'B6', icaoCode: 'JBU', name: 'JetBlue Airways', country: 'USA' },
    { iataCode: 'AS', icaoCode: 'ASA', name: 'Alaska Airlines', country: 'USA' },
    { iataCode: 'AC', icaoCode: 'ACA', name: 'Air Canada', country: 'Canada' },
    { iataCode: 'WS', icaoCode: 'WJA', name: 'WestJet', country: 'Canada' },
    { iataCode: 'AM', icaoCode: 'AMX', name: 'Aeromexico', country: 'Mexico' },
    { iataCode: 'LA', icaoCode: 'LAN', name: 'LATAM Airlines', country: 'Chile' },
    { iataCode: 'G3', icaoCode: 'GLO', name: 'Gol Airlines', country: 'Brazil' },
    { iataCode: 'AV', icaoCode: 'AVA', name: 'Avianca', country: 'Colombia' },
    { iataCode: 'CM', icaoCode: 'CMP', name: 'Copa Airlines', country: 'Panama' },

    // Africa & Oceania
    { iataCode: 'ET', icaoCode: 'ETH', name: 'Ethiopian Airlines', country: 'Ethiopia' },
    { iataCode: 'SA', icaoCode: 'SAA', name: 'South African Airways', country: 'South Africa' },
    { iataCode: 'MS', icaoCode: 'MSR', name: 'EgyptAir', country: 'Egypt' },
    { iataCode: 'AT', icaoCode: 'RAM', name: 'Royal Air Maroc', country: 'Morocco' },
    { iataCode: 'KQ', icaoCode: 'KQA', name: 'Kenya Airways', country: 'Kenya' },
    { iataCode: 'RW', icaoCode: 'RWD', name: 'RwandAir', country: 'Rwanda' },
    { iataCode: 'QF', icaoCode: 'QFA', name: 'Qantas', country: 'Australia' },
    { iataCode: 'NZ', icaoCode: 'ANZ', name: 'Air New Zealand', country: 'New Zealand' },
    { iataCode: 'FJ', icaoCode: 'FJI', name: 'Fiji Airways', country: 'Fiji' },
    { iataCode: 'JQ', icaoCode: 'JST', name: 'Jetstar', country: 'Australia' },
    { iataCode: 'VA', icaoCode: 'VOZ', name: 'Virgin Australia', country: 'Australia' },
];

export function searchAirlines(query: string): Airline[] {
    if (!query) return [];
    const lowerQuery = query.toLowerCase();
    return AIRLINES.filter(airline =>
        airline.name.toLowerCase().includes(lowerQuery) ||
        airline.iataCode.toLowerCase().includes(lowerQuery) ||
        airline.icaoCode.toLowerCase().includes(lowerQuery)
    ).slice(0, 10);
}
