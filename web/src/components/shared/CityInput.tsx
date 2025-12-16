"use client";

import { useCallback } from "react";
import { PlaceAutocompleteInput, type PlaceAutocompleteInputProps } from "./PlaceAutocompleteInput";
import type { NormalizedPlace } from "@/lib/googlePlaces";

export interface CityInputProps extends Omit<PlaceAutocompleteInputProps, "variant" | "onSelect"> {
    /** Callback when a city is selected, provides city and country info */
    onCitySelect?: (data: {
        city: string;
        country: string;
        countryCode: string;
        placeId: string;
    }) => void;
}

/**
 * City Input Component
 *
 * A specialized autocomplete input for selecting cities.
 * Auto-fills city and country information on selection.
 */
export function CityInput({
    placeholder = "Search for a city...",
    onCitySelect,
    ...props
}: CityInputProps) {
    const handleSelect = useCallback(
        (place: NormalizedPlace) => {
            onCitySelect?.({
                city: place.city || place.name,
                country: place.country,
                countryCode: place.countryCode,
                placeId: place.placeId,
            });
        },
        [onCitySelect]
    );

    return (
        <PlaceAutocompleteInput
            {...props}
            placeholder={placeholder}
            variant="city"
            onSelect={handleSelect}
        />
    );
}
