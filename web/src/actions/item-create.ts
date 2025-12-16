"use server";

import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";

export interface CreateTransportInput {
    trip_id: string;
    title: string;
    description?: string;
    day_index?: number;
    mode: string;
    carrier_name?: string;
    carrier_code?: string;
    transport_number?: string;
    booking_reference?: string;
    origin_city?: string;
    origin_country_code?: string;
    origin_airport_code?: string;
    origin_terminal?: string;
    destination_city?: string;
    destination_country_code?: string;
    destination_airport_code?: string;
    destination_terminal?: string;
    departure_local?: string;
    arrival_local?: string;
    passenger_count?: number;
    expense_amount?: number;
    expense_currency?: string;
    payment_status?: string;
}

export interface CreateStayInput {
    trip_id: string;
    title: string;
    description?: string;
    day_index?: number;
    accommodation_name: string;
    address?: string;
    city?: string;
    country_code?: string;
    checkin_local?: string;
    checkout_local?: string;
    has_breakfast?: boolean;
    confirmation_number?: string;
    booking_url?: string;
    expense_amount?: number;
    expense_currency?: string;
    payment_status?: string;
}

export interface CreateActivityInput {
    trip_id: string;
    title: string;
    description?: string;
    day_index?: number;
    category?: string;
    location_name?: string;
    address?: string;
    city?: string;
    country_code?: string;
    start_local?: string;
    end_local?: string;
    booking_code?: string;
    booking_url?: string;
    expense_amount?: number;
    expense_currency?: string;
    payment_status?: string;
}

export interface CreateNoteInput {
    trip_id: string;
    title: string;
    description?: string;
    day_index?: number;
}

// Get max sort index for a trip
async function getNextSortIndex(tripId: string, dayIndex: number | null): Promise<number> {
    const supabase = await createClient();

    const query = supabase
        .from("trip_items")
        .select("sort_index")
        .eq("trip_id", tripId)
        .order("sort_index", { ascending: false })
        .limit(1);

    if (dayIndex !== null) {
        query.eq("day_index", dayIndex);
    }

    const { data } = await query;
    return (data?.[0]?.sort_index ?? -1) + 1;
}

export async function createTransportItem(input: CreateTransportInput): Promise<{ id: string } | null> {
    const supabase = await createClient();

    const sortIndex = await getNextSortIndex(input.trip_id, input.day_index ?? null);

    // Create base trip item
    const { data: tripItem, error: itemError } = await supabase
        .from("trip_items")
        .insert({
            trip_id: input.trip_id,
            type: "transport",
            title: input.title,
            description: input.description || null,
            day_index: input.day_index ?? null,
            sort_index: sortIndex,
        })
        .select("id")
        .single();

    if (itemError || !tripItem) {
        console.error("Error creating trip item:", itemError);
        return null;
    }

    // DEBUG: Check if transport_items has owner_id column
    const { error: colError } = await supabase.from("transport_items").select("owner_id").limit(1);
    const hasOwnerId = !colError;

    // Get user id
    const { data: { user } } = await supabase.auth.getUser();

    const payload: Record<string, unknown> = {
        trip_item_id: tripItem.id,
        mode: input.mode,
        carrier_name: input.carrier_name || null,
        carrier_code: input.carrier_code || null,
        transport_number: input.transport_number || null,
        booking_reference: input.booking_reference || null,
        origin_city: input.origin_city || null,
        origin_country_code: input.origin_country_code || null,
        origin_airport_code: input.origin_airport_code || null,
        origin_terminal: input.origin_terminal || null,
        destination_city: input.destination_city || null,
        destination_country_code: input.destination_country_code || null,
        destination_airport_code: input.destination_airport_code || null,
        destination_terminal: input.destination_terminal || null,
        departure_local: input.departure_local || null,
        arrival_local: input.arrival_local || null,
        passenger_count: input.passenger_count || null,
        // Legacy
        price: input.expense_amount || null,
        currency: input.expense_currency || null,
        // New
        expense_amount: input.expense_amount || null,
        expense_currency: input.expense_currency || null,
        payment_status: input.payment_status || null,
    };

    if (hasOwnerId && user) {
        payload.owner_id = user.id;
    }

    const { error: transportError } = await supabase.from("transport_items").insert(payload);

    if (transportError) {
        console.error("Error creating transport details:", transportError);
        // Rollback: delete the trip item
        await supabase.from("trip_items").delete().eq("id", tripItem.id);
        return null;
    }

    revalidatePath(`/app/trips/${input.trip_id}`);
    return { id: tripItem.id };
}

