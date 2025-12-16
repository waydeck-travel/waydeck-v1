export type TripItemType = "transport" | "stay" | "activity" | "note";

export type TransportMode =
    | "flight"
    | "train"
    | "bus"
    | "car"
    | "bike"
    | "cruise"
    | "metro"
    | "ferry"
    | "other";

export interface TripItem {
    id: string;
    trip_id: string;
    type: TripItemType;
    day_index: number;
    sort_index: number;
    created_at: string;
    updated_at: string;
}

export interface TransportItem extends TripItem {
    type: "transport";
    mode: TransportMode;
    carrier_name: string | null;
    carrier_code: string | null;
    transport_number: string | null;
    booking_reference: string | null;
    origin_city: string;
    origin_country: string;
    origin_airport_code: string | null;
    origin_terminal: string | null;
    destination_city: string;
    destination_country: string;
    destination_airport_code: string | null;
    destination_terminal: string | null;
    departure_time: string;
    arrival_time: string;
    notes: string | null;
}

export interface StayItem extends TripItem {
    type: "stay";
    property_name: string;
    address: string | null;
    city: string;
    country: string;
    check_in_date: string;
    check_in_time: string | null;
    check_out_date: string;
    check_out_time: string | null;
    confirmation_number: string | null;
    includes_breakfast: boolean;
    notes: string | null;
}

export interface ActivityItem extends TripItem {
    type: "activity";
    name: string;
    venue: string | null;
    address: string | null;
    city: string;
    country: string;
    start_time: string | null;
    end_time: string | null;
    confirmation_number: string | null;
    category: string | null;
    notes: string | null;
}

export interface NoteItem extends TripItem {
    type: "note";
    title: string;
    content: string;
}
