import Link from "next/link";
import { Plus, Plane } from "lucide-react";
import { Button } from "@/components/ui/button";
import { TripCard } from "@/components/trips/trip-card";
import { getTrips } from "@/actions/trips";

// Empty state component
function EmptyState() {
    return (
        <div className="flex flex-col items-center justify-center py-16 text-center">
            <div className="rounded-full bg-muted p-4 mb-4">
                <Plane className="h-8 w-8 text-muted-foreground" />
            </div>
            <h3 className="text-lg font-semibold mb-1">No trips yet</h3>
            <p className="text-sm text-muted-foreground mb-6 max-w-sm">
                Start planning your first adventure. Create a trip to organize your
                flights, hotels, and activities.
            </p>
            <Button asChild>
                <Link href="/app/trips/new">
                    <Plus className="mr-2 h-4 w-4" />
                    Create Your First Trip
                </Link>
            </Button>
        </div>
    );
}

export default async function TripsPage() {
    const trips = await getTrips();

    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-2xl font-bold">My Trips</h1>
                    <p className="text-muted-foreground">
                        Plan and organize your travel adventures
                    </p>
                </div>
                <Button asChild>
                    <Link href="/app/trips/new">
                        <Plus className="mr-2 h-4 w-4" />
                        New Trip
                    </Link>
                </Button>
            </div>

            {/* Content */}
            {trips.length === 0 ? (
                <EmptyState />
            ) : (
                <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
                    {trips.map((trip) => (
                        <TripCard key={trip.id} trip={trip} />
                    ))}
                </div>
            )}
        </div>
    );
}
