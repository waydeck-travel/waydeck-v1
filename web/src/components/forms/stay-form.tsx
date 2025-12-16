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
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Calendar } from "@/components/ui/calendar";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";
import { Switch } from "@/components/ui/switch";
import { cn } from "@/lib/utils";
import { HotelInput, CityInput } from "@/components/shared";
import { createStayItem } from "@/actions/item-create";
import { toast } from "sonner";

const stayFormSchema = z.object({
    accommodation_name: z.string().min(1, "Property name is required"),
    address: z.string().optional(),
    city: z.string().optional(),
    country_code: z.string().optional(),
    checkin_date: z.date().optional(),
    checkin_time: z.string().optional(),
    checkout_date: z.date().optional(),
    checkout_time: z.string().optional(),
    has_breakfast: z.boolean().optional(),
    confirmation_number: z.string().optional(),
    booking_url: z.string().optional(),
    notes: z.string().optional(),
});

type StayFormValues = z.infer<typeof stayFormSchema>;

interface StayFormProps {
    tripId: string;
}

export function StayForm({ tripId }: StayFormProps) {
    const router = useRouter();
    const [isSubmitting, setIsSubmitting] = useState(false);

    const form = useForm<StayFormValues>({
        resolver: zodResolver(stayFormSchema),
        defaultValues: {
            accommodation_name: "",
            address: "",
            city: "",
            country_code: "",
            checkin_time: "",
            checkout_time: "",
            confirmation_number: "",
            booking_url: "",
            notes: "",
            has_breakfast: false,
        },
    });

    async function onSubmit(data: StayFormValues) {
        setIsSubmitting(true);

        const checkinLocal =
            data.checkin_date && data.checkin_time
                ? `${format(data.checkin_date, "yyyy-MM-dd")}T${data.checkin_time}:00`
                : data.checkin_date
                    ? format(data.checkin_date, "yyyy-MM-dd")
                    : undefined;

        const checkoutLocal =
            data.checkout_date && data.checkout_time
                ? `${format(data.checkout_date, "yyyy-MM-dd")}T${data.checkout_time}:00`
                : data.checkout_date
                    ? format(data.checkout_date, "yyyy-MM-dd")
                    : undefined;

        const result = await createStayItem({
            trip_id: tripId,
            title: data.accommodation_name,
            description: data.notes,
            accommodation_name: data.accommodation_name,
            address: data.address,
            city: data.city,
            country_code: data.country_code,
            checkin_local: checkinLocal,
            checkout_local: checkoutLocal,
            has_breakfast: data.has_breakfast,
            confirmation_number: data.confirmation_number,
            booking_url: data.booking_url,
        });

        if (result) {
            toast.success("Stay added!");
            router.push(`/app/trips/${tripId}`);
        } else {
            toast.error("Failed to add stay");
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
                    <h1 className="text-2xl font-bold">Add Stay</h1>
                    <p className="text-muted-foreground">Add a hotel, hostel, or accommodation</p>
                </div>
            </div>

            <Form {...form}>
                <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-8">
                    {/* Property Details */}
                    <div className="space-y-4">
                        <h3 className="text-lg font-semibold">Property Details</h3>
                        <div className="grid gap-4 sm:grid-cols-2">
                            <FormField
                                control={form.control}
                                name="accommodation_name"
                                render={({ field }) => (
                                    <FormItem className="sm:col-span-2">
                                        <FormLabel>Property Name *</FormLabel>
                                        <FormControl>
                                            <HotelInput
                                                value={field.value}
                                                onChange={field.onChange}
                                                placeholder="Search for a hotel..."
                                                onHotelSelect={(data) => {
                                                    field.onChange(data.name);
                                                    form.setValue("address", data.address);
                                                    form.setValue("city", data.city);
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
                                name="address"
                                render={({ field }) => (
                                    <FormItem className="sm:col-span-2">
                                        <FormLabel>Address</FormLabel>
                                        <FormControl>
                                            <Input placeholder="e.g., 123 Sukhumvit Road" {...field} />
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

                    {/* Dates */}
                    <div className="space-y-4">
                        <h3 className="text-lg font-semibold">Check-in / Check-out</h3>
                        <div className="grid gap-4 sm:grid-cols-2">
                            <FormField
                                control={form.control}
                                name="checkin_date"
                                render={({ field }) => (
                                    <FormItem className="flex flex-col">
                                        <FormLabel>Check-in Date</FormLabel>
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
                                name="checkin_time"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Check-in Time</FormLabel>
                                        <FormControl>
                                            <Input type="time" {...field} />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                            <FormField
                                control={form.control}
                                name="checkout_date"
                                render={({ field }) => (
                                    <FormItem className="flex flex-col">
                                        <FormLabel>Check-out Date</FormLabel>
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
                                name="checkout_time"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Check-out Time</FormLabel>
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
                                name="confirmation_number"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Confirmation Number</FormLabel>
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
                                                placeholder="e.g., https://booking.com/..."
                                                {...field}
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                            <FormField
                                control={form.control}
                                name="has_breakfast"
                                render={({ field }) => (
                                    <FormItem className="flex items-center gap-3 space-y-0">
                                        <FormControl>
                                            <Switch
                                                checked={field.value}
                                                onCheckedChange={field.onChange}
                                            />
                                        </FormControl>
                                        <FormLabel className="cursor-pointer">
                                            Breakfast included
                                        </FormLabel>
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
                                        placeholder="Any notes about this stay..."
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
                            Add Stay
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
