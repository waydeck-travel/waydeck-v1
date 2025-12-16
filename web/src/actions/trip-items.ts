"use server";

import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";

export interface TripItemBase {
    id: string;
    trip_id: string;
    type: "transport" | "stay" | "activity" | "note";
    title: string;
    description: string | null;
    start_time_utc: string | null;
    end_time_utc: string | null;
    local_tz: string | null;
    day_index: number | null;
    sort_index: number;
    comment: string | null;
    created_at: string;
    updated_at: string;
}

export interface TransportDetails {
    trip_item_id: string;
    mode: string;
    carrier_name: string | null;
    carrier_code: string | null;
    transport_number: string | null;
    booking_reference: string | null;
    origin_city: string | null;
    origin_country_code: string | null;
    origin_airport_code: string | null;
    origin_terminal: string | null;
    destination_city: string | null;
    destination_country_code: string | null;
    destination_airport_code: string | null;
    destination_terminal: string | null;
    departure_local: string | null;
    arrival_local: string | null;
    passenger_count: number | null;
    price: number | null;
    currency: string | null;
    expense_amount: number | null;
    expense_currency: string | null;
    payment_status: string | null;
}

export interface StayDetails {
    trip_item_id: string;
    accommodation_name: string;
    address: string | null;
    city: string | null;
    country_code: string | null;
    checkin_local: string | null;
    checkout_local: string | null;
    has_breakfast: boolean;
    confirmation_number: string | null;
    booking_url: string | null;
    expense_amount: number | null;
    expense_currency: string | null;
    payment_status: string | null;
}

export interface ActivityDetails {
    trip_item_id: string;
    category: string | null;
    location_name: string | null;
    address: string | null;
    city: string | null;
    country_code: string | null;
    start_local: string | null;
    end_local: string | null;
    booking_code: string | null;
    booking_url: string | null;
    expense_amount: number | null;
    expense_currency: string | null;
    payment_status: string | null;
}

export interface TripItemWithDetails extends TripItemBase {
    transport_items?: TransportDetails[];
    stay_items?: StayDetails[];
    activity_items?: ActivityDetails[];
    documents?: { count: number }[];
}

export async function getTripItems(tripId: string): Promise<TripItemWithDetails[]> {
    const supabase = await createClient();

    const { data: items, error } = await supabase
        .from("trip_items")
        .select(`
            *,
            transport_items (*),
            stay_items (*),
            activity_items (*),
            documents (count)
        `)
        .eq("trip_id", tripId)
        .order("start_time_utc", { ascending: true });

    if (error) {
        console.error("Error fetching trip items:", error);
        return [];
    }

    // Batch fetch document counts in single query (fixes N+1)
    const itemIds = (items || []).map((i) => i.id);
    const { data: docCounts } = await supabase
        .from("documents")
        .select("trip_item_id")
        .in("trip_item_id", itemIds);

    // Aggregate counts per item
    const countMap = new Map<string, number>();
    docCounts?.forEach((d) =>
        countMap.set(d.trip_item_id, (countMap.get(d.trip_item_id) || 0) + 1)
    );

    const itemsWithDocCounts = (items || []).map((item) => ({
        ...item,
        documents: [{ count: countMap.get(item.id) || 0 }],
    }));

    return itemsWithDocCounts;
}

export async function getTripWithDetails(tripId: string) {
    const supabase = await createClient();

    // Get trip basic info
    const { data: trip, error: tripError } = await supabase
        .from("trips")
        .select("*")
        .eq("id", tripId)
        .single();

    if (tripError || !trip) {
        console.error("Error fetching trip:", tripError);
        return null;
    }

    // Get counts efficiently with single query for items + one for documents
    const [itemsResult, documentCount] = await Promise.all([
        supabase.from("trip_items").select("type").eq("trip_id", tripId),
        supabase
            .from("documents")
            .select("*", { count: "exact", head: true })
            .eq("trip_id", tripId),
    ]);

    // Aggregate counts by type client-side
    const counts = { transport: 0, stay: 0, activity: 0, note: 0 };
    itemsResult.data?.forEach((item) => {
        if (item.type in counts) {
            counts[item.type as keyof typeof counts]++;
        }
    });

    // Get cities from transport items
    const { data: transportItems } = await supabase
        .from("trip_items")
        .select(
            `
            transport_items(origin_city, destination_city)
        `
        )
        .eq("trip_id", tripId)
        .eq("type", "transport");

    const cities: string[] = [];
    transportItems?.forEach((item: { transport_items?: { origin_city?: string | null; destination_city?: string | null } | { origin_city?: string | null; destination_city?: string | null }[] | null }) => {
        // transport_items might be an object (single) or array (multiple) depending on Supabase response
        const transportData = item.transport_items;
        if (!transportData) return;

        const transportArray = Array.isArray(transportData) ? transportData : [transportData];
        transportArray.forEach((t) => {
            if (t.origin_city && !cities.includes(t.origin_city)) cities.push(t.origin_city);
            if (t.destination_city && !cities.includes(t.destination_city)) cities.push(t.destination_city);
        });
    });

    return {
        ...trip,
        transport_count: counts.transport,
        stay_count: counts.stay,
        activity_count: counts.activity,
        note_count: counts.note,
        document_count: documentCount.count || 0,
        cities,
    };
}

export async function getItemById(itemId: string): Promise<TripItemWithDetails | null> {
    const supabase = await createClient();

    const { data: item, error } = await supabase
        .from("trip_items")
        .select(`
            *,
            transport_items (*),
            stay_items (*),
            activity_items (*),
            documents (count)
        `)
        .eq("id", itemId)
        .single();

    if (error || !item) {
        console.error("Error fetching trip item:", error);
        return null;
    }

    // Get document count
    const { count } = await supabase
        .from("documents")
        .select("*", { count: "exact", head: true })
        .eq("trip_item_id", item.id);

    return {
        ...item,
        documents: [{ count: count || 0 }],
    };
}

export async function deleteTripItem(itemId: string, tripId: string): Promise<boolean> {
    const supabase = await createClient();

    const { error } = await supabase.from("trip_items").delete().eq("id", itemId);

    if (error) {
        console.error("Error deleting trip item:", error);
        return false;
    }

    revalidatePath(`/app/trips/${tripId}`);
    return true;
}
