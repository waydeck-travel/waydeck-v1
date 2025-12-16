"use server";

import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";

export interface Document {
    id: string;
    owner_id: string;
    trip_id: string | null;
    trip_item_id: string | null;
    doc_type: string;
    label: string | null;
    storage_path: string;
    mime_type: string | null;
    file_size: number | null;
    expires_at: string | null;
    created_at: string;
    updated_at: string;
}

export interface GlobalDocument {
    id: string;
    owner_id: string;
    doc_type: string;
    label: string | null;
    storage_path: string;
    mime_type: string | null;
    file_size: number | null;
    expires_at: string | null;
    country_code: string | null;
    created_at: string;
    updated_at: string;
}

export async function getTripDocuments(tripId: string): Promise<Document[]> {
    const supabase = await createClient();

    const { data, error } = await supabase
        .from("documents")
        .select("*")
        .eq("trip_id", tripId)
        .is("trip_item_id", null)
        .order("created_at", { ascending: false });

    if (error) {
        console.error("Error fetching trip documents:", error);
        return [];
    }

    return data || [];
}

export async function getItemDocuments(tripItemId: string): Promise<Document[]> {
    const supabase = await createClient();

    const { data, error } = await supabase
        .from("documents")
        .select("*")
        .eq("trip_item_id", tripItemId)
        .order("created_at", { ascending: false });

    if (error) {
        console.error("Error fetching item documents:", error);
        return [];
    }

    return data || [];
}

export async function getGlobalDocuments(): Promise<GlobalDocument[]> {
    const supabase = await createClient();

    const {
        data: { user },
    } = await supabase.auth.getUser();

    if (!user) return [];

    // CHECK SCHEMA
    const { error: colError } = await supabase.from("global_documents").select("user_id").limit(1);

    const { data, error } = await supabase
        .from("global_documents")
        .select("*")
        .eq("owner_id", user.id)
        .order("created_at", { ascending: false });

    if (error) {
        console.error("Error fetching global documents:", error);
        // Fallback or detailed error logging
        if (error.code === '42703') { // Undefined column
            console.error("Column mismatch detected!");
        }
        return [];
    }

    return data || [];
}

export async function deleteDocument(documentId: string, tripId?: string): Promise<boolean> {
    const supabase = await createClient();

    const { error } = await supabase.from("documents").delete().eq("id", documentId);

    if (error) {
        console.error("Error deleting document:", error);
        return false;
    }

    if (tripId) {
        revalidatePath(`/app/trips/${tripId}`);
    }
    revalidatePath("/app/documents");
    return true;
}

export async function deleteGlobalDocument(documentId: string): Promise<boolean> {
    const supabase = await createClient();

    const { error } = await supabase.from("global_documents").delete().eq("id", documentId);

    if (error) {
        console.error("Error deleting global document:", error);
        return false;
    }

    revalidatePath("/app/documents");
    return true;
}

export async function getSignedUrl(storagePath: string): Promise<string | null> {
    const supabase = await createClient();

    // Determine bucket from path
    const bucket = storagePath.startsWith("global_documents/")
        ? "global_documents"
        : "documents";

    const path = storagePath.replace(`${bucket}/`, "");

    const { data, error } = await supabase.storage.from(bucket).createSignedUrl(path, 3600);

    if (error) {
        console.error("Error getting signed URL:", error);
        return null;
    }

    return data.signedUrl;
}

export interface UploadDocumentParams {
    tripId: string;
    tripItemId?: string;
    docType: string;
    label?: string;
    expiresAt?: string;
    file: File;
}

export async function uploadDocument(formData: FormData): Promise<Document | null> {
    const supabase = await createClient();

    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return null;

    const file = formData.get("file") as File;
    const tripId = formData.get("tripId") as string;
    const tripItemId = formData.get("tripItemId") as string | null;
    const docType = formData.get("docType") as string;
    const label = formData.get("label") as string;
    const expiresAt = formData.get("expiresAt") as string | null;

    if (!file || !tripId || !docType) {
        console.error("Missing required fields for uploadDocument");
        return null;
    }

    // Generate unique filename
    const ext = file.name.split(".").pop() || "file";
    const filename = `${user.id}/${tripId}/${Date.now()}-${Math.random().toString(36).slice(2)}.${ext}`;

    // Upload to storage
    const { error: uploadError } = await supabase.storage
        .from("documents")
        .upload(filename, file, {
            contentType: file.type,
            upsert: false,
        });

    if (uploadError) {
        console.error("Error uploading document:", uploadError);
        return null;
    }

    // Create database record
    const { data, error } = await supabase
        .from("documents")
        .insert({
            owner_id: user.id,
            trip_id: tripId,
            trip_item_id: tripItemId || null,
            doc_type: docType,
            label: label || file.name,
            storage_path: `documents/${filename}`,
            mime_type: file.type,
            file_size: file.size,
            expires_at: expiresAt || null,
        })
        .select()
        .single();

    if (error) {
        console.error("Error creating document record:", error);
        // Try to clean up uploaded file
        await supabase.storage.from("documents").remove([filename]);
        return null;
    }

    revalidatePath(`/app/trips/${tripId}`);
    revalidatePath(`/app/trips/${tripId}/documents`);
    return data;
}

export interface UploadGlobalDocumentParams {
    docType: string;
    label?: string;
    expiresAt?: string;
    countryCode?: string;
    file: File;
}

export async function uploadGlobalDocument(formData: FormData): Promise<GlobalDocument | null> {
    const supabase = await createClient();

    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
        return null;
    }

    const file = formData.get("file") as File;
    const docType = formData.get("docType") as string;
    const label = formData.get("label") as string;
    const expiresAt = formData.get("expiresAt") as string | null;
    const countryCode = formData.get("countryCode") as string | null;

    if (!file || !docType) {
        console.error("Missing required fields for uploadGlobalDocument");
        return null;
    }

    // Generate unique filename
    const ext = file.name.split(".").pop() || "file";
    const filename = `${user.id}/${Date.now()}-${Math.random().toString(36).slice(2)}.${ext}`;

    // Upload to storage
    const { error: uploadError } = await supabase.storage
        .from("global_documents")
        .upload(filename, file, {
            contentType: file.type,
            upsert: false,
        });

    if (uploadError) {
        console.error("Error uploading global document:", uploadError);
        return null;
    }

    // Create database record
    const payload = {
        owner_id: user.id,
        doc_type: docType,
        label: label || file.name,
        storage_path: `global_documents/${filename}`,
        mime_type: file.type,
        file_size: file.size,
        expires_at: expiresAt || null,
        country_code: countryCode || null,
    };

    const { data, error } = await supabase
        .from("global_documents")
        .insert(payload)
        .select()
        .single();

    if (error) {
        console.error("Error creating global document record:", error);
        // Try to clean up uploaded file
        await supabase.storage.from("global_documents").remove([filename]);
        return null;
    }

    revalidatePath("/app/documents");
    return data;
}