export async function createStayItem(input: CreateStayInput): Promise<{ id: string } | null> {
    const supabase = await createClient();

    const sortIndex = await getNextSortIndex(input.trip_id, input.day_index ?? null);

    const { data: tripItem, error: itemError } = await supabase
        .from("trip_items")
        .insert({
            trip_id: input.trip_id,
            type: "stay",
            title: input.title,
            description: input.description || null,
            day_index: input.day_index ?? null,
            sort_index: sortIndex,
        })
        .select("id")
        .single();

    if (itemError || !tripItem) {
        console.error("Error creating trip item:", itemError);
        return null;
    }

    // DEBUG: Check if stay_items has owner_id
    const { error: colError } = await supabase.from("stay_items").select("owner_id").limit(1);
    const hasOwnerId = !colError;
    const { data: { user } } = await supabase.auth.getUser();

    const payload: Record<string, unknown> = {
        trip_item_id: tripItem.id,
        accommodation_name: input.accommodation_name,
        address: input.address || null,
        city: input.city || null,
        country_code: input.country_code || null,
        checkin_local: input.checkin_local || null,
        checkout_local: input.checkout_local || null,
        has_breakfast: input.has_breakfast ?? false,
        confirmation_number: input.confirmation_number || null,
        booking_url: input.booking_url || null,
        // Legacy
        price: input.expense_amount || null,
        currency: input.expense_currency || null,
        // New
        expense_amount: input.expense_amount || null,
        expense_currency: input.expense_currency || null,
        payment_status: input.payment_status || null,
    };
    if (hasOwnerId && user) payload.owner_id = user.id;

    const { error: stayError } = await supabase.from("stay_items").insert(payload);

    if (stayError) {
        console.error("Error creating stay details:", stayError);
        await supabase.from("trip_items").delete().eq("id", tripItem.id);
        return null;
    }

    revalidatePath(`/app/trips/${input.trip_id}`);
    return { id: tripItem.id };
}

export async function createActivityItem(input: CreateActivityInput): Promise<{ id: string } | null> {
    const supabase = await createClient();

    const sortIndex = await getNextSortIndex(input.trip_id, input.day_index ?? null);

    const { data: tripItem, error: itemError } = await supabase
        .from("trip_items")
        .insert({
            trip_id: input.trip_id,
            type: "activity",
            title: input.title,
            description: input.description || null,
            day_index: input.day_index ?? null,
            sort_index: sortIndex,
        })
        .select("id")
        .single();

    if (itemError || !tripItem) {
        console.error("Error creating trip item:", itemError);
        return null;
    }

    // DEBUG: Check if activity_items has owner_id
    const { error: colError } = await supabase.from("activity_items").select("owner_id").limit(1);
    const hasOwnerId = !colError;
    const { data: { user } } = await supabase.auth.getUser();

    const payload: Record<string, unknown> = {
        trip_item_id: tripItem.id,
        category: input.category || null,
        location_name: input.location_name || null,
        address: input.address || null,
        city: input.city || null,
        country_code: input.country_code || null,
        start_local: input.start_local || null,
        end_local: input.end_local || null,
        booking_code: input.booking_code || null,
        booking_url: input.booking_url || null,
        // Legacy
        price: input.expense_amount || null,
        currency: input.expense_currency || null,
        // New
        expense_amount: input.expense_amount || null,
        expense_currency: input.expense_currency || null,
        payment_status: input.payment_status || null,
    };
    if (hasOwnerId && user) payload.owner_id = user.id;

    const { error: activityError } = await supabase.from("activity_items").insert(payload);

    if (activityError) {
        console.error("Error creating activity details:", activityError);
        await supabase.from("trip_items").delete().eq("id", tripItem.id);
        return null;
    }

    revalidatePath(`/app/trips/${input.trip_id}`);
    return { id: tripItem.id };
}

export async function createNoteItem(input: CreateNoteInput): Promise<{ id: string } | null> {
    const supabase = await createClient();

    const sortIndex = await getNextSortIndex(input.trip_id, input.day_index ?? null);

    const { data: tripItem, error: itemError } = await supabase
        .from("trip_items")
        .insert({
            trip_id: input.trip_id,
            type: "note",
            title: input.title,
            description: input.description || null,
            day_index: input.day_index ?? null,
            sort_index: sortIndex,
        })
        .select("id")
        .single();

    if (itemError || !tripItem) {
        console.error("Error creating note:", itemError);
        return null;
    }

    revalidatePath(`/app/trips/${input.trip_id}`);
    return { id: tripItem.id };
}
