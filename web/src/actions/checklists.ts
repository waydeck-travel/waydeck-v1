"use server";

import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";

export interface ChecklistItem {
    id: string;
    trip_id: string;
    description: string;
    is_checked: boolean;
    group_name: string | null;
    sort_index: number;
    created_at: string;
    updated_at: string;
}

export async function getTripChecklist(tripId: string): Promise<ChecklistItem[]> {
    const supabase = await createClient();

    const { data, error } = await supabase
        .from("checklist_items")
        .select("*")
        .eq("trip_id", tripId)
        .order("is_checked", { ascending: true }) // Unchecked first
        .order("sort_index", { ascending: true });

    if (error) {
        console.error("Error fetching checklist items:", error);
        return [];
    }

    return data || [];
}

export async function addChecklistItem(
    tripId: string,
    description: string,
    groupName?: string
): Promise<ChecklistItem | null> {
    const supabase = await createClient();

    // Get max sort order
    const { data: maxOrderData } = await supabase
        .from("checklist_items")
        .select("sort_index")
        .eq("trip_id", tripId)
        .order("sort_index", { ascending: false })
        .limit(1)
        .single();

    const nextOrder = (maxOrderData?.sort_index || 0) + 100;

    const { data, error } = await supabase
        .from("checklist_items")
        .insert({
            trip_id: tripId,
            description,
            group_name: groupName || "General",
            sort_index: nextOrder,
            is_checked: false,
        })
        .select()
        .single();

    if (error) {
        console.error("Error adding checklist item:", error);
        return null;
    }

    revalidatePath(`/app/trips/${tripId}/checklist`);
    return data;
}

export async function toggleChecklistItem(
    itemId: string,
    tripId: string,
    checked: boolean
): Promise<boolean> {
    const supabase = await createClient();

    const { error } = await supabase
        .from("checklist_items")
        .update({ is_checked: checked })
        .eq("id", itemId);

    if (error) {
        console.error("Error toggling checklist item:", error);
        return false;
    }

    revalidatePath(`/app/trips/${tripId}/checklist`);
    return true;
}

export async function deleteChecklistItem(
    itemId: string,
    tripId: string
): Promise<boolean> {
    const supabase = await createClient();

    const { error } = await supabase
        .from("checklist_items")
        .delete()
        .eq("id", itemId);

    if (error) {
        console.error("Error deleting checklist item:", error);
        return false;
    }

    revalidatePath(`/app/trips/${tripId}/checklist`);
    return true;
}

export interface ChecklistTemplate {
    id: string;
    owner_id: string;
    name: string;
    description: string | null;
    created_at: string;
    updated_at: string;
}

export async function getChecklistTemplates(): Promise<ChecklistTemplate[]> {
    const supabase = await createClient();
    const { data: { user } } = await supabase.auth.getUser();

    if (!user) return [];

    const { data, error } = await supabase
        .from("checklist_templates")
        .select("*")
        .eq("owner_id", user.id)
        .order("created_at", { ascending: false });

    if (error) {
        console.error("Error fetching checklist templates:", error);
        return [];
    }

    return data || [];
}

export async function createChecklistTemplate(
    name: string,
    description?: string
): Promise<ChecklistTemplate | null> {
    const supabase = await createClient();
    const {
        data: { user },
    } = await supabase.auth.getUser();

    if (!user) return null;

    const { data, error } = await supabase
        .from("checklist_templates")
        .insert({
            owner_id: user.id,
            name,
            description,
        })
        .select()
        .single();

    if (error) {
        console.error("Error creating checklist template:", error);
        return null;
    }

    revalidatePath("/app/checklists");
    return data;
}

// Get single template by ID
export async function getChecklistTemplate(templateId: string): Promise<ChecklistTemplate | null> {
    const supabase = await createClient();
    const { data: { user } } = await supabase.auth.getUser();

    if (!user) return null;

    const { data, error } = await supabase
        .from("checklist_templates")
        .select("*")
        .eq("id", templateId)
        .eq("owner_id", user.id)
        .single();

    if (error) {
        console.error("Error fetching checklist template:", error);
        return null;
    }

    return data;
}

// Template item interface
export interface TemplateItem {
    id: string;
    template_id: string;
    description: string;
    sort_index: number;
    created_at: string;
}

// Get items for a template
export async function getTemplateItems(templateId: string): Promise<TemplateItem[]> {
    const supabase = await createClient();

    const { data, error } = await supabase
        .from("checklist_template_items")
        .select("*")
        .eq("template_id", templateId)
        .order("sort_index", { ascending: true });

    if (error) {
        console.error("Error fetching template items:", error);
        return [];
    }

    return data || [];
}

// Add item to template
export async function addTemplateItem(
    templateId: string,
    description: string
): Promise<TemplateItem | null> {
    const supabase = await createClient();

    // Get max sort order
    const { data: maxOrderData } = await supabase
        .from("checklist_template_items")
        .select("sort_index")
        .eq("template_id", templateId)
        .order("sort_index", { ascending: false })
        .limit(1)
        .single();

    const nextOrder = (maxOrderData?.sort_index || 0) + 100;

    const { data, error } = await supabase
        .from("checklist_template_items")
        .insert({
            template_id: templateId,
            description,
            sort_index: nextOrder,
        })
        .select()
        .single();

    if (error) {
        console.error("Error adding template item:", error);
        return null;
    }

    revalidatePath(`/app/checklists/${templateId}`);
    return data;
}

// Delete item from template
export async function deleteTemplateItem(
    itemId: string,
    templateId: string
): Promise<boolean> {
    const supabase = await createClient();

    const { error } = await supabase
        .from("checklist_template_items")
        .delete()
        .eq("id", itemId);

    if (error) {
        console.error("Error deleting template item:", error);
        return false;
    }

    revalidatePath(`/app/checklists/${templateId}`);
    return true;
}
