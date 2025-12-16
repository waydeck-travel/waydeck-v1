"use server";

import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";

export interface TripBudget {
    id: string;
    trip_id: string;
    category: string;
    budget_amount: number; // Fixed: column name in DB
    currency: string;
    created_at: string;
    updated_at: string;
}

export async function getTripBudgets(tripId: string): Promise<TripBudget[]> {
    const supabase = await createClient();

    const { data, error } = await supabase
        .from("trip_budgets")
        .select("*")
        .eq("trip_id", tripId);

    if (error) {
        console.error("Error fetching trip budgets:", error);
        return [];
    }

    return data || [];
}

export async function setTripBudget(
    tripId: string,
    category: string,
    amount: number,
    currency: string
): Promise<TripBudget | null> {
    const supabase = await createClient();

    // Upsert budget for category
    const { data, error } = await supabase
        .from("trip_budgets")
        .upsert(
            {
                trip_id: tripId,
                category: category.toLowerCase(), // Match constraint: lowercase
                budget_amount: amount, // Fixed: column is 'budget_amount', not 'amount'
                currency,
                updated_at: new Date().toISOString(),
            },
            { onConflict: "trip_id,category" } // Fixed: no space after comma
        )
        .select()
        .single();

    if (error) {
        console.error("Error setting trip budget:", error);
        return null;
    }

    revalidatePath(`/app/trips/${tripId}/budget`);
    return data;
}

// eslint-disable-next-line @typescript-eslint/no-unused-vars
export async function getTripExpensesSummary(_tripId: string) {
    // const supabase = await createClient();

    // Fetch expenses from all item types and custom expenses
    // This is a simplified implementation. Real world would need more complex query or view.



    // Correct approach needs to join through trip_items.
    // For now, let's just implement the budget actions.
    return {};
}
