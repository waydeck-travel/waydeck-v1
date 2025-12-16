import { notFound } from "next/navigation";
import { TripForm } from "@/components/forms/trip-form";
import { getTrip } from "@/actions/trips";

interface EditTripPageProps {
    params: Promise<{ tripId: string }>;
}

export default async function EditTripPage({ params }: EditTripPageProps) {
    const { tripId } = await params;
    const trip = await getTrip(tripId);

    if (!trip) {
        notFound();
    }

    return <TripForm mode="edit" trip={trip} />;
}
