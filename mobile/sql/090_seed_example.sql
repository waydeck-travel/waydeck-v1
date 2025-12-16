-- =============================================================================
-- Waydeck SQL Migration: 090_seed_example.sql
-- Purpose: Sample seed data for development and testing
-- =============================================================================
--
-- IMPORTANT: This file is for DEVELOPMENT ONLY.
-- Do NOT run in production.
--
-- Before running this seed, you need to:
-- 1. Create a user via Supabase Auth (sign up in your app or via dashboard)
-- 2. Replace 'YOUR_USER_ID_HERE' with the actual auth.users.id UUID
--
-- =============================================================================

-- Replace this with an actual user ID from your auth.users table
-- You can find this in Supabase Dashboard > Authentication > Users
DO $$
DECLARE
    v_user_id UUID := 'YOUR_USER_ID_HERE';  -- ⚠️ REPLACE THIS!
    v_trip_id UUID;
    v_item_flight1_id UUID;
    v_item_flight2_id UUID;
    v_item_hotel_id UUID;
    v_item_activity_id UUID;
BEGIN
    -- Skip if placeholder not replaced
    IF v_user_id = 'YOUR_USER_ID_HERE' THEN
        RAISE NOTICE 'Seed skipped: Replace YOUR_USER_ID_HERE with an actual user ID';
        RETURN;
    END IF;

    -- ==========================================================================
    -- Create Profile
    -- ==========================================================================
    INSERT INTO public.profiles (user_id, full_name)
    VALUES (v_user_id, 'Demo User')
    ON CONFLICT (user_id) DO UPDATE SET full_name = 'Demo User';

    -- ==========================================================================
    -- Create Trip: India → Vietnam & Thailand
    -- ==========================================================================
    INSERT INTO public.trips (
        id, owner_id, name, origin_city, origin_country_code,
        start_date, end_date, currency, notes
    ) VALUES (
        gen_random_uuid(),
        v_user_id,
        'India → Vietnam & Thailand',
        'Pune',
        'IN',
        '2025-01-15',
        '2025-01-25',
        'USD',
        'Winter trip to Southeast Asia. Remember to pack light!'
    )
    RETURNING id INTO v_trip_id;

    -- ==========================================================================
    -- Trip Item 1: Flight Mumbai → Bangkok
    -- ==========================================================================
    INSERT INTO public.trip_items (
        id, trip_id, type, title, description,
        start_time_utc, end_time_utc, local_tz, day_index, sort_index
    ) VALUES (
        gen_random_uuid(),
        v_trip_id,
        'transport',
        'Flight BOM → BKK',
        'IndiGo flight to Bangkok. Window seats booked.',
        '2025-01-15 03:00:00+00',  -- 08:30 IST
        '2025-01-15 08:15:00+00',  -- 13:45 IST (arrival in BKK local: 15:15)
        'Asia/Kolkata',
        0,
        0
    )
    RETURNING id INTO v_item_flight1_id;

    INSERT INTO public.transport_items (
        trip_item_id, mode, carrier_name, carrier_code, transport_number,
        booking_reference,
        origin_city, origin_country_code, origin_airport_code, origin_terminal,
        destination_city, destination_country_code, destination_airport_code, destination_terminal,
        departure_local, arrival_local,
        passenger_count, price, currency
    ) VALUES (
        v_item_flight1_id,
        'flight',
        'IndiGo',
        '6E',
        '6E 1053',
        'ABC123',
        'Mumbai',
        'IN',
        'BOM',
        '2',
        'Bangkok',
        'TH',
        'BKK',
        '1',
        '2025-01-15 08:30:00+05:30',
        '2025-01-15 15:15:00+07:00',
        2,
        450.00,
        'USD'
    );

    -- ==========================================================================
    -- Trip Item 2: Flight Bangkok → Da Nang
    -- ==========================================================================
    INSERT INTO public.trip_items (
        id, trip_id, type, title, description,
        start_time_utc, end_time_utc, local_tz, day_index, sort_index
    ) VALUES (
        gen_random_uuid(),
        v_trip_id,
        'transport',
        'Flight BKK → DAD',
        'Connecting flight to Da Nang',
        '2025-01-15 11:30:00+00',  -- 18:30 BKK local
        '2025-01-15 13:30:00+00',  -- 20:30 DAD local
        'Asia/Bangkok',
        0,
        1
    )
    RETURNING id INTO v_item_flight2_id;

    INSERT INTO public.transport_items (
        trip_item_id, mode, carrier_name, carrier_code, transport_number,
        booking_reference,
        origin_city, origin_country_code, origin_airport_code,
        destination_city, destination_country_code, destination_airport_code,
        departure_local, arrival_local,
        passenger_count, price, currency
    ) VALUES (
        v_item_flight2_id,
        'flight',
        'VietJet Air',
        'VJ',
        'VJ 901',
        'XYZ789',
        'Bangkok',
        'TH',
        'BKK',
        'Da Nang',
        'VN',
        'DAD',
        '2025-01-15 18:30:00+07:00',
        '2025-01-15 20:30:00+07:00',
        2,
        120.00,
        'USD'
    );

    -- ==========================================================================
    -- Trip Item 3: Hotel in Da Nang
    -- ==========================================================================
    INSERT INTO public.trip_items (
        id, trip_id, type, title, description,
        start_time_utc, end_time_utc, local_tz, day_index, sort_index
    ) VALUES (
        gen_random_uuid(),
        v_trip_id,
        'stay',
        'Fusion Maia Da Nang',
        'Beachfront resort with spa. All-inclusive breakfast.',
        '2025-01-15 14:00:00+00',  -- Check-in 21:00 local
        '2025-01-18 04:00:00+00',  -- Check-out 11:00 local
        'Asia/Ho_Chi_Minh',
        0,
        2
    )
    RETURNING id INTO v_item_hotel_id;

    INSERT INTO public.stay_items (
        trip_item_id, accommodation_name, address, city, country_code,
        checkin_local, checkout_local,
        has_breakfast, confirmation_number, booking_url,
        latitude, longitude
    ) VALUES (
        v_item_hotel_id,
        'Fusion Maia Da Nang',
        'Vo Nguyen Giap Street, Son Tra District',
        'Da Nang',
        'VN',
        '2025-01-15 21:00:00+07:00',
        '2025-01-18 11:00:00+07:00',
        true,
        'BOOK-2025-001',
        'https://booking.com/hotel/fusion-maia',
        16.0544,
        108.2478
    );

    -- ==========================================================================
    -- Trip Item 4: Activity - Ba Na Hills
    -- ==========================================================================
    INSERT INTO public.trip_items (
        id, trip_id, type, title, description,
        start_time_utc, end_time_utc, local_tz, day_index, sort_index, comment
    ) VALUES (
        gen_random_uuid(),
        v_trip_id,
        'activity',
        'Ba Na Hills Day Tour',
        'Full day tour including cable car, Golden Bridge, and French Village',
        '2025-01-16 01:00:00+00',  -- 08:00 local
        '2025-01-16 10:00:00+00',  -- 17:00 local
        'Asia/Ho_Chi_Minh',
        1,
        0,
        'Arrive 30 mins early for cable car. Bring jacket - it''s cold at the top!'
    )
    RETURNING id INTO v_item_activity_id;

    INSERT INTO public.activity_items (
        trip_item_id, category, location_name, address, city, country_code,
        start_local, end_local,
        booking_code, latitude, longitude
    ) VALUES (
        v_item_activity_id,
        'tour',
        'Ba Na Hills',
        'An Son, Hoa Ninh, Hoa Vang District',
        'Da Nang',
        'VN',
        '2025-01-16 08:00:00+07:00',
        '2025-01-16 17:00:00+07:00',
        'TOUR-BNH-001',
        15.9957,
        107.9875
    );

    -- ==========================================================================
    -- Document: Flight Ticket (placeholder - no actual file)
    -- ==========================================================================
    INSERT INTO public.documents (
        owner_id, trip_id, trip_item_id, doc_type,
        file_name, mime_type, storage_path, size_bytes
    ) VALUES (
        v_user_id,
        v_trip_id,
        v_item_flight1_id,
        'ticket',
        'indigo-ticket-bom-bkk.pdf',
        'application/pdf',
        format('%s/%s/%s/indigo-ticket-bom-bkk.pdf', v_user_id, v_trip_id, v_item_flight1_id),
        125000
    );

    RAISE NOTICE 'Seed completed! Trip ID: %', v_trip_id;
END
$$;
