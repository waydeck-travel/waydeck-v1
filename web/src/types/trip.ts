export type TripStatus = "planned" | "active" | "completed" | "archived";

export interface Trip {
    id: string;
    owner_id: string;
    name: string;
    origin_city: string | null;
    origin_country_code: string | null;
    start_date: string | null;
    end_date: string | null;
    currency: string | null;
    notes: string | null;
    archived: boolean;
    created_at: string;
    updated_at: string;
}

export interface TripWithCounts extends Trip {
    transport_count: number;
    stay_count: number;
    activity_count: number;
    note_count: number;
    document_count: number;
}
