"use client";

import { useState, useEffect, useRef, useCallback } from "react";
import { Check, Loader2, Plane, Building2, MapPin, Search } from "lucide-react";

import { Button } from "@/components/ui/button";
import {
    Command,
    CommandEmpty,
    CommandGroup,
    CommandInput,
    CommandItem,
    CommandList,
} from "@/components/ui/command";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";
import { cn } from "@/lib/utils";
import { useDebounce } from "@/lib/useDebounce";
import {
    searchPlaces,
    searchAirportsAndCities,
    getPlaceDetails,
    isAirportPrediction,
    isCityPrediction,
    isHotelPrediction,
    type PlacePrediction,
    type NormalizedPlace,
    type PlaceType,
} from "@/lib/googlePlaces";

export interface PlaceAutocompleteInputProps {
    /** Display label */
    label?: string;
    /** Placeholder text */
    placeholder?: string;
    /** Current value to display */
    value?: string;
    /** Type of places to search for */
    variant?: PlaceType | "airportCity";
    /** Callback when a place is selected */
    onSelect?: (place: NormalizedPlace) => void;
    /** Callback when value changes (for controlled input) */
    onChange?: (value: string) => void;
    /** Whether the input is disabled */
    disabled?: boolean;
    /** Additional className for the trigger button */
    className?: string;
    /** ID for the input element */
    id?: string;
}

/**
 * Place Autocomplete Input Component
 *
 * A reusable autocomplete input that uses Google Places API to search for
 * cities, airports, addresses, hotels, or establishments.
 */
export function PlaceAutocompleteInput({
    label,
    placeholder = "Search for a place...",
    value = "",
    variant = "city",
    onSelect,
    onChange,
    disabled = false,
    className,
    id,
}: PlaceAutocompleteInputProps) {
    const [open, setOpen] = useState(false);
    const [inputValue, setInputValue] = useState(value);
    const [predictions, setPredictions] = useState<PlacePrediction[]>([]);
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const abortControllerRef = useRef<AbortController | null>(null);

    const debouncedInput = useDebounce(inputValue, 300);

    // Update input value when prop value changes
    useEffect(() => {
        setInputValue(value);
    }, [value]);

    // Search for predictions when debounced input changes
    useEffect(() => {
        async function fetchPredictions() {
            if (!debouncedInput || debouncedInput.length < 2) {
                setPredictions([]);
                setError(null);
                return;
            }

            // Cancel previous request
            if (abortControllerRef.current) {
                abortControllerRef.current.abort();
            }
            abortControllerRef.current = new AbortController();

            setIsLoading(true);
            setError(null);

            try {
                let results: PlacePrediction[];

                if (variant === "airportCity") {
                    results = await searchAirportsAndCities(
                        debouncedInput,
                        abortControllerRef.current.signal
                    );
                } else {
                    results = await searchPlaces(
                        debouncedInput,
                        variant,
                        abortControllerRef.current.signal
                    );
                }

                setPredictions(results);
            } catch (err) {
                if (err instanceof Error && err.name !== "AbortError") {
                    console.error("Place search error:", err);
                    setError("Unable to search places. You can type manually.");
                }
            } finally {
                setIsLoading(false);
            }
        }

        fetchPredictions();
    }, [debouncedInput, variant]);

    // Handle place selection
    const handleSelect = useCallback(
        async (prediction: PlacePrediction) => {
            setInputValue(prediction.mainText);
            onChange?.(prediction.mainText);
            setOpen(false);

            // Fetch full place details
            const details = await getPlaceDetails(prediction.placeId);
            if (details) {
                onSelect?.(details);
            } else {
                // Fallback: create partial normalized place from prediction
                const fallbackPlace: NormalizedPlace = {
                    placeId: prediction.placeId,
                    name: prediction.mainText,
                    formattedAddress: prediction.description,
                    city: isCityPrediction(prediction) ? prediction.mainText : "",
                    country: "",
                    countryCode: "",
                    types: prediction.types,
                };
                onSelect?.(fallbackPlace);
            }
        },
        [onChange, onSelect]
    );

    // Handle manual input change
    const handleInputChange = (newValue: string) => {
        setInputValue(newValue);
        onChange?.(newValue);
    };

    // Get icon for prediction type
    const getIcon = (prediction: PlacePrediction) => {
        if (isAirportPrediction(prediction)) {
            return <Plane className="mr-2 h-4 w-4 text-blue-500" />;
        }
        if (isHotelPrediction(prediction)) {
            return <Building2 className="mr-2 h-4 w-4 text-purple-500" />;
        }
        if (isCityPrediction(prediction)) {
            return <MapPin className="mr-2 h-4 w-4 text-green-500" />;
        }
        return <MapPin className="mr-2 h-4 w-4 text-muted-foreground" />;
    };

    return (
        <Popover open={open} onOpenChange={setOpen}>
            <PopoverTrigger asChild>
                <Button
                    id={id}
                    variant="outline"
                    role="combobox"
                    aria-expanded={open}
                    aria-label={label || placeholder}
                    disabled={disabled}
                    className={cn(
                        "w-full justify-between font-normal",
                        !inputValue && "text-muted-foreground",
                        className
                    )}
                >
                    <span className="truncate">
                        {inputValue || placeholder}
                    </span>
                    <Search className="ml-2 h-4 w-4 shrink-0 opacity-50" />
                </Button>
            </PopoverTrigger>
            <PopoverContent className="w-full p-0" align="start">
                <Command shouldFilter={false}>
                    <CommandInput
                        placeholder={placeholder}
                        value={inputValue}
                        onValueChange={handleInputChange}
                    />
                    <CommandList>
                        {isLoading && (
                            <div className="flex items-center justify-center py-6">
                                <Loader2 className="h-4 w-4 animate-spin text-muted-foreground" />
                                <span className="ml-2 text-sm text-muted-foreground">
                                    Searching...
                                </span>
                            </div>
                        )}

                        {error && (
                            <div className="py-6 text-center text-sm text-destructive">
                                {error}
                            </div>
                        )}

                        {!isLoading && !error && predictions.length === 0 && inputValue.length >= 2 && (
                            <CommandEmpty>
                                No places found. You can type a custom value.
                            </CommandEmpty>
                        )}

                        {!isLoading && predictions.length > 0 && (
                            <CommandGroup>
                                {predictions.map((prediction) => (
                                    <CommandItem
                                        key={prediction.placeId}
                                        value={prediction.placeId}
                                        onSelect={() => handleSelect(prediction)}
                                        className="cursor-pointer"
                                    >
                                        {getIcon(prediction)}
                                        <div className="flex flex-col">
                                            <span className="font-medium">
                                                {prediction.mainText}
                                            </span>
                                            {prediction.secondaryText && (
                                                <span className="text-xs text-muted-foreground">
                                                    {prediction.secondaryText}
                                                </span>
                                            )}
                                        </div>
                                        {inputValue === prediction.mainText && (
                                            <Check className="ml-auto h-4 w-4" />
                                        )}
                                    </CommandItem>
                                ))}
                            </CommandGroup>
                        )}
                    </CommandList>
                </Command>
            </PopoverContent>
        </Popover>
    );
}
