"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { format } from "date-fns";
import { CalendarIcon, Loader2, ArrowLeft } from "lucide-react";
import Link from "next/link";

import { Button } from "@/components/ui/button";
import {
    Form,
    FormControl,
    FormDescription,
    FormField,
    FormItem,
    FormLabel,
    FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Calendar } from "@/components/ui/calendar";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from "@/components/ui/select";
import { cn } from "@/lib/utils";
import { CityInput } from "@/components/shared";
import { createTrip, updateTrip, type CreateTripInput } from "@/actions/trips";
import type { Trip } from "@/types";
import { toast } from "sonner";

const tripFormSchema = z.object({
    name: z.string().min(1, "Trip name is required").max(100, "Name too long"),
    origin_city: z.string().optional(),
    origin_country_code: z.string().optional(),
    start_date: z.date().optional(),
    end_date: z.date().optional(),
    notes: z.string().optional(),
    currency: z.string().optional(),
});

type TripFormValues = z.infer<typeof tripFormSchema>;

// Common currencies
const currencies = [
    { code: "USD", name: "US Dollar" },
    { code: "EUR", name: "Euro" },
    { code: "GBP", name: "British Pound" },
    { code: "INR", name: "Indian Rupee" },
    { code: "JPY", name: "Japanese Yen" },
    { code: "AUD", name: "Australian Dollar" },
    { code: "CAD", name: "Canadian Dollar" },
    { code: "THB", name: "Thai Baht" },
    { code: "VND", name: "Vietnamese Dong" },
    { code: "SGD", name: "Singapore Dollar" },
];

interface TripFormProps {
    trip?: Trip;
    mode: "create" | "edit";
}

export function TripForm({ trip, mode }: TripFormProps) {
    const router = useRouter();
    const [isSubmitting, setIsSubmitting] = useState(false);

    const form = useForm<TripFormValues>({
        resolver: zodResolver(tripFormSchema),
        defaultValues: {
            name: trip?.name || "",
            origin_city: trip?.origin_city || "",
            origin_country_code: trip?.origin_country_code || "",
            start_date: trip?.start_date ? new Date(trip.start_date) : undefined,
            end_date: trip?.end_date ? new Date(trip.end_date) : undefined,
            notes: trip?.notes || "",
            currency: trip?.currency || "USD",
        },
    });

    async function onSubmit(data: TripFormValues) {
        setIsSubmitting(true);

        const input: CreateTripInput = {
            name: data.name,
            origin_city: data.origin_city,
            origin_country_code: data.origin_country_code,
            start_date: data.start_date ? format(data.start_date, "yyyy-MM-dd") : undefined,
            end_date: data.end_date ? format(data.end_date, "yyyy-MM-dd") : undefined,
            notes: data.notes,
            currency: data.currency,
        };

        if (mode === "create") {
            const result = await createTrip(input);
            if (result) {
                toast.success("Trip created!");
                router.push(`/app/trips/${result.id}`);
            } else {
                toast.error("Failed to create trip");
                setIsSubmitting(false);
            }
        } else if (trip) {
            const success = await updateTrip(trip.id, input);
            if (success) {
                toast.success("Trip updated!");
                router.push(`/app/trips/${trip.id}`);
            } else {
                toast.error("Failed to update trip");
                setIsSubmitting(false);
            }
        }
    }

    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex items-center gap-4">
                <Button variant="ghost" size="icon" asChild>
                    <Link href={mode === "edit" && trip ? `/app/trips/${trip.id}` : "/app/trips"}>
                        <ArrowLeft className="h-4 w-4" />
                    </Link>
                </Button>
                <div>
                    <h1 className="text-2xl font-bold">
                        {mode === "create" ? "Create New Trip" : "Edit Trip"}
                    </h1>
                    <p className="text-muted-foreground">
                        {mode === "create"
                            ? "Plan your next adventure"
                            : "Update your trip details"}
                    </p>
                </div>
            </div>

            <Form {...form}>
                <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-8">
                    {/* Trip Name */}
                    <FormField
                        control={form.control}
                        name="name"
                        render={({ field }) => (
                            <FormItem>
                                <FormLabel>Trip Name *</FormLabel>
                                <FormControl>
                                    <Input
                                        placeholder="e.g., Vietnam & Thailand 2025"
                                        {...field}
                                    />
                                </FormControl>
                                <FormDescription>
                                    Give your trip a memorable name
                                </FormDescription>
                                <FormMessage />
                            </FormItem>
                        )}
                    />

                    {/* Origin Section */}
                    <div className="space-y-4">
                        <h3 className="text-lg font-semibold">Origin</h3>
                        <div className="grid gap-4 sm:grid-cols-2">
                            <FormField
                                control={form.control}
                                name="origin_city"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>City</FormLabel>
                                        <FormControl>
                                            <CityInput
                                                value={field.value}
                                                onChange={field.onChange}
                                                placeholder="e.g., Pune"
                                                onCitySelect={(data) => {
                                                    field.onChange(data.city);
                                                    form.setValue("origin_country_code", data.countryCode);
                                                }}
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                            <FormField
                                control={form.control}
                                name="origin_country_code"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Country Code</FormLabel>
                                        <FormControl>
                                            <Input
                                                placeholder="e.g., IN"
                                                maxLength={2}
                                                {...field}
                                                onChange={(e) =>
                                                    field.onChange(e.target.value.toUpperCase())
                                                }
                                            />
                                        </FormControl>
                                        <FormDescription>2-letter country code</FormDescription>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                        </div>
                    </div>

                    {/* Dates Section */}
                    <div className="space-y-4">
                        <h3 className="text-lg font-semibold">Dates</h3>
                        <div className="grid gap-4 sm:grid-cols-2">
                            <FormField
                                control={form.control}
                                name="start_date"
                                render={({ field }) => (
                                    <FormItem className="flex flex-col">
                                        <FormLabel>Start Date</FormLabel>
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
                                name="end_date"
                                render={({ field }) => (
                                    <FormItem className="flex flex-col">
                                        <FormLabel>End Date</FormLabel>
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
                        </div>
                    </div>

                    {/* Currency */}
                    <FormField
                        control={form.control}
                        name="currency"
                        render={({ field }) => (
                            <FormItem>
                                <FormLabel>Primary Currency</FormLabel>
                                <Select onValueChange={field.onChange} defaultValue={field.value}>
                                    <FormControl>
                                        <SelectTrigger>
                                            <SelectValue placeholder="Select currency" />
                                        </SelectTrigger>
                                    </FormControl>
                                    <SelectContent>
                                        {currencies.map((currency) => (
                                            <SelectItem key={currency.code} value={currency.code}>
                                                {currency.code} - {currency.name}
                                            </SelectItem>
                                        ))}
                                    </SelectContent>
                                </Select>
                                <FormDescription>
                                    Used for budget and expense tracking
                                </FormDescription>
                                <FormMessage />
                            </FormItem>
                        )}
                    />

                    {/* Notes */}
                    <FormField
                        control={form.control}
                        name="notes"
                        render={({ field }) => (
                            <FormItem>
                                <FormLabel>Notes</FormLabel>
                                <FormControl>
                                    <Textarea
                                        placeholder="Any notes about your trip..."
                                        className="resize-none"
                                        rows={4}
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
                            {mode === "create" ? "Create Trip" : "Save Changes"}
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
