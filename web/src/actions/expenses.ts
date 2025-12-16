"use server";

import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";

export interface ExpenseItem {
    id: string;
    description: string;
    amount: number;
    currency: string;
    category: string;
    date: string;
    type: "transport" | "stay" | "activity" | "custom";
}

export async function getTripExpenses(tripId: string): Promise<ExpenseItem[]> {
    const supabase = await createClient();

    const expenses: ExpenseItem[] = [];

    // 1. Fetch Transport Expenses
    const { data: transportItems } = await supabase
        .from("transport_items")
        .select(`
            trip_item_id,
            price,
            currency,
            trip_items (
                title,
                start_time_utc
            )
        `)
        // We need to join via trip_items to filter by trip_id, but supabase query syntax is tricky for deep filtering
        // So we might fetch filtered by trip_id if we can, or filtering in join.
        // Easier: fetch trip_items first then join? No, performant way:
        .eq("trip_items.trip_id", tripId) // This requires inner join filter which Supabase supports if set up
    // Actually, simpler to select from trip_items where type=transport and include transport_items
    // Let's try selecting from trip_items joined with subtypes

    // Alternative: standard way
    const { data: items, error } = await supabase
        .from("trip_items")
        .select(`
            id,
            type,
            title,
            start_time_utc,
            transport_items (
                price,
                expense_amount,
                currency,
                expense_currency
            ),
            stay_items (
                price,
                expense_amount,
                currency,
                expense_currency
            ),
            activity_items (
                price,
                expense_amount,
                currency,
                expense_currency
            )
        `) // Assuming stay/activity also have price since spec mentioned adding them
        .eq("trip_id", tripId);

    if (items) {
        items.forEach((item) => {
            let amount = 0;
            let currency = "USD";

            if (item.type === "transport" && item.transport_items) {
                // @ts-ignore
                const details = Array.isArray(item.transport_items) ? item.transport_items[0] : item.transport_items;
                if (details) {
                    amount = details.expense_amount || details.price || 0;
                    currency = details.expense_currency || details.currency || "USD";
                }
            } else if (item.type === "stay" && item.stay_items) {
                // @ts-ignore
                const details = Array.isArray(item.stay_items) ? item.stay_items[0] : item.stay_items;
                if (details) {
                    amount = details.expense_amount || details.price || 0;
                    currency = details.expense_currency || details.currency || "USD";
                }
            }
            else if (item.type === "activity" && item.activity_items) {
                // @ts-ignore
                const details = Array.isArray(item.activity_items) ? item.activity_items[0] : item.activity_items;
                if (details) {
                    amount = details.expense_amount || details.price || 0;
                    currency = details.expense_currency || details.currency || "USD";
                }
            }

            if (amount > 0) {
                expenses.push({
                    id: item.id,
                    description: item.title,
                    amount,
                    currency,
                    category: item.type === "stay" ? "Accommodation" : (item.type.charAt(0).toUpperCase() + item.type.slice(1)),
                    date: item.start_time_utc || new Date().toISOString(),
                    type: item.type as any,
                });
            }
        });
    }

    // 2. Fetch Custom Expenses
    const { data: customExpenses } = await supabase
        .from("trip_expenses")
        .select("*")
        .eq("trip_id", tripId);

    if (customExpenses) {
        customExpenses.forEach((e) => {
            expenses.push({
                id: e.id,
                description: e.description,
                amount: e.amount,
                currency: e.currency,
                category: e.category,
                date: e.expense_date || new Date().toISOString(), // Fixed: column is expense_date
                type: "custom",
            });
        });
    }

    // Sort by date descending
    return expenses.sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());
}

export async function addCustomExpense(
    tripId: string,
    description: string,
    amount: number,
    currency: string,
    category: string,
    date: string
): Promise<boolean> {
    const supabase = await createClient();

    const { error } = await supabase
        .from("trip_expenses")
        .insert({
            trip_id: tripId,
            description,
            amount,
            currency,
            category: category.toLowerCase(), // Match constraint: lowercase
            expense_date: date, // Fixed: column is 'expense_date', not 'date'
        });

    if (error) {
        console.error("Error adding custom expense:", error);
        return false;
    }

    revalidatePath(`/app/trips/${tripId}/expenses`);
    return true;
}
