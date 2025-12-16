import { notFound } from "next/navigation";
import Link from "next/link";
import { ArrowLeft, FileText, Plus, Upload } from "lucide-react";
import { Button } from "@/components/ui/button";
import { DocumentGrid } from "@/components/documents/document-grid";
import { UploadDocumentDialog } from "@/components/documents/upload-document-dialog";
import { getTripDocuments } from "@/actions/documents";
import { getTrip } from "@/actions/trips";

interface DocumentsPageProps {
    params: Promise<{ tripId: string }>;
}

export default async function TripDocumentsPage({ params }: DocumentsPageProps) {
    const { tripId } = await params;

    const [trip, documents] = await Promise.all([
        getTrip(tripId),
        getTripDocuments(tripId),
    ]);

    if (!trip) {
        notFound();
    }

    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex items-start gap-4">
                <Button variant="ghost" size="icon" asChild>
                    <Link href={`/app/trips/${tripId}`}>
                        <ArrowLeft className="h-4 w-4" />
                    </Link>
                </Button>
                <div className="flex-1">
                    <h1 className="text-2xl font-bold">Documents</h1>
                    <p className="text-muted-foreground">{trip.name}</p>
                </div>
                <UploadDocumentDialog type="trip" tripId={tripId} />
            </div>

            {/* Documents Grid */}
            <DocumentGrid documents={documents} type="trip" tripId={tripId} />
        </div>
    );
}
