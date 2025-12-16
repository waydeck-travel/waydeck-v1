"use client";

import Link from "next/link";
import { useState } from "react";
import {
    Plane,
    Hotel,
    Ticket,
    FileText,
    MoreVertical,
    Pencil,
    Share2,
    Archive,
    Trash2,
    MapPin,
    Calendar,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import {
    Card,
    CardContent,
    CardDescription,
    CardHeader,
    CardTitle,
} from "@/components/ui/card";
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuSeparator,
    DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import {
    AlertDialog,
    AlertDialogAction,
    AlertDialogCancel,
    AlertDialogContent,
    AlertDialogDescription,
    AlertDialogFooter,
    AlertDialogHeader,
    AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import { Badge } from "@/components/ui/badge";
import { formatDateRange, isTripActive, getDurationDays } from "@/lib/dates";
import { archiveTrip, deleteTrip } from "@/actions/trips";
import type { TripWithCounts } from "@/types";
import { toast } from "sonner";

interface TripCardProps {
    trip: TripWithCounts;
}

export function TripCard({ trip }: TripCardProps) {
    const [showArchiveDialog, setShowArchiveDialog] = useState(false);
    const [showDeleteDialog, setShowDeleteDialog] = useState(false);
    const [isLoading, setIsLoading] = useState(false);

    const isActive = isTripActive(trip.start_date, trip.end_date);
    const duration = getDurationDays(trip.start_date, trip.end_date);

    const handleArchive = async () => {
        setIsLoading(true);
        const success = await archiveTrip(trip.id);
        setIsLoading(false);
        setShowArchiveDialog(false);
        if (success) {
            toast.success("Trip archived");
        } else {
            toast.error("Failed to archive trip");
        }
    };

    const handleDelete = async () => {
        setIsLoading(true);
        const success = await deleteTrip(trip.id);
        setIsLoading(false);
        setShowDeleteDialog(false);
        if (success) {
            toast.success("Trip deleted");
        } else {
            toast.error("Failed to delete trip");
        }
    };

    return (
        <>
            <Card className="overflow-hidden hover:shadow-md transition-shadow">
                <CardHeader className="pb-2">
                    <div className="flex items-start justify-between">
                        <Link href={`/app/trips/${trip.id}`} className="flex-1 min-w-0">
                            <CardTitle className="text-lg truncate hover:text-primary transition-colors">
                                {trip.name}
                            </CardTitle>
                        </Link>
                        <DropdownMenu>
                            <DropdownMenuTrigger asChild>
                                <Button variant="ghost" size="icon" className="shrink-0 -mr-2">
                                    <MoreVertical className="h-4 w-4" />
                                </Button>
                            </DropdownMenuTrigger>
                            <DropdownMenuContent align="end">
                                <DropdownMenuItem asChild>
                                    <Link href={`/app/trips/${trip.id}/edit`}>
                                        <Pencil className="h-4 w-4 mr-2" />
                                        Edit
                                    </Link>
                                </DropdownMenuItem>
                                <DropdownMenuItem>
                                    <Share2 className="h-4 w-4 mr-2" />
                                    Share
                                </DropdownMenuItem>
                                <DropdownMenuSeparator />
                                <DropdownMenuItem onClick={() => setShowArchiveDialog(true)}>
                                    <Archive className="h-4 w-4 mr-2" />
                                    Archive
                                </DropdownMenuItem>
                                <DropdownMenuItem
                                    onClick={() => setShowDeleteDialog(true)}
                                    className="text-destructive focus:text-destructive"
                                >
                                    <Trash2 className="h-4 w-4 mr-2" />
                                    Delete
                                </DropdownMenuItem>
                            </DropdownMenuContent>
                        </DropdownMenu>
                    </div>
                    {(trip.origin_city || trip.origin_country_code) && (
                        <CardDescription className="flex items-center gap-1">
                            <MapPin className="h-3 w-3" />
                            {[trip.origin_city, trip.origin_country_code]
                                .filter(Boolean)
                                .join(", ")}
                        </CardDescription>
                    )}
                </CardHeader>
                <CardContent className="pt-2">
                    <Link href={`/app/trips/${trip.id}`}>
                        <div className="flex items-center gap-1 text-sm text-muted-foreground mb-3">
                            <Calendar className="h-3 w-3" />
                            <span>{formatDateRange(trip.start_date, trip.end_date)}</span>
                            {duration && <span className="text-xs">({duration} days)</span>}
                        </div>
                        <div className="flex flex-wrap gap-2">
                            {trip.transport_count > 0 && (
                                <Badge variant="secondary" className="gap-1">
                                    <Plane className="h-3 w-3" />
                                    {trip.transport_count}
                                </Badge>
                            )}
                            {trip.stay_count > 0 && (
                                <Badge variant="secondary" className="gap-1">
                                    <Hotel className="h-3 w-3" />
                                    {trip.stay_count}
                                </Badge>
                            )}
                            {trip.activity_count > 0 && (
                                <Badge variant="secondary" className="gap-1">
                                    <Ticket className="h-3 w-3" />
                                    {trip.activity_count}
                                </Badge>
                            )}
                            {trip.document_count > 0 && (
                                <Badge variant="secondary" className="gap-1">
                                    <FileText className="h-3 w-3" />
                                    {trip.document_count}
                                </Badge>
                            )}
                            {isActive && (
                                <Badge variant="default" className="bg-green-600">
                                    Active
                                </Badge>
                            )}
                        </div>
                    </Link>
                </CardContent>
            </Card>

            {/* Archive Dialog */}
            <AlertDialog open={showArchiveDialog} onOpenChange={setShowArchiveDialog}>
                <AlertDialogContent>
                    <AlertDialogHeader>
                        <AlertDialogTitle>Archive Trip?</AlertDialogTitle>
                        <AlertDialogDescription>
                            &quot;{trip.name}&quot; will be moved to your archive. You can restore
                            it later from the archived trips section.
                        </AlertDialogDescription>
                    </AlertDialogHeader>
                    <AlertDialogFooter>
                        <AlertDialogCancel disabled={isLoading}>Cancel</AlertDialogCancel>
                        <AlertDialogAction onClick={handleArchive} disabled={isLoading}>
                            {isLoading ? "Archiving..." : "Archive"}
                        </AlertDialogAction>
                    </AlertDialogFooter>
                </AlertDialogContent>
            </AlertDialog>

            {/* Delete Dialog */}
            <AlertDialog open={showDeleteDialog} onOpenChange={setShowDeleteDialog}>
                <AlertDialogContent>
                    <AlertDialogHeader>
                        <AlertDialogTitle>Delete Trip?</AlertDialogTitle>
                        <AlertDialogDescription>
                            This will permanently delete &quot;{trip.name}&quot; and all its items,
                            documents, and checklists. This action cannot be undone.
                        </AlertDialogDescription>
                    </AlertDialogHeader>
                    <AlertDialogFooter>
                        <AlertDialogCancel disabled={isLoading}>Cancel</AlertDialogCancel>
                        <AlertDialogAction
                            onClick={handleDelete}
                            disabled={isLoading}
                            className="bg-destructive hover:bg-destructive/90"
                        >
                            {isLoading ? "Deleting..." : "Delete"}
                        </AlertDialogAction>
                    </AlertDialogFooter>
                </AlertDialogContent>
            </AlertDialog>
        </>
    );
}
