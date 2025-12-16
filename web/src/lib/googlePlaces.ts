/**
 * Google Places API integration for Waydeck Web
 *
 * This module provides utility functions for searching places using Google Places API.
 * Uses client-side Google Maps JavaScript API for autocomplete and place details.
 */

// Types
export interface NormalizedPlace {
    placeId: string;
    name: string;
    formattedAddress: string;
    city: string;
    country: string;
    countryCode: string;
    airportCode?: string;
    lat?: number;
    lng?: number;
    types: string[];
}

export interface PlacePrediction {
    placeId: string;
    mainText: string;
    secondaryText: string;
    description: string;
    types: string[];
}

export type PlaceType = "city" | "address" | "airport" | "hotel" | "establishment";

// Simple in-memory cache for recent queries
const queryCache = new Map<string, { data: PlacePrediction[]; timestamp: number }>();
const CACHE_TTL_MS = 5 * 60 * 1000; // 5 minutes

// IATA airport codes mapping (common airports)
const AIRPORT_CODES: Record<string, string> = {
    // India
    "chhatrapati shivaji maharaj international airport": "BOM",
    "indira gandhi international airport": "DEL",
    "kempegowda international airport": "BLR",
    "rajiv gandhi international airport": "HYD",
    "chennai international airport": "MAA",
    "netaji subhas chandra bose international airport": "CCU",
    "pune airport": "PNQ",
    "sardar vallabhbhai patel international airport": "AMD",
    "cochin international airport": "COK",
    "goa international airport": "GOI",
    "dabolim airport": "GOI",
    "manohar international airport": "GOX",
    // Southeast Asia
    "suvarnabhumi airport": "BKK",
    "don mueang international airport": "DMK",
    "changi airport": "SIN",
    "kuala lumpur international airport": "KUL",
    "tan son nhat international airport": "SGN",
    "noi bai international airport": "HAN",
    "da nang international airport": "DAD",
    "nguyen thue cong": "DAD",
    "phu quoc international airport": "PQC",
    "ninoy aquino international airport": "MNL",
    "soekarno-hatta international airport": "CGK",
    "ngurah rai international airport": "DPS",
    // Middle East
    "dubai international airport": "DXB",
    "abu dhabi international airport": "AUH",
    "hamad international airport": "DOH",
    // Europe
    "heathrow airport": "LHR",
    "gatwick airport": "LGW",
    "paris charles de gaulle airport": "CDG",
    "amsterdam airport schiphol": "AMS",
    "frankfurt airport": "FRA",
    // Americas
    "john f. kennedy international airport": "JFK",
    "los angeles international airport": "LAX",
    "san francisco international airport": "SFO",
    "o'hare international airport": "ORD",
    "toronto pearson international airport": "YYZ",
    // Australia
    "sydney airport": "SYD",
    "melbourne airport": "MEL",
};

/**
 * Match airport name to IATA code
 */
export function matchAirportCode(airportName: string): string | undefined {
    const normalized = airportName.toLowerCase().trim();

    // Empty string should not match anything
    if (!normalized) {
        return undefined;
    }

    // Direct lookup
    if (AIRPORT_CODES[normalized]) {
        return AIRPORT_CODES[normalized];
    }

    // Partial match - only if normalized has meaningful content
    for (const [name, code] of Object.entries(AIRPORT_CODES)) {
        if (normalized.includes(name) || name.includes(normalized)) {
            return code;
        }
    }

    return undefined;
}

/**
 * Check if Google Places API is available
 */
function isGooglePlacesAvailable(): boolean {
    return (
        typeof window !== "undefined" &&
        typeof google !== "undefined" &&
        typeof google.maps !== "undefined" &&
        typeof google.maps.places !== "undefined"
    );
}

/**
 * Get cached results if valid
 */
function getCachedResults(cacheKey: string): PlacePrediction[] | null {
    const cached = queryCache.get(cacheKey);
    if (cached && Date.now() - cached.timestamp < CACHE_TTL_MS) {
        return cached.data;
    }
    queryCache.delete(cacheKey);
    return null;
}

/**
 * Cache query results
 */
function cacheResults(cacheKey: string, data: PlacePrediction[]): void {
    queryCache.set(cacheKey, { data, timestamp: Date.now() });

    // Limit cache size
    if (queryCache.size > 100) {
        const oldestKey = queryCache.keys().next().value;
        if (oldestKey) queryCache.delete(oldestKey);
    }
}



/**
 * Build the types parameter for Google Places API based on PlaceType
 */
function getGoogleTypesForPlaceType(placeType: PlaceType): string[] {
    switch (placeType) {
        case "city":
            return ["(cities)"];
        case "address":
            return ["address"];
        case "airport":
            return ["airport"];
        case "hotel":
            return ["lodging"];
        case "establishment":
        default:
            return ["establishment"];
    }
}

/**
 * Search for places using Google Places Autocomplete
 * @param input - Search query (min 2 characters)
 * @param placeType - Type of place to search for
 * @param signal - Optional AbortSignal for cancellation
 */
