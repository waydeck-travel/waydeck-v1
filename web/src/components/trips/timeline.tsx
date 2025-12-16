"use client";

import { format, parseISO } from "date-fns";
import { TimelineItemCard } from "./timeline-item-card";
import type { TripItemWithDetails } from "@/actions/trip-items";

interface TimelineItem extends TripItemWithDetails {
    dateKey: string;
    dateLabel: string;
}

function getDayLabel(date: Date, tripStartDate: Date | null, dayIndex: number | null): string {
    const monthDay = format(date, "EEE, d MMM");

    if (tripStartDate && dayIndex !== null) {
        return `Day ${dayIndex + 1} • ${monthDay}`;
    }
    return monthDay;
}

function getDateFromItem(item: TripItemWithDetails): Date | null {
    if (item.start_time_utc) return parseISO(item.start_time_utc);

    if (item.type === "transport" && item.transport_items?.[0]?.departure_local) {
        return parseISO(item.transport_items[0].departure_local);
    }
    if (item.type === "stay" && item.stay_items?.[0]?.checkin_local) {
        return parseISO(item.stay_items[0].checkin_local);
    }
    if (item.type === "activity" && item.activity_items?.[0]?.start_local) {
        return parseISO(item.activity_items[0].start_local);
    }

    return null;
}

interface TimelineProps {
    items: TripItemWithDetails[];
    tripId: string;
    tripStartDate?: string | null;
}

export function Timeline({ items, tripId, tripStartDate: startTime }: TimelineProps) {
    // Group items by date
    const tripStart = startTime ? parseISO(startTime) : null;

    const itemsWithDates: TimelineItem[] = items.map((item) => {
        const date = getDateFromItem(item);
        const dateKey = date ? format(date, "yyyy-MM-dd") : "unscheduled";
        const dateLabel = date
            ? getDayLabel(date, tripStart, item.day_index)
            : "Inbox / Unscheduled";

        return { ...item, dateKey, dateLabel };
    });

    // Group by dateKey
    const groupedItems: Record<string, TimelineItem[]> = {};
    itemsWithDates.forEach((item) => {
        if (!groupedItems[item.dateKey]) {
            groupedItems[item.dateKey] = [];
        }
        groupedItems[item.dateKey].push(item);
    });

    const sortedDateKeys = Object.keys(groupedItems).sort((a, b) => {
        if (a === "unscheduled") return -1; // Move to top
        if (b === "unscheduled") return 1;
        return a.localeCompare(b);
    });

    if (items.length === 0) {
        return (
            <div className="text-center py-12 text-muted-foreground">
                <p>No items in this trip yet.</p>
                <p className="text-sm mt-1">Add your first flight, hotel, or activity!</p>
            </div>
        );
    }

    return (
        <div className="space-y-6">
            {sortedDateKeys.map((dateKey) => {
                const dayItems = groupedItems[dateKey];
                const label = dayItems[0].dateLabel;

                return (
                    <div key={dateKey} className="space-y-3">
                        {/* Day Header */}
                        <div className="sticky top-0 z-10 bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60 py-2">
                            <h3 className="text-sm font-semibold text-muted-foreground">
                                {label}
                            </h3>
                        </div>

                        {/* Items */}
                        <div className="space-y-2 relative">
                            {/* Timeline rail */}
                            <div className="absolute left-[26px] top-0 bottom-0 w-0.5 bg-border" />

                            {dayItems.map((item) => (
                                <div key={item.id} className="relative">
                                    {/* Timeline dot */}
                                    <div
                                        className={`absolute left-[22px] top-6 w-2 h-2 rounded-full border-2 bg-background z-10 ${item.type === "transport"
                                            ? "border-blue-500"
                                            : item.type === "stay"
                                                ? "border-green-500"
                                                : item.type === "activity"
                                                    ? "border-purple-500"
                                                    : "border-amber-500"
                                            }`}
                                    />
                                    <div className="pl-12">
                                        <TimelineItemCard item={item} tripId={tripId} />
                                    </div>
                                </div>
                            ))}
                        </div>
                    </div>
                );
            })}
        </div>
    );
}
