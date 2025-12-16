export interface Traveller {
    id: string;
    user_id: string;
    first_name: string;
    last_name: string;
    email: string | null;
    phone: string | null;
    date_of_birth: string | null;
    nationality: string | null;
    passport_number: string | null;
    passport_expiry: string | null;
    passport_country: string | null;
    avatar_url: string | null;
    notes: string | null;
    created_at: string;
    updated_at: string;
}
