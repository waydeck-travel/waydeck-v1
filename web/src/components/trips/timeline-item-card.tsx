"use client";

import {
    Plane,
    Train,
    Bus,
    Car,
    Bike,
    Ship,
    TrainFront,
    Sailboat,
    CarTaxiFront,
    Hotel,
    Ticket,
    FileText,
    MapPin,
    Clock,
    ChevronRight,
} from "lucide-react";
import Link from "next/link";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { formatTime, formatShortDate } from "@/lib/dates";
import type { TripItemWithDetails } from "@/actions/trip-items";

const transportModeIcons: Record<string, typeof Plane> = {
    flight: Plane,
    train: Train,
    bus: Bus,
    car: Car,
    bike: Bike,
    cruise: Ship,
    metro: TrainFront,
    ferry: Sailboat,
    other: CarTaxiFront,
};

interface TimelineItemCardProps {
    item: TripItemWithDetails;
    tripId: string;
}

export function TimelineItemCard({ item, tripId }: TimelineItemCardProps) {
    const docCount = item.documents?.[0]?.count || 0;

    const getTransportContent = () => {
        const transport = item.transport_items?.[0];
        // RLS or legacy data might result in missing details. Show generic info.
        if (!transport) return {
            icon: CarTaxiFront,
            iconBg: "bg-gray-100 dark:bg-gray-800",
            iconColor: "text-gray-600 dark:text-gray-400",
            title: item.title || "Transport",
            subtitle: "Details unavailable",
            time: formatTime(item.start_time_utc),
            badges: [],
        };

        const ModeIcon = transportModeIcons[transport.mode] || CarTaxiFront;
        const modeName = transport.mode.charAt(0).toUpperCase() + transport.mode.slice(1);

        return {
            icon: ModeIcon,
            iconBg: "bg-blue-100 dark:bg-blue-900/30",
            iconColor: "text-blue-600 dark:text-blue-400",
            title:
                transport.transport_number
                    ? `${modeName} ${transport.carrier_code || ""} ${transport.transport_number}`
                    : `${modeName} to ${transport.destination_city || "destination"}`,
            subtitle: transport.origin_airport_code && transport.destination_airport_code
                ? `${transport.origin_airport_code} → ${transport.destination_airport_code}`
                : `${transport.origin_city || ""} → ${transport.destination_city || ""}`,
            time:
                transport.departure_local && transport.arrival_local
                    ? `${formatTime(transport.departure_local)} – ${formatTime(transport.arrival_local)}`
                    : undefined,
            badges: [
                modeName,
                transport.passenger_count && transport.passenger_count > 1
                    ? `${transport.passenger_count} passengers`
                    : undefined,
                docCount > 0 ? "🎫 Ticket" : undefined,
                transport.expense_amount
                    ? `${transport.expense_currency || ""} ${transport.expense_amount.toLocaleString()}`
                    : undefined,
            ].filter(Boolean) as string[],
        };
    };

    const getStayContent = () => {
        const stay = item.stay_items?.[0];
        if (!stay) return {
            icon: Hotel,
            iconBg: "bg-gray-100 dark:bg-gray-800",
            iconColor: "text-gray-600 dark:text-gray-400",
            title: item.title || "Accommodation",
            subtitle: "Details unavailable",
            time: formatTime(item.start_time_utc),
            badges: [],
        };

        return {
            icon: Hotel,
            iconBg: "bg-green-100 dark:bg-green-900/30",
            iconColor: "text-green-600 dark:text-green-400",
            title: stay.accommodation_name,
            subtitle: [stay.city, stay.country_code].filter(Boolean).join(", "),
            time:
                stay.checkin_local && stay.checkout_local
                    ? `Check-in ${formatShortDate(stay.checkin_local)} • Out ${formatShortDate(stay.checkout_local)}`
                    : undefined,
            badges: [
                stay.has_breakfast ? "🍳 Breakfast" : undefined,
                docCount > 0 ? "📎 Voucher" : undefined,
                stay.expense_amount
                    ? `${stay.expense_currency || ""} ${stay.expense_amount.toLocaleString()}`
                    : undefined,
            ].filter(Boolean) as string[],
        };
    };

    const getActivityContent = () => {
        const activity = item.activity_items?.[0];
        if (!activity) return {
            icon: Ticket,
            iconBg: "bg-gray-100 dark:bg-gray-800",
            iconColor: "text-gray-600 dark:text-gray-400",
            title: item.title || "Activity",
            subtitle: "Details unavailable",
            time: formatTime(item.start_time_utc),
            badges: [],
        };

        return {
            icon: Ticket,
            iconBg: "bg-purple-100 dark:bg-purple-900/30",
            iconColor: "text-purple-600 dark:text-purple-400",
            title: item.title,
            subtitle: [activity.location_name || activity.city, activity.category]
                .filter(Boolean)
                .join(" • "),
            time:
                activity.start_local && activity.end_local
                    ? `${formatTime(activity.start_local)} – ${formatTime(activity.end_local)}`
                    : activity.start_local
                        ? formatTime(activity.start_local)
                        : undefined,
            badges: [
                activity.category,
                docCount > 0 ? "🎫 Ticket" : undefined,
                activity.expense_amount
                    ? `${activity.expense_currency || ""} ${activity.expense_amount.toLocaleString()}`
                    : undefined,
            ].filter(Boolean) as string[],
        };
    };

    const getNoteContent = () => {
        return {
            icon: FileText,
            iconBg: "bg-amber-100 dark:bg-amber-900/30",
            iconColor: "text-amber-600 dark:text-amber-400",
            title: item.title,
            subtitle: item.description?.slice(0, 80) || "",
            time: undefined,
            badges: [],
        };
    };

    const content =
        item.type === "transport"
            ? getTransportContent()
            : item.type === "stay"
                ? getStayContent()
                : item.type === "activity"
                    ? getActivityContent()
                    : getNoteContent();

    if (!content) return null;

    const Icon = content.icon;

    return (
        <Link href={`/app/trips/${tripId}/items/${item.id}`}>
            <Card className="hover:bg-muted/50 transition-colors cursor-pointer">
                <CardContent className="flex items-start gap-4 p-4">
                    {/* Icon */}
                    <div className={`rounded-lg p-2 ${content.iconBg}`}>
                        <Icon className={`h-5 w-5 ${content.iconColor}`} />
                    </div>

                    {/* Content */}
                    <div className="flex-1 min-w-0">
                        <h4 className="font-medium truncate">{content.title}</h4>
                        {content.subtitle && (
                            <p className="text-sm text-muted-foreground flex items-center gap-1">
                                <MapPin className="h-3 w-3" />
                                {content.subtitle}
                            </p>
                        )}
                        {content.time && (
                            <p className="text-sm text-muted-foreground flex items-center gap-1">
                                <Clock className="h-3 w-3" />
                                {content.time}
                            </p>
                        )}
                        {content.badges.length > 0 && (
                            <div className="mt-2 flex flex-wrap gap-1">
                                {content.badges.map((badge, i) => (
                                    <Badge key={i} variant="secondary" className="text-xs">
                                        {badge}
                                    </Badge>
                                ))}
                            </div>
                        )}
                    </div>

                    {/* Arrow */}
                    <ChevronRight className="h-4 w-4 text-muted-foreground shrink-0" />
                </CardContent>
            </Card>
        </Link>
    );
}

// Layover chip component
interface LayoverChipProps {
    durationMinutes: number;
    location: string;
}

export function LayoverChip({ durationMinutes, location }: LayoverChipProps) {
    const hours = Math.floor(durationMinutes / 60);
    const minutes = durationMinutes % 60;
    const duration = hours > 0 ? `${hours}h ${minutes}m` : `${minutes}m`;

    return (
        <div className="py-2 px-4 bg-amber-50 dark:bg-amber-950 rounded-lg text-sm flex items-center gap-2">
            <Clock className="h-4 w-4 text-amber-600 dark:text-amber-400" />
            <span className="text-amber-800 dark:text-amber-200">
                Layover: {duration} at {location}
            </span>
        </div>
    );
}
