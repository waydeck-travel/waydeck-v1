import { notFound } from "next/navigation";
import Link from "next/link";
import { ArrowLeft, CheckSquare, Import } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { getTrip } from "@/actions/trips";
import { getTripChecklist } from "@/actions/checklists";
import { AddChecklistItemDialog } from "@/components/trips/add-checklist-item-dialog";
import { ChecklistList } from "@/components/trips/checklist-list";

interface ChecklistPageProps {
    params: Promise<{ tripId: string }>;
}

export default async function TripChecklistPage({ params }: ChecklistPageProps) {
    const { tripId } = await params;
    const [trip, items] = await Promise.all([
        getTrip(tripId),
        getTripChecklist(tripId),
    ]);

    if (!trip) {
        notFound();
    }

    const totalItems = items.length;
    const completedItems = items.filter((i) => i.is_checked).length;
    const progress = totalItems > 0 ? (completedItems / totalItems) * 100 : 0;

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
                    <h1 className="text-2xl font-bold">Checklist</h1>
                    <p className="text-muted-foreground">{trip.name}</p>
                </div>
                <div className="flex gap-2">
                    <Button variant="outline" size="sm" disabled>
                        <Import className="h-4 w-4 mr-1" />
                        Import
                    </Button>
                    <AddChecklistItemDialog tripId={tripId} />
                </div>
            </div>

            {/* Progress */}
            <div className="space-y-2">
                <div className="flex justify-between text-sm">
                    <span className="text-muted-foreground">Progress</span>
                    <span className="font-medium">{Math.round(progress)}%</span>
                </div>
                <Progress value={progress} className="h-2" />
            </div>

            {/* Items */}
            {items.length === 0 ? (
                <div className="text-center py-12">
                    <div className="rounded-full bg-muted p-4 mx-auto w-fit mb-4">
                        <CheckSquare className="h-8 w-8 text-muted-foreground" />
                    </div>
                    <h3 className="text-lg font-semibold mb-1">No items yet</h3>
                    <p className="text-sm text-muted-foreground mb-4">
                        Add items to your checklist to keep track of your packing.
                    </p>
                    <AddChecklistItemDialog tripId={tripId} />
                </div>
            ) : (
                <ChecklistList items={items} tripId={tripId} />
            )}
        </div>
    );
}
