"use client";

import { useCallback } from "react";
import { PlaceAutocompleteInput, type PlaceAutocompleteInputProps } from "./PlaceAutocompleteInput";
import type { NormalizedPlace } from "@/lib/googlePlaces";

export interface HotelInputProps extends Omit<PlaceAutocompleteInputProps, "variant" | "onSelect"> {
    /** Callback when a hotel is selected */
    onHotelSelect?: (data: {
        name: string;
        address: string;
        city: string;
        country: string;
        countryCode: string;
        placeId: string;
        lat?: number;
        lng?: number;
    }) => void;
}

/**
 * Hotel Input Component
 *
 * A specialized autocomplete input for selecting hotels and lodging.
 * Auto-fills hotel name, address, city, and country on selection.
 */
export function HotelInput({
    placeholder = "Search for a hotel...",
    onHotelSelect,
    ...props
}: HotelInputProps) {
    const handleSelect = useCallback(
        (place: NormalizedPlace) => {
            onHotelSelect?.({
                name: place.name,
                address: place.formattedAddress,
                city: place.city,
                country: place.country,
                countryCode: place.countryCode,
                placeId: place.placeId,
                lat: place.lat,
                lng: place.lng,
            });
        },
        [onHotelSelect]
    );

    return (
        <PlaceAutocompleteInput
            {...props}
            placeholder={placeholder}
            variant="hotel"
            onSelect={handleSelect}
        />
    );
}
