import { notFound } from "next/navigation";
import Link from "next/link";
import {
    ArrowLeft,
    Plane,
    Hotel,
    Ticket,
    FileText,
    Plus,
    CheckSquare,
    Wallet,
    Calculator,
    Settings,
    Calendar,
    MapPin,
    Edit,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent } from "@/components/ui/card";
import { Separator } from "@/components/ui/separator";
import { Timeline } from "@/components/trips/timeline";
import { getTripWithDetails, getTripItems } from "@/actions/trip-items";
import { formatDateRange, getDurationDays, isTripActive } from "@/lib/dates";
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuSeparator,
    DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";

interface TripPageProps {
    params: Promise<{ tripId: string }>;
    searchParams: Promise<{ city?: string }>;
}

export default async function TripPage({ params, searchParams }: TripPageProps) {
    const { tripId } = await params;
    const { city: filterCity } = await searchParams;

    const [trip, allItems] = await Promise.all([
        getTripWithDetails(tripId),
        getTripItems(tripId),
    ]);

    if (!trip) {
        notFound();
    }

    // Filter items by city if filter is active
    const items = filterCity
        ? allItems.filter((item) => {
            if (item.type === "transport") {
                const t = item.transport_items?.[0];
                return t?.origin_city === filterCity || t?.destination_city === filterCity;
            }
            if (item.type === "stay") {
                return item.stay_items?.[0]?.city === filterCity;
            }
            if (item.type === "activity") {
                return item.activity_items?.[0]?.city === filterCity;
            }
            return true; // notes always show
        })
        : allItems;

    const isActive = isTripActive(trip.start_date, trip.end_date);
    const duration = getDurationDays(trip.start_date, trip.end_date);

    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex items-start gap-4">
                <Button variant="ghost" size="icon" asChild>
                    <Link href="/app/trips">
                        <ArrowLeft className="h-4 w-4" />
                    </Link>
                </Button>
                <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-3 flex-wrap">
                        <h1 className="text-2xl font-bold truncate">{trip.name}</h1>
                        {isActive && (
                            <Badge className="bg-green-600">Active</Badge>
                        )}
                    </div>
                    <div className="text-muted-foreground flex flex-wrap items-center gap-x-4 gap-y-1 text-sm mt-1">
                        {(trip.origin_city || trip.origin_country_code) && (
                            <span className="flex items-center gap-1">
                                <MapPin className="h-3 w-3" />
                                {[trip.origin_city, trip.origin_country_code]
                                    .filter(Boolean)
                                    .join(", ")}
                            </span>
                        )}
                        <span className="flex items-center gap-1">
                            <Calendar className="h-3 w-3" />
                            {formatDateRange(trip.start_date, trip.end_date)}
                            {duration && <span className="text-xs">({duration} days)</span>}
                        </span>
                    </div>
                </div>
                <Button variant="outline" size="sm" asChild>
                    <Link href={`/app/trips/${tripId}/edit`}>
                        <Edit className="h-4 w-4 mr-1" />
                        Edit
                    </Link>
                </Button>
            </div>

            {/* Stats Row */}
            <Card>
                <CardContent className="py-3 px-4">
                    <div className="flex flex-wrap gap-4 sm:gap-6">
                        <div className="flex items-center gap-2 text-sm">
                            <Plane className="h-4 w-4 text-blue-500" />
                            <span className="font-medium">{trip.transport_count}</span>
                            <span className="text-muted-foreground">Transport</span>
                        </div>
                        <div className="flex items-center gap-2 text-sm">
                            <Hotel className="h-4 w-4 text-green-500" />
                            <span className="font-medium">{trip.stay_count}</span>
                            <span className="text-muted-foreground">Stay</span>
                        </div>
                        <div className="flex items-center gap-2 text-sm">
                            <Ticket className="h-4 w-4 text-purple-500" />
                            <span className="font-medium">{trip.activity_count}</span>
                            <span className="text-muted-foreground">Activities</span>
                        </div>
                        <div className="flex items-center gap-2 text-sm">
                            <FileText className="h-4 w-4 text-amber-500" />
                            <span className="font-medium">{trip.document_count}</span>
                            <span className="text-muted-foreground">Documents</span>
                        </div>
                    </div>
                </CardContent>
            </Card>

            {/* Cities Chips */}
            {trip.cities && trip.cities.length > 0 && (
                <div className="flex flex-wrap gap-2 items-center">
                    {filterCity && (
                        <Badge variant="secondary" className="py-1 px-3">
                            Filtered: {filterCity}
                            <Link href={`/app/trips/${tripId}`} className="ml-2 hover:text-destructive">×</Link>
                        </Badge>
                    )}
                    {trip.cities.map((city: string) => (
                        <Link key={city} href={`/app/trips/${tripId}?city=${encodeURIComponent(city)}`}>
                            <Badge
                                variant={filterCity === city ? "default" : "outline"}
                                className="py-1 px-3 cursor-pointer hover:bg-muted"
                            >
                                <MapPin className="h-3 w-3 mr-1" />
                                {city}
                            </Badge>
                        </Link>
                    ))}
                </div>
            )}

            {/* Quick Actions */}
            <div className="flex flex-wrap gap-2">
                <Button variant="outline" size="sm" asChild>
                    <Link href={`/app/trips/${tripId}/checklist`}>
                        <CheckSquare className="h-4 w-4 mr-1" />
                        Checklist
                    </Link>
                </Button>
                <Button variant="outline" size="sm" asChild>
                    <Link href={`/app/trips/${tripId}/expenses`}>
                        <Wallet className="h-4 w-4 mr-1" />
                        Expenses
                    </Link>
                </Button>
                <Button variant="outline" size="sm" asChild>
                    <Link href={`/app/trips/${tripId}/budget`}>
                        <Calculator className="h-4 w-4 mr-1" />
                        Budget
                    </Link>
                </Button>
                <Button variant="outline" size="sm" asChild>
                    <Link href={`/app/trips/${tripId}/documents`}>
                        <FileText className="h-4 w-4 mr-1" />
                        Documents
                    </Link>
                </Button>
            </div>

            <Separator />

            {/* Timeline Section */}
            <div className="flex items-center justify-between">
                <h2 className="text-lg font-semibold">Itinerary</h2>
                <DropdownMenu>
                    <DropdownMenuTrigger asChild>
                        <Button size="sm">
                            <Plus className="h-4 w-4 mr-1" />
                            Add Item
                        </Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent align="end">
                        <DropdownMenuItem asChild>
                            <Link href={`/app/trips/${tripId}/items/new?type=transport`}>
                                <Plane className="h-4 w-4 mr-2 text-blue-500" />
                                Transport
                            </Link>
                        </DropdownMenuItem>
                        <DropdownMenuItem asChild>
                            <Link href={`/app/trips/${tripId}/items/new?type=stay`}>
                                <Hotel className="h-4 w-4 mr-2 text-green-500" />
                                Stay
                            </Link>
                        </DropdownMenuItem>
                        <DropdownMenuItem asChild>
                            <Link href={`/app/trips/${tripId}/items/new?type=activity`}>
                                <Ticket className="h-4 w-4 mr-2 text-purple-500" />
                                Activity
                            </Link>
                        </DropdownMenuItem>
                        <DropdownMenuSeparator />
                        <DropdownMenuItem asChild>
                            <Link href={`/app/trips/${tripId}/items/new?type=note`}>
                                <FileText className="h-4 w-4 mr-2 text-amber-500" />
                                Note
                            </Link>
                        </DropdownMenuItem>
                    </DropdownMenuContent>
                </DropdownMenu>
            </div>

            <Timeline items={items} tripId={tripId} tripStartDate={trip.start_date} />
        </div>
    );
}
