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
    FormField,
    FormItem,
    FormLabel,
    FormMessage,
} from "@/components/ui/form";
import { CityInput, PlaceAutocompleteInput } from "@/components/shared";
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
import { createActivityItem } from "@/actions/item-create";
import { toast } from "sonner";

const activityCategories = [
    "Tour",
    "Museum",
    "Restaurant",
    "Show",
    "Adventure",
    "Shopping",
    "Nature",
    "Landmark",
    "Entertainment",
    "Spa",
    "Other",
];

const activityFormSchema = z.object({
    title: z.string().min(1, "Activity name is required"),
    category: z.string().optional(),
    location_name: z.string().optional(),
    address: z.string().optional(),
    city: z.string().optional(),
    country_code: z.string().optional(),
    start_date: z.date().optional(),
    start_time: z.string().optional(),
    end_date: z.date().optional(),
    end_time: z.string().optional(),
    booking_code: z.string().optional(),
    booking_url: z.string().optional(),
    notes: z.string().optional(),
});

type ActivityFormValues = z.infer<typeof activityFormSchema>;

interface ActivityFormProps {
    tripId: string;
}

export function ActivityForm({ tripId }: ActivityFormProps) {
    const router = useRouter();
    const [isSubmitting, setIsSubmitting] = useState(false);

    const form = useForm<ActivityFormValues>({
        resolver: zodResolver(activityFormSchema),
        defaultValues: {},
    });

    async function onSubmit(data: ActivityFormValues) {
        setIsSubmitting(true);

        const startLocal =
            data.start_date && data.start_time
                ? `${format(data.start_date, "yyyy-MM-dd")}T${data.start_time}:00`
                : data.start_date
                    ? format(data.start_date, "yyyy-MM-dd")
                    : undefined;

        const endLocal =
            data.end_date && data.end_time
                ? `${format(data.end_date, "yyyy-MM-dd")}T${data.end_time}:00`
                : data.end_date
                    ? format(data.end_date, "yyyy-MM-dd")
                    : undefined;

        const result = await createActivityItem({
            trip_id: tripId,
            title: data.title,
            description: data.notes,
            category: data.category,
            location_name: data.location_name,
            address: data.address,
            city: data.city,
            country_code: data.country_code,
            start_local: startLocal,
            end_local: endLocal,
            booking_code: data.booking_code,
            booking_url: data.booking_url,
        });

        if (result) {
            toast.success("Activity added!");
            router.push(`/app/trips/${tripId}`);
        } else {
            toast.error("Failed to add activity");
            setIsSubmitting(false);
        }
    }

    return (
        <div className="space-y-6">
            <div className="flex items-center gap-4">
                <Button variant="ghost" size="icon" asChild>
                    <Link href={`/app/trips/${tripId}`}>
                        <ArrowLeft className="h-4 w-4" />
                    </Link>
                </Button>
                <div>
                    <h1 className="text-2xl font-bold">Add Activity</h1>
                    <p className="text-muted-foreground">Add a tour, restaurant, or event</p>
                </div>
            </div>

            <Form {...form}>
                <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-8">
                    {/* Activity Details */}
                    <div className="space-y-4">
                        <h3 className="text-lg font-semibold">Activity Details</h3>
                        <div className="grid gap-4 sm:grid-cols-2">
                            <FormField
                                control={form.control}
                                name="title"
                                render={({ field }) => (
                                    <FormItem className="sm:col-span-2">
                                        <FormLabel>Activity Name *</FormLabel>
                                        <FormControl>
                                            <Input
                                                placeholder="e.g., Grand Palace Tour"
                                                {...field}
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                            <FormField
                                control={form.control}
                                name="category"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Category</FormLabel>
                                        <Select
                                            onValueChange={field.onChange}
                                            defaultValue={field.value}
                                        >
                                            <FormControl>
                                                <SelectTrigger>
                                                    <SelectValue placeholder="Select category" />
                                                </SelectTrigger>
                                            </FormControl>
                                            <SelectContent>
                                                {activityCategories.map((cat) => (
                                                    <SelectItem key={cat} value={cat}>
                                                        {cat}
                                                    </SelectItem>
                                                ))}
                                            </SelectContent>
                                        </Select>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                            <FormField
                                control={form.control}
                                name="location_name"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Venue / Location</FormLabel>
                                        <FormControl>
                                            <PlaceAutocompleteInput
                                                value={field.value}
                                                variant="establishment"
                                                onChange={field.onChange}
                                                placeholder="Search for a place..."
                                                onSelect={(place) => {
                                                    field.onChange(place.name);
                                                    if (place.formattedAddress) {
                                                        form.setValue("address", place.formattedAddress);
                                                    }
                                                    if (place.city) {
                                                        form.setValue("city", place.city);
                                                    }
                                                    if (place.countryCode) {
                                                        form.setValue("country_code", place.countryCode);
                                                    }
                                                }}
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                            <FormField
                                control={form.control}
                                name="address"
                                render={({ field }) => (
                                    <FormItem className="sm:col-span-2">
                                        <FormLabel>Address</FormLabel>
                                        <FormControl>
                                            <Input placeholder="Full address" {...field} />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                            <FormField
                                control={form.control}
                                name="city"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>City</FormLabel>
                                        <FormControl>
                                            <CityInput
                                                value={field.value}
                                                onChange={field.onChange}
                                                placeholder="e.g., Bangkok"
                                                onCitySelect={(data) => {
                                                    field.onChange(data.city);
                                                    form.setValue("country_code", data.countryCode);
                                                }}
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                            <FormField
                                control={form.control}
                                name="country_code"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Country Code</FormLabel>
                                        <FormControl>
                                            <Input
                                                placeholder="e.g., TH"
                                                maxLength={2}
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

                    {/* Times */}
                    <div className="space-y-4">
                        <h3 className="text-lg font-semibold">Timing</h3>
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
                                                        {field.value
                                                            ? format(field.value, "PPP")
                                                            : "Pick a date"}
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
                                name="start_time"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Start Time</FormLabel>
                                        <FormControl>
                                            <Input type="time" {...field} />
                                        </FormControl>
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
                                                        {field.value
                                                            ? format(field.value, "PPP")
                                                            : "Pick a date"}
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
                                name="end_time"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>End Time</FormLabel>
                                        <FormControl>
                                            <Input type="time" {...field} />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                        </div>
                    </div>

                    {/* Booking Info */}
                    <div className="space-y-4">
                        <h3 className="text-lg font-semibold">Booking</h3>
                        <div className="grid gap-4 sm:grid-cols-2">
                            <FormField
                                control={form.control}
                                name="booking_code"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Booking Code</FormLabel>
                                        <FormControl>
                                            <Input placeholder="e.g., 12345678" {...field} />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                            <FormField
                                control={form.control}
                                name="booking_url"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Booking URL</FormLabel>
                                        <FormControl>
                                            <Input
                                                placeholder="e.g., https://viator.com/..."
                                                {...field}
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
                                        placeholder="Any notes about this activity..."
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
                            Add Activity
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
