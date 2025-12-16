/// <reference types="google.maps" />

// Type declarations for Google Maps Places API
// These are used by the PlaceAutocompleteInput component

declare namespace google.maps {
    namespace places {
        interface AutocompletePrediction {
            place_id: string;
            description: string;
            structured_formatting: {
                main_text: string;
                secondary_text?: string;
            };
            types: string[];
        }

        interface AutocompletionRequest {
            input: string;
            types?: string[];
        }

        interface PlaceDetailsRequest {
            placeId: string;
            fields: string[];
        }

        interface PlaceResult {
            place_id?: string;
            name?: string;
            formatted_address?: string;
            address_components?: {
                long_name: string;
                short_name: string;
                types: string[];
            }[];
            geometry?: {
                location?: {
                    lat(): number;
                    lng(): number;
                };
            };
            types?: string[];
        }

        enum PlacesServiceStatus {
            OK = "OK",
            ZERO_RESULTS = "ZERO_RESULTS",
            OVER_QUERY_LIMIT = "OVER_QUERY_LIMIT",
            REQUEST_DENIED = "REQUEST_DENIED",
            INVALID_REQUEST = "INVALID_REQUEST",
            UNKNOWN_ERROR = "UNKNOWN_ERROR",
            NOT_FOUND = "NOT_FOUND",
        }

        class AutocompleteService {
            getPlacePredictions(
                request: AutocompletionRequest,
                callback: (
                    predictions: AutocompletePrediction[] | null,
                    status: PlacesServiceStatus
                ) => void
            ): void;
        }

        class PlacesService {
            constructor(attributionNode: HTMLDivElement);
            getDetails(
                request: PlaceDetailsRequest,
                callback: (
                    result: PlaceResult | null,
                    status: PlacesServiceStatus
                ) => void
            ): void;
        }
    }
}
