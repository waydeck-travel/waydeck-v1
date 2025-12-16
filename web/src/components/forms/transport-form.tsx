"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { format } from "date-fns";
import {
    CalendarIcon,
    Loader2,
    ArrowLeft,
    Plane,
    Train,
    Bus,
    Car,
    Bike,
    Ship,
    TrainFront,
    Sailboat,
    CarTaxiFront,
} from "lucide-react";
import Link from "next/link";

import { Button } from "@/components/ui/button";
import {
    Form,
    FormControl,
    FormField,
    FormItem,
    FormLabel,
    FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Calendar } from "@/components/ui/calendar";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";
import { cn } from "@/lib/utils";
import { AirportCityInput } from "@/components/shared";
import { AirlineAutocomplete } from "@/components/forms/airline-autocomplete";
import { createTransportItem } from "@/actions/item-create";
import { toast } from "sonner";

const transportModes = [
    { id: "flight", label: "Flight", icon: Plane },
    { id: "train", label: "Train", icon: Train },
    { id: "bus", label: "Bus", icon: Bus },
    { id: "car", label: "Car", icon: Car },
    { id: "bike", label: "Bike", icon: Bike },
    { id: "cruise", label: "Cruise", icon: Ship },
    { id: "metro", label: "Metro", icon: TrainFront },
    { id: "ferry", label: "Ferry", icon: Sailboat },
    { id: "other", label: "Other", icon: CarTaxiFront },
];

const transportFormSchema = z.object({
    mode: z.string().min(1, "Select a transport mode"),
    carrier_name: z.string().optional(),
    carrier_code: z.string().optional(),
    transport_number: z.string().optional(),
    booking_reference: z.string().optional(),
    origin_city: z.string().optional(),
    origin_country_code: z.string().optional(),
    origin_airport_code: z.string().optional(),
    origin_terminal: z.string().optional(),
    destination_city: z.string().optional(),
    destination_country_code: z.string().optional(),
    destination_airport_code: z.string().optional(),
    destination_terminal: z.string().optional(),
    departure_date: z.date().optional(),
    departure_time: z.string().optional(),
    arrival_date: z.date().optional(),
    arrival_time: z.string().optional(),
    passenger_count: z.union([z.number(), z.string().transform(v => v === "" ? undefined : Number(v))]).optional(),
    expense_amount: z.union([z.number(), z.string().transform(v => v === "" ? undefined : Number(v))]).optional(),
    expense_currency: z.string().optional(),
    notes: z.string().optional(),
});

type TransportFormValues = z.input<typeof transportFormSchema>;

interface TransportFormProps {
    tripId: string;
}

