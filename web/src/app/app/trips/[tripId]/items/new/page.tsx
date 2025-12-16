"use client";

import { useSearchParams } from "next/navigation";
import { TransportForm } from "@/components/forms/transport-form";
import { StayForm } from "@/components/forms/stay-form";
import { ActivityForm } from "@/components/forms/activity-form";
import { NoteForm } from "@/components/forms/note-form";
import { use } from "react";

interface NewItemPageProps {
    params: Promise<{ tripId: string }>;
}

export default function NewItemPage({ params }: NewItemPageProps) {
    const { tripId } = use(params);
    const searchParams = useSearchParams();
    const type = searchParams.get("type") || "transport";

    switch (type) {
        case "transport":
            return <TransportForm tripId={tripId} />;
        case "stay":
            return <StayForm tripId={tripId} />;
        case "activity":
            return <ActivityForm tripId={tripId} />;
        case "note":
            return <NoteForm tripId={tripId} />;
        default:
            return <TransportForm tripId={tripId} />;
    }
}
