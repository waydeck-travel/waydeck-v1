"use server";

import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";
import { Traveller } from "@/types/traveller";

export async function getTravellers(): Promise<Traveller[]> {
    const supabase = await createClient();
    const {
        data: { user },
    } = await supabase.auth.getUser();

    if (!user) return [];

    const { data, error } = await supabase
        .from("travellers")
        .select("*")
        .eq("owner_id", user.id)
        .order("first_name", { ascending: true });

    if (error) {
        console.error("Error fetching travellers:", error);
        return [];
    }

    return data || [];
}

export type CreateTravellerInput = Omit<
    Traveller,
    "id" | "owner_id" | "created_at" | "updated_at"
>;

export type TravellerResult =
    | { success: true; data: Traveller }
    | { success: false; error: string };

export async function createTraveller(input: CreateTravellerInput): Promise<TravellerResult> {
    const supabase = await createClient();
    const {
        data: { user },
    } = await supabase.auth.getUser();

    if (!user) {
        return { success: false, error: "Not authenticated" };
    }

    const { data, error } = await supabase
        .from("travellers")
        .insert({
            owner_id: user.id,
            ...input,
        })
        .select()
        .single();

    if (error) {
        console.error("Error creating traveller:", error);
        return { success: false, error: `${error.message} (code: ${error.code})` };
    }

    revalidatePath("/app/travellers");
    return { success: true, data };
}

export async function updateTraveller(
    id: string,
    input: Partial<CreateTravellerInput>
): Promise<boolean> {
    const supabase = await createClient();

    const { error } = await supabase
        .from("travellers")
        .update({
            ...input,
            updated_at: new Date().toISOString(),
        })
        .eq("id", id);

    if (error) {
        console.error("Error updating traveller:", error);
        return false;
    }

    revalidatePath("/app/travellers");
    return true;
}

export async function deleteTraveller(id: string): Promise<boolean> {
    const supabase = await createClient();

    const { error } = await supabase.from("travellers").delete().eq("id", id);

    if (error) {
        console.error("Error deleting traveller:", error);
        return false;
    }

    revalidatePath("/app/travellers");
    return true;
}