export function TransportForm({ tripId }: TransportFormProps) {
    const router = useRouter();
    const [isSubmitting, setIsSubmitting] = useState(false);

    const form = useForm<TransportFormValues>({
        resolver: zodResolver(transportFormSchema),
        defaultValues: {
            mode: "flight",
            expense_currency: "USD",
            passenger_count: 1,
        },
    });

    const selectedMode = form.watch("mode");

    async function onSubmit(data: TransportFormValues) {
        setIsSubmitting(true);

        // Combine date and time
        const departureLocal =
            data.departure_date && data.departure_time
                ? `${format(data.departure_date, "yyyy-MM-dd")}T${data.departure_time}:00`
                : data.departure_date
                    ? format(data.departure_date, "yyyy-MM-dd")
                    : undefined;

        const arrivalLocal =
            data.arrival_date && data.arrival_time
                ? `${format(data.arrival_date, "yyyy-MM-dd")}T${data.arrival_time}:00`
                : data.arrival_date
                    ? format(data.arrival_date, "yyyy-MM-dd")
                    : undefined;

        // Build title
        const modeLabel = transportModes.find((m) => m.id === data.mode)?.label || "Transport";
        const title =
            data.transport_number && data.carrier_code
                ? `${data.carrier_code} ${data.transport_number}`
                : data.destination_city
                    ? `${modeLabel} to ${data.destination_city}`
                    : modeLabel;

        const result = await createTransportItem({
            trip_id: tripId,
            title,
            description: data.notes,
            mode: data.mode,
            carrier_name: data.carrier_name,
            carrier_code: data.carrier_code,
            transport_number: data.transport_number,
            booking_reference: data.booking_reference,
            origin_city: data.origin_city,
            origin_country_code: data.origin_country_code,
            origin_airport_code: data.origin_airport_code,
            origin_terminal: data.origin_terminal,
            destination_city: data.destination_city,
            destination_country_code: data.destination_country_code,
            destination_airport_code: data.destination_airport_code,
            destination_terminal: data.destination_terminal,
            departure_local: departureLocal,
            arrival_local: arrivalLocal,
            passenger_count: typeof data.passenger_count === "string" ? Number(data.passenger_count) : data.passenger_count,
            expense_amount: typeof data.expense_amount === "string" ? Number(data.expense_amount) : data.expense_amount,
            expense_currency: data.expense_currency,
        });

        if (result) {
            toast.success("Transport added!");
            router.push(`/app/trips/${tripId}`);
        } else {
            toast.error("Failed to add transport");
            setIsSubmitting(false);
        }
    }

    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex items-center gap-4">
                <Button variant="ghost" size="icon" asChild>
                    <Link href={`/app/trips/${tripId}`}>
                        <ArrowLeft className="h-4 w-4" />
                    </Link>
                </Button>
                <div>
                    <h1 className="text-2xl font-bold">Add Transport</h1>
                    <p className="text-muted-foreground">
                        Add a flight, train, bus, or other transport
                    </p>
                </div>
            </div>

            <Form {...form}>
                <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-8">
                    {/* Mode Selector */}
                    <FormField
                        control={form.control}
                        name="mode"
                        render={({ field }) => (
                            <FormItem>
                                <FormLabel>Transport Type *</FormLabel>
                                <div className="flex flex-wrap gap-2">
                                    {transportModes.map((mode) => {
                                        const Icon = mode.icon;
                                        return (
                                            <Button
                                                key={mode.id}
                                                type="button"
                                                variant={
                                                    field.value === mode.id
                                                        ? "default"
                                                        : "outline"
                                                }
                                                size="sm"
                                                onClick={() => field.onChange(mode.id)}
                                                className="gap-2"
                                            >
                                                <Icon className="h-4 w-4" />
                                                {mode.label}
                                            </Button>
                                        );
                                    })}
                                </div>
                                <FormMessage />
                            </FormItem>
                        )}
                    />

                    {/* Carrier & Flight Info */}
                    <div className="space-y-4">
                        <h3 className="text-lg font-semibold">
                            {selectedMode === "flight" ? "Flight Details" : "Transport Details"}
                        </h3>
                        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
                            {selectedMode === "flight" ? (
                                <FormField
                                    control={form.control}
                                    name="carrier_code"
                                    render={({ field }) => (
                                        <FormItem>
                                            <FormLabel>Airline</FormLabel>
                                            <FormControl>
                                                <AirlineAutocomplete
                                                    value={field.value}
                                                    onSelect={(airline) => {
                                                        if (airline) {
                                                            form.setValue("carrier_code", airline.iataCode);
                                                            form.setValue("carrier_name", airline.name);
                                                        } else {
                                                            form.setValue("carrier_code", "");
                                                            form.setValue("carrier_name", "");
                                                        }
                                                    }}
                                                />
                                            </FormControl>
                                            <FormMessage />
                                        </FormItem>
                                    )}
                                />
                            ) : (
                                <FormField
                                    control={form.control}
                                    name="carrier_name"
                                    render={({ field }) => (
                                        <FormItem>
                                            <FormLabel>Carrier</FormLabel>
                                            <FormControl>
                                                <Input placeholder="e.g., Amtrak" {...field} />
                                            </FormControl>
                                            <FormMessage />
                                        </FormItem>
                                    )}
                                />
                            )}
                            <FormField
                                control={form.control}
                                name="carrier_code"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Code</FormLabel>
                                        <FormControl>
                                            <Input
                                                placeholder="e.g., 6E"
                                                maxLength={3}
                                                {...field}
                                                onChange={(e) =>
                                                    field.onChange(e.target.value.toUpperCase())
                                                }
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                            <FormField
                                control={form.control}
                                name="transport_number"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>
                                            {selectedMode === "flight" ? "Flight" : "Number"}
                                        </FormLabel>
                                        <FormControl>
                                            <Input placeholder="e.g., 2057" {...field} />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                            <FormField
                                control={form.control}
                                name="booking_reference"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Booking Ref</FormLabel>
                                        <FormControl>
                                            <Input
                                                placeholder="e.g., ABC123"
                                                {...field}
                                                onChange={(e) =>
                                                    field.onChange(e.target.value.toUpperCase())
                                                }
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                        </div>
                    </div>

                    {/* Origin */}
                    <div className="space-y-4">
                        <h3 className="text-lg font-semibold">Departure</h3>
                        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
                            <FormField
                                control={form.control}
                                name="origin_city"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>City / Airport</FormLabel>
                                        <FormControl>
                                            <AirportCityInput
                                                value={field.value}
                                                onChange={field.onChange}
                                                placeholder={selectedMode === "flight" ? "Search airport or city..." : "e.g., Pune"}
                                                onLocationSelect={(data) => {
                                                    field.onChange(data.city || data.placeId);
                                                    form.setValue("origin_country_code", data.countryCode);
                                                    if (data.airportCode) {
                                                        form.setValue("origin_airport_code", data.airportCode);
                                                    }
                                                }}
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                            {selectedMode === "flight" && (
                                <>
                                    <FormField
                                        control={form.control}
                                        name="origin_airport_code"
                                        render={({ field }) => (
                                            <FormItem>
                                                <FormLabel>Airport Code</FormLabel>
                                                <FormControl>
                                                    <Input
                                                        placeholder="e.g., PNQ"
                                                        maxLength={3}
                                                        {...field}
                                                        onChange={(e) =>
                                                            field.onChange(
                                                                e.target.value.toUpperCase()
                                                            )
                                                        }
                                                    />
                                                </FormControl>
                                                <FormMessage />
                                            </FormItem>
                                        )}
                                    />
                                    <FormField
                                        control={form.control}
                                        name="origin_terminal"
                                        render={({ field }) => (
                                            <FormItem>
                                                <FormLabel>Terminal</FormLabel>
                                                <FormControl>
                                                    <Input placeholder="e.g., T1" {...field} />
                                                </FormControl>
                                                <FormMessage />
                                            </FormItem>
                                        )}
                                    />
                                </>
                            )}
                        </div>
                        <div className="grid gap-4 sm:grid-cols-2">
                            <FormField
                                control={form.control}
                                name="departure_date"
                                render={({ field }) => (
                                    <FormItem className="flex flex-col">
                                        <FormLabel>Departure Date</FormLabel>
                                        <Popover>
                                            <PopoverTrigger asChild>
                                                <FormControl>
                                                    <Button
                                                        variant="outline"
                                                        className={cn(
                                                            "w-full pl-3 text-left font-normal",
                                                            !field.value && "text-muted-foreground"
                                                        )}
                                                    >
                                                        {field.value ? (
                                                            format(field.value, "PPP")
                                                        ) : (
                                                            <span>Pick a date</span>
                                                        )}
                                                        <CalendarIcon className="ml-auto h-4 w-4 opacity-50" />
                                                    </Button>
                                                </FormControl>
                                            </PopoverTrigger>
                                            <PopoverContent className="w-auto p-0" align="start">
                                                <Calendar
                                                    mode="single"
                                                    selected={field.value}
                                                    onSelect={field.onChange}
                                                    initialFocus
                                                />
                                            </PopoverContent>
                                        </Popover>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                            <FormField
                                control={form.control}
                                name="departure_time"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Departure Time</FormLabel>
                                        <FormControl>
                                            <Input type="time" {...field} />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                        </div>
                    </div>

                    {/* Destination */}
                    <div className="space-y-4">
                        <h3 className="text-lg font-semibold">Arrival</h3>
                        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
                            <FormField
                                control={form.control}
                                name="destination_city"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>City / Airport</FormLabel>
                                        <FormControl>
                                            <AirportCityInput
                                                value={field.value}
                                                onChange={field.onChange}
                                                placeholder={selectedMode === "flight" ? "Search airport or city..." : "e.g., Bangkok"}
                                                onLocationSelect={(data) => {
                                                    field.onChange(data.city || data.placeId);
                                                    form.setValue("destination_country_code", data.countryCode);
                                                    if (data.airportCode) {
                                                        form.setValue("destination_airport_code", data.airportCode);
                                                    }
                                                }}
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                            {selectedMode === "flight" && (
                                <>
                                    <FormField
                                        control={form.control}
                                        name="destination_airport_code"
                                        render={({ field }) => (
                                            <FormItem>
                                                <FormLabel>Airport Code</FormLabel>
                                                <FormControl>
                                                    <Input
                                                        placeholder="e.g., BKK"
                                                        maxLength={3}
                                                        {...field}
                                                        onChange={(e) =>
                                                            field.onChange(
                                                                e.target.value.toUpperCase()
                                                            )
                                                        }
                                                    />
                                                </FormControl>
                                                <FormMessage />
                                            </FormItem>
                                        )}
                                    />
                                    <FormField
                                        control={form.control}
                                        name="destination_terminal"
                                        render={({ field }) => (
                                            <FormItem>
                                                <FormLabel>Terminal</FormLabel>
                                                <FormControl>
                                                    <Input placeholder="e.g., T2" {...field} />
                                                </FormControl>
                                                <FormMessage />
                                            </FormItem>
                                        )}
                                    />
                                </>
                            )}
                        </div>
                        <div className="grid gap-4 sm:grid-cols-2">
                            <FormField
                                control={form.control}
                                name="arrival_date"
                                render={({ field }) => (
                                    <FormItem className="flex flex-col">
                                        <FormLabel>Arrival Date</FormLabel>
                                        <Popover>
                                            <PopoverTrigger asChild>
                                                <FormControl>
                                                    <Button
                                                        variant="outline"
                                                        className={cn(
                                                            "w-full pl-3 text-left font-normal",
                                                            !field.value && "text-muted-foreground"
                                                        )}
                                                    >
                                                        {field.value ? (
                                                            format(field.value, "PPP")
                                                        ) : (
                                                            <span>Pick a date</span>
                                                        )}
                                                        <CalendarIcon className="ml-auto h-4 w-4 opacity-50" />
                                                    </Button>
                                                </FormControl>
                                            </PopoverTrigger>
                                            <PopoverContent className="w-auto p-0" align="start">
                                                <Calendar
                                                    mode="single"
                                                    selected={field.value}
                                                    onSelect={field.onChange}
                                                    initialFocus
                                                />
                                            </PopoverContent>
                                        </Popover>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                            <FormField
                                control={form.control}
                                name="arrival_time"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Arrival Time</FormLabel>
                                        <FormControl>
                                            <Input type="time" {...field} />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                        </div>
                    </div>

                    {/* Passengers */}
                    <div className="space-y-4">
                        <h3 className="text-lg font-semibold">Passengers</h3>
                        <div className="grid gap-4 sm:grid-cols-2">
                            <FormField
                                control={form.control}
                                name="passenger_count"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Number of Passengers</FormLabel>
                                        <FormControl>
                                            <Input
                                                type="number"
                                                min={1}
                                                placeholder="1"
                                                {...field}
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                        </div>
                    </div>

                    {/* Cost */}
                    <div className="space-y-4">
                        <h3 className="text-lg font-semibold">Cost</h3>
                        <div className="grid gap-4 sm:grid-cols-2">
                            <FormField
                                control={form.control}
                                name="expense_amount"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Amount</FormLabel>
                                        <FormControl>
                                            <Input
                                                type="number"
                                                placeholder="0.00"
                                                {...field}
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                            <FormField
                                control={form.control}
                                name="expense_currency"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Currency</FormLabel>
                                        <FormControl>
                                            <Input
                                                placeholder="USD"
                                                maxLength={3}
                                                {...field}
                                                onChange={(e) => field.onChange(e.target.value.toUpperCase())}
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                        </div>
                    </div>

                    {/* Notes */}
                    <FormField
                        control={form.control}
                        name="notes"
                        render={({ field }) => (
                            <FormItem>
                                <FormLabel>Notes</FormLabel>
                                <FormControl>
                                    <Textarea
                                        placeholder="Any notes about this transport..."
                                        className="resize-none"
                                        rows={3}
                                        {...field}
                                    />
                                </FormControl>
                                <FormMessage />
                            </FormItem>
                        )}
                    />

                    {/* Actions */}
                    <div className="flex gap-4">
                        <Button type="submit" disabled={isSubmitting}>
                            {isSubmitting && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                            Add Transport
                        </Button>
                        <Button
                            type="button"
                            variant="outline"
                            onClick={() => router.back()}
                            disabled={isSubmitting}
                        >
                            Cancel
                        </Button>
                    </div>
                </form>
            </Form>
        </div>
    );
}
