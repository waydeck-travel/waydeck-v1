"use client";

import { useCallback } from "react";
import { PlaceAutocompleteInput, type PlaceAutocompleteInputProps } from "./PlaceAutocompleteInput";
import type { NormalizedPlace } from "@/lib/googlePlaces";

export interface AddressInputProps extends Omit<PlaceAutocompleteInputProps, "variant" | "onSelect"> {
    /** Callback when an address is selected */
    onAddressSelect?: (data: {
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
 * Address Input Component
 *
 * A specialized autocomplete input for selecting street addresses.
 * Used for car/bike pickup and dropoff locations.
 */
export function AddressInput({
    placeholder = "Search for an address...",
    onAddressSelect,
    ...props
}: AddressInputProps) {
    const handleSelect = useCallback(
        (place: NormalizedPlace) => {
            onAddressSelect?.({
                address: place.formattedAddress || place.name,
                city: place.city,
                country: place.country,
                countryCode: place.countryCode,
                placeId: place.placeId,
                lat: place.lat,
                lng: place.lng,
            });
        },
        [onAddressSelect]
    );

    return (
        <PlaceAutocompleteInput
            {...props}
            placeholder={placeholder}
            variant="address"
            onSelect={handleSelect}
        />
    );
}
