"use client";

import { useCallback } from "react";
import { PlaceAutocompleteInput, type PlaceAutocompleteInputProps } from "./PlaceAutocompleteInput";
import type { NormalizedPlace } from "@/lib/googlePlaces";

export interface AirportCityInputProps extends Omit<PlaceAutocompleteInputProps, "variant" | "onSelect"> {
    /** Callback when an airport or city is selected */
    onLocationSelect?: (data: {
        city: string;
        country: string;
        countryCode: string;
        airportCode?: string;
        placeId: string;
        isAirport: boolean;
    }) => void;
}

/**
 * Airport/City Input Component
 *
 * A specialized autocomplete input for selecting airports or cities.
 * Used for transport origin/destination (flights, trains, buses).
 * Auto-populates city, country, and airport code when available.
 */
export function AirportCityInput({
    placeholder = "Search airport or city...",
    onLocationSelect,
    ...props
}: AirportCityInputProps) {
    const handleSelect = useCallback(
        (place: NormalizedPlace) => {
            const isAirport = place.types.includes("airport");

            onLocationSelect?.({
                city: place.city || (isAirport ? "" : place.name),
                country: place.country,
                countryCode: place.countryCode,
                airportCode: place.airportCode,
                placeId: place.placeId,
                isAirport,
            });
        },
        [onLocationSelect]
    );

    return (
        <PlaceAutocompleteInput
            {...props}
            placeholder={placeholder}
            variant="airportCity"
            onSelect={handleSelect}
        />
    );
}
