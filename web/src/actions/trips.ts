"use server";

import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";
import type { Trip, TripWithCounts } from "@/types";

export async function getTrips(): Promise<TripWithCounts[]> {
    const supabase = await createClient();

    const {
        data: { user },
    } = await supabase.auth.getUser();
    if (!user) return [];

    // Get trips with counts using raw query approach
    const { data: trips, error } = await supabase
        .from("trips")
        .select("*")
        .eq("owner_id", user.id)
        .eq("archived", false)
        .order("created_at", { ascending: false });

    if (error || !trips) {
        console.error("Error fetching trips:", error);
        return [];
    }

    // Get trip IDs for batch queries
    const tripIds = trips.map((t) => t.id);

    // Fetch all trip items and documents in two queries instead of N+1
    const [itemsResult, documentsResult] = await Promise.all([
        supabase.from("trip_items").select("trip_id, type").in("trip_id", tripIds),
        supabase.from("documents").select("trip_id").in("trip_id", tripIds),
    ]);

    // Aggregate item counts by trip and type
    const itemCounts = new Map<
        string,
        { transport: number; stay: number; activity: number; note: number }
    >();
    tripIds.forEach((id) =>
        itemCounts.set(id, { transport: 0, stay: 0, activity: 0, note: 0 })
    );

    itemsResult.data?.forEach((item) => {
        const counts = itemCounts.get(item.trip_id);
        if (counts && item.type in counts) {
            counts[item.type as keyof typeof counts]++;
        }
    });

    // Aggregate document counts by trip
    const documentCounts = new Map<string, number>();
    tripIds.forEach((id) => documentCounts.set(id, 0));
    documentsResult.data?.forEach((doc) => {
        documentCounts.set(doc.trip_id, (documentCounts.get(doc.trip_id) || 0) + 1);
    });

    // Combine trips with counts
    const tripsWithCounts = trips.map((trip) => {
        const counts = itemCounts.get(trip.id) || {
            transport: 0,
            stay: 0,
            activity: 0,
            note: 0,
        };
        return {
            ...trip,
            transport_count: counts.transport,
            stay_count: counts.stay,
            activity_count: counts.activity,
            note_count: counts.note,
            document_count: documentCounts.get(trip.id) || 0,
        } as TripWithCounts;
    });

    return tripsWithCounts;
}

export async function getTrip(tripId: string): Promise<Trip | null> {
    const supabase = await createClient();

    const { data: trip, error } = await supabase
        .from("trips")
        .select("*")
        .eq("id", tripId)
        .single();

    if (error) {
        console.error("Error fetching trip:", error);
        return null;
    }

    return trip;
}

export interface CreateTripInput {
    name: string;
    origin_city?: string;
    origin_country_code?: string;
    start_date?: string;
    end_date?: string;
    notes?: string;
    currency?: string;
}

export async function createTrip(input: CreateTripInput): Promise<{ id: string } | null> {
    const supabase = await createClient();

    const {
        data: { user },
    } = await supabase.auth.getUser();
    if (!user) return null;

    const { data, error } = await supabase
        .from("trips")
        .insert({
            owner_id: user.id,
            name: input.name,
            origin_city: input.origin_city || null,
            origin_country_code: input.origin_country_code || null,
            start_date: input.start_date || null,
            end_date: input.end_date || null,
            notes: input.notes || null,
            currency: input.currency || "USD",
            archived: false,
        })
        .select("id")
        .single();

    if (error) {
        console.error("Error creating trip:", error);
        return null;
    }

    revalidatePath("/app/trips");
    return data;
}

export async function updateTrip(
    tripId: string,
    input: Partial<CreateTripInput>
): Promise<boolean> {
    const supabase = await createClient();

    const { error } = await supabase
        .from("trips")
        .update({
            ...input,
            updated_at: new Date().toISOString(),
        })
        .eq("id", tripId);

    if (error) {
        console.error("Error updating trip:", error);
        return false;
    }

    revalidatePath("/app/trips");
    revalidatePath(`/app/trips/${tripId}`);
    return true;
}

export async function archiveTrip(tripId: string): Promise<boolean> {
    const supabase = await createClient();

    const { error } = await supabase
        .from("trips")
        .update({
            archived: true,
            updated_at: new Date().toISOString(),
        })
        .eq("id", tripId);

    if (error) {
        console.error("Error archiving trip:", error);
        return false;
    }

    revalidatePath("/app/trips");
    return true;
}

export async function deleteTrip(tripId: string): Promise<boolean> {
    const supabase = await createClient();

    const { error } = await supabase.from("trips").delete().eq("id", tripId);

    if (error) {
        console.error("Error deleting trip:", error);
        return false;
    }

    revalidatePath("/app/trips");
    return true;
}
