"use client";

import { useState, useMemo } from "react";
import { Check, ChevronsUpDown } from "lucide-react";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import {
    Command,
    CommandEmpty,
    CommandGroup,
    CommandInput,
    CommandItem,
    CommandList,
} from "@/components/ui/command";
import {
    Popover,
    PopoverContent,
    PopoverTrigger,
} from "@/components/ui/popover";
import { AIRLINES, Airline } from "@/data/airlines";

interface AirlineAutocompleteProps {
    value?: string;
    onSelect: (airline: Airline | null) => void;
    className?: string;
}

export function AirlineAutocomplete({ value, onSelect, className }: AirlineAutocompleteProps) {
    const [open, setOpen] = useState(false);
    // Remove state for `value` since it's controlled by parent

    // Helper to find airline by IATA code
    const selectedAirline = useMemo(() =>
        AIRLINES.find((a) => a.iataCode === value),
        [value]);

    return (
        <Popover open={open} onOpenChange={setOpen}>
            <PopoverTrigger asChild>
                <Button
                    variant="outline"
                    role="combobox"
                    aria-expanded={open}
                    className={cn("w-full justify-between", className)}
                >
                    {selectedAirline ? (
                        <span className="truncate">
                            {selectedAirline.name} ({selectedAirline.iataCode})
                        </span>
                    ) : (
                        <span className="text-muted-foreground">Select airline...</span>
                    )}
                    <ChevronsUpDown className="ml-2 h-4 w-4 shrink-0 opacity-50" />
                </Button>
            </PopoverTrigger>
            <PopoverContent className="w-[300px] p-0" align="start">
                <Command>
                    <CommandInput placeholder="Search airline name or code..." />
                    <CommandList>
                        <CommandEmpty>No airline found.</CommandEmpty>
                        <CommandGroup>
                            {AIRLINES.map((airline) => (
                                <CommandItem
                                    key={airline.iataCode}
                                    value={`${airline.name} ${airline.iataCode}`} // Search against this string
                                    onSelect={() => {
                                        onSelect(airline);
                                        setOpen(false);
                                    }}
                                >
                                    <Check
                                        className={cn(
                                            "mr-2 h-4 w-4",
                                            value === airline.iataCode ? "opacity-100" : "opacity-0"
                                        )}
                                    />
                                    <div className="flex flex-col">
                                        <span>{airline.name}</span>
                                        <span className="text-xs text-muted-foreground">
                                            {airline.iataCode} • {airline.country}
                                        </span>
                                    </div>
                                </CommandItem>
                            ))}
                        </CommandGroup>
                    </CommandList>
                </Command>
            </PopoverContent>
        </Popover>
    );
}