export async function searchPlaces(
    input: string,
    placeType: PlaceType = "city",
    signal?: AbortSignal
): Promise<PlacePrediction[]> {
    // Minimum character requirement
    if (!input || input.trim().length < 2) {
        return [];
    }

    const cacheKey = `${placeType}:${input.toLowerCase().trim()}`;

    // Check cache first
    const cached = getCachedResults(cacheKey);
    if (cached) {
        return cached;
    }

    // Check if Google Places is available
    if (!isGooglePlacesAvailable()) {
        console.warn("Google Places API not loaded");
        return [];
    }

    // Create autocomplete service
    const service = new google.maps.places.AutocompleteService();
    const types = getGoogleTypesForPlaceType(placeType);

    return new Promise((resolve) => {
        // Check if aborted before making request
        if (signal?.aborted) {
            resolve([]);
            return;
        }

        const request: google.maps.places.AutocompletionRequest = {
            input: input.trim(),
            types: types,
        };

        service.getPlacePredictions(request, (predictions, status) => {
            if (signal?.aborted) {
                resolve([]);
                return;
            }

            if (
                status !== google.maps.places.PlacesServiceStatus.OK ||
                !predictions
            ) {
                if (status !== google.maps.places.PlacesServiceStatus.ZERO_RESULTS) {
                    console.warn("Places API error:", status);
                }
                resolve([]);
                return;
            }

            const results: PlacePrediction[] = predictions.map((p) => ({
                placeId: p.place_id,
                mainText: p.structured_formatting.main_text,
                secondaryText: p.structured_formatting.secondary_text || "",
                description: p.description,
                types: p.types || [],
            }));

            cacheResults(cacheKey, results);
            resolve(results);
        });
    });
}

/**
 * Convenience function to search for cities only
 */
export async function searchCities(
    input: string,
    signal?: AbortSignal
): Promise<PlacePrediction[]> {
    return searchPlaces(input, "city", signal);
}

/**
 * Convenience function to search for airports
 */
export async function searchAirports(
    input: string,
    signal?: AbortSignal
): Promise<PlacePrediction[]> {
    return searchPlaces(input, "airport", signal);
}

/**
 * Convenience function to search for addresses
 */
export async function searchAddresses(
    input: string,
    signal?: AbortSignal
): Promise<PlacePrediction[]> {
    return searchPlaces(input, "address", signal);
}

/**
 * Convenience function to search for hotels/lodging
 */
export async function searchHotels(
    input: string,
    signal?: AbortSignal
): Promise<PlacePrediction[]> {
    return searchPlaces(input, "hotel", signal);
}

/**
 * Search for both airports and cities (for transport origin/destination)
 */
export async function searchAirportsAndCities(
    input: string,
    signal?: AbortSignal
): Promise<PlacePrediction[]> {
    if (!input || input.trim().length < 2) {
        return [];
    }

    const [airports, cities] = await Promise.all([
        searchAirports(input, signal),
        searchCities(input, signal),
    ]);

    // Merge and dedupe by placeId, airports first
    const seen = new Set<string>();
    const results: PlacePrediction[] = [];

    for (const prediction of [...airports, ...cities]) {
        if (!seen.has(prediction.placeId)) {
            seen.add(prediction.placeId);
            results.push(prediction);
        }
    }

    return results.slice(0, 8); // Limit to 8 results
}

/**
 * Get detailed place information
 * @param placeId - Google Place ID
 */
export async function getPlaceDetails(placeId: string): Promise<NormalizedPlace | null> {
    if (!placeId || !isGooglePlacesAvailable()) {
        return null;
    }

    return new Promise((resolve) => {
        // Need a DOM element for PlacesService
        const div = document.createElement("div");
        const service = new google.maps.places.PlacesService(div);

        const request: google.maps.places.PlaceDetailsRequest = {
            placeId,
            fields: [
                "place_id",
                "name",
                "formatted_address",
                "address_components",
                "geometry",
                "types",
            ],
        };

        service.getDetails(request, (place, status) => {
            if (status !== google.maps.places.PlacesServiceStatus.OK || !place) {
                console.warn("Place details error:", status);
                resolve(null);
                return;
            }

            // Extract city and country from address_components
            let city = "";
            let country = "";
            let countryCode = "";

            if (place.address_components) {
                for (const component of place.address_components) {
                    const types = component.types;

                    if (types.includes("locality")) {
                        city = component.long_name;
                    } else if (
                        types.includes("administrative_area_level_1") &&
                        !city
                    ) {
                        // Fallback to state/region if no city
                        city = component.long_name;
                    } else if (types.includes("country")) {
                        country = component.long_name;
                        countryCode = component.short_name;
                    }
                }
            }

            // Check if it's an airport and try to get IATA code
            const isAirport = place.types?.includes("airport");
            const airportCode = isAirport
                ? matchAirportCode(place.name || "")
                : undefined;

            const normalized: NormalizedPlace = {
                placeId: place.place_id || placeId,
                name: place.name || "",
                formattedAddress: place.formatted_address || "",
                city,
                country,
                countryCode,
                airportCode,
                lat: place.geometry?.location?.lat(),
                lng: place.geometry?.location?.lng(),
                types: place.types || [],
            };

            resolve(normalized);
        });
    });
}

/**
 * Check if a prediction is an airport
 */
export function isAirportPrediction(prediction: PlacePrediction): boolean {
    return prediction.types.includes("airport");
}

/**
 * Check if a prediction is a city
 */
export function isCityPrediction(prediction: PlacePrediction): boolean {
    return (
        prediction.types.includes("locality") ||
        prediction.types.includes("administrative_area_level_1") ||
        prediction.types.includes("administrative_area_level_2")
    );
}

/**
 * Check if a prediction is a hotel/lodging
 */
export function isHotelPrediction(prediction: PlacePrediction): boolean {
    return prediction.types.includes("lodging");
}
