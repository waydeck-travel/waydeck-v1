"use client";

import { notFound, useRouter } from "next/navigation";
import Link from "next/link";
import { use, useEffect, useState, useTransition } from "react";
import {
    ArrowLeft,
    Plane,
    Train,
    Bus,
    Car,
    Bike,
    Ship,
    TrainFront,
    Sailboat,
    CarTaxiFront,
    Hotel,
    Ticket,
    FileText,
    Clock,
    Trash2,
    Loader2,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Separator } from "@/components/ui/separator";
import {
    AlertDialog,
    AlertDialogAction,
    AlertDialogCancel,
    AlertDialogContent,
    AlertDialogDescription,
    AlertDialogFooter,
    AlertDialogHeader,
    AlertDialogTitle,
    AlertDialogTrigger,
} from "@/components/ui/alert-dialog";
import { getItemById, deleteTripItem, TripItemWithDetails } from "@/actions/trip-items";
import { formatTime, formatShortDate } from "@/lib/dates";
import { toast } from "sonner";



interface ItemDetailPageProps {
    params: Promise<{ tripId: string; itemId: string }>;
}

export default function ItemDetailPage({ params }: ItemDetailPageProps) {
    const { tripId, itemId } = use(params);
    const router = useRouter();
    const [item, setItem] = useState<TripItemWithDetails | null>(null);
    const [loading, setLoading] = useState(true);
    const [isPending, startTransition] = useTransition();

    useEffect(() => {
        async function fetchItem() {
            const data = await getItemById(itemId);
            setItem(data);
            setLoading(false);
        }
        fetchItem();
    }, [itemId]);

    const handleDelete = async () => {
        startTransition(async () => {
            const success = await deleteTripItem(itemId, tripId);
            if (success) {
                toast.success("Item deleted");
                router.push(`/app/trips/${tripId}`);
            } else {
                toast.error("Failed to delete item");
            }
        });
    };

    if (loading) {
        return (
            <div className="flex items-center justify-center py-12">
                <Loader2 className="h-8 w-8 animate-spin" />
            </div>
        );
    }

    if (!item) {
        notFound();
    }

    // Determine icon type without creating component during render
    const getIconType = (): string => {
        if (item.type === "transport") {
            return item.transport_items?.[0]?.mode || "other";
        }
        return item.type;
    };

    const getItemColor = () => {
        if (item.type === "transport") return "text-blue-600";
        if (item.type === "stay") return "text-green-600";
        if (item.type === "activity") return "text-purple-600";
        return "text-amber-600";
    };

    const iconType = getIconType();
    const iconClass = `h-6 w-6 ${getItemColor()}`;

    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex items-start gap-4">
                <Button variant="ghost" size="icon" asChild>
                    <Link href={`/app/trips/${tripId}`}>
                        <ArrowLeft className="h-4 w-4" />
                    </Link>
                </Button>
                <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-3">
                        {/* Render icon based on type without creating component during render */}
                        {iconType === "flight" && <Plane className={iconClass} />}
                        {iconType === "train" && <Train className={iconClass} />}
                        {iconType === "bus" && <Bus className={iconClass} />}
                        {iconType === "car" && <Car className={iconClass} />}
                        {iconType === "bike" && <Bike className={iconClass} />}
                        {iconType === "cruise" && <Ship className={iconClass} />}
                        {iconType === "metro" && <TrainFront className={iconClass} />}
                        {iconType === "ferry" && <Sailboat className={iconClass} />}
                        {iconType === "other" && <CarTaxiFront className={iconClass} />}
                        {iconType === "stay" && <Hotel className={iconClass} />}
                        {iconType === "activity" && <Ticket className={iconClass} />}
                        {iconType === "note" && <FileText className={iconClass} />}
                        <h1 className="text-2xl font-bold truncate">{item.title}</h1>
                    </div>
                    <Badge variant="outline" className="mt-1 capitalize">{item.type}</Badge>
                </div>
                <div className="flex gap-2">
                    <AlertDialog>
                        <AlertDialogTrigger asChild>
                            <Button variant="destructive" size="sm" disabled={isPending}>
                                {isPending ? (
                                    <Loader2 className="h-4 w-4 animate-spin" />
                                ) : (
                                    <>
                                        <Trash2 className="h-4 w-4 mr-1" />
                                        Delete
                                    </>
                                )}
                            </Button>
                        </AlertDialogTrigger>
                        <AlertDialogContent>
                            <AlertDialogHeader>
                                <AlertDialogTitle>Delete Item?</AlertDialogTitle>
                                <AlertDialogDescription>
                                    This will permanently delete &quot;{item.title}&quot; from your trip.
                                    This action cannot be undone.
                                </AlertDialogDescription>
                            </AlertDialogHeader>
                            <AlertDialogFooter>
                                <AlertDialogCancel>Cancel</AlertDialogCancel>
                                <AlertDialogAction onClick={handleDelete}>Delete</AlertDialogAction>
                            </AlertDialogFooter>
                        </AlertDialogContent>
                    </AlertDialog>
                </div>
            </div>

            <Separator />

            {/* Transport Details */}
            {item.type === "transport" && item.transport_items?.[0] && (
                <Card>
                    <CardHeader>
                        <CardTitle>Transport Details</CardTitle>
                    </CardHeader>
                    <CardContent className="space-y-4">
                        {(() => {
                            const t = item.transport_items[0];
                            return (
                                <>
                                    <div className="grid grid-cols-2 gap-4">
                                        <div>
                                            <p className="text-sm text-muted-foreground">Mode</p>
                                            <p className="font-medium capitalize">{t.mode}</p>
                                        </div>
                                        {t.carrier_name && (
                                            <div>
                                                <p className="text-sm text-muted-foreground">Carrier</p>
                                                <p className="font-medium">{t.carrier_name}</p>
                                            </div>
                                        )}
                                        {t.transport_number && (
                                            <div>
                                                <p className="text-sm text-muted-foreground">Number</p>
                                                <p className="font-medium">{t.carrier_code} {t.transport_number}</p>
                                            </div>
                                        )}
                                        {t.booking_reference && (
                                            <div>
                                                <p className="text-sm text-muted-foreground">Booking Ref</p>
                                                <p className="font-medium">{t.booking_reference}</p>
                                            </div>
                                        )}
                                    </div>

                                    <Separator />

                                    <div className="grid grid-cols-2 gap-4">
                                        <div>
                                            <p className="text-sm text-muted-foreground">From</p>
                                            <p className="font-medium">{t.origin_city || "—"}</p>
                                            {t.origin_airport_code && (
                                                <Badge variant="outline">{t.origin_airport_code}</Badge>
                                            )}
                                            {t.departure_local && (
                                                <p className="text-sm text-muted-foreground mt-1">
                                                    <Clock className="h-3 w-3 inline mr-1" />
                                                    {formatTime(t.departure_local)}
                                                </p>
                                            )}
                                        </div>
                                        <div>
                                            <p className="text-sm text-muted-foreground">To</p>
                                            <p className="font-medium">{t.destination_city || "—"}</p>
                                            {t.destination_airport_code && (
                                                <Badge variant="outline">{t.destination_airport_code}</Badge>
                                            )}
                                            {t.arrival_local && (
                                                <p className="text-sm text-muted-foreground mt-1">
                                                    <Clock className="h-3 w-3 inline mr-1" />
                                                    {formatTime(t.arrival_local)}
                                                </p>
                                            )}
                                        </div>
                                    </div>

                                    {(t.passenger_count || t.expense_amount) && (
                                        <>
                                            <Separator />
                                            <div className="grid grid-cols-2 gap-4">
                                                {t.passenger_count && (
                                                    <div>
                                                        <p className="text-sm text-muted-foreground">Passengers</p>
                                                        <p className="font-medium">{t.passenger_count}</p>
                                                    </div>
                                                )}
                                                {t.expense_amount && (
                                                    <div>
                                                        <p className="text-sm text-muted-foreground">Cost</p>
                                                        <p className="font-medium">
                                                            {t.expense_currency || ""} {t.expense_amount.toLocaleString()}
                                                        </p>
                                                    </div>
                                                )}
                                            </div>
                                        </>
                                    )}
                                </>
                            );
                        })()}
                    </CardContent>
                </Card>
            )}

            {/* Stay Details */}
            {item.type === "stay" && item.stay_items?.[0] && (
                <Card>
                    <CardHeader>
                        <CardTitle>Stay Details</CardTitle>
                    </CardHeader>
                    <CardContent className="space-y-4">
                        {(() => {
                            const s = item.stay_items[0];
                            return (
                                <>
                                    <div className="grid grid-cols-2 gap-4">
                                        <div className="col-span-2">
                                            <p className="text-sm text-muted-foreground">Property</p>
                                            <p className="font-medium">{s.accommodation_name}</p>
                                        </div>
                                        {s.address && (
                                            <div className="col-span-2">
                                                <p className="text-sm text-muted-foreground">Address</p>
                                                <p className="font-medium">{s.address}</p>
                                            </div>
                                        )}
                                        {s.city && (
                                            <div>
                                                <p className="text-sm text-muted-foreground">City</p>
                                                <p className="font-medium">{s.city}</p>
                                            </div>
                                        )}
                                    </div>

                                    <Separator />

                                    <div className="grid grid-cols-2 gap-4">
                                        {s.checkin_local && (
                                            <div>
                                                <p className="text-sm text-muted-foreground">Check-in</p>
                                                <p className="font-medium">{formatShortDate(s.checkin_local)}</p>
                                            </div>
                                        )}
                                        {s.checkout_local && (
                                            <div>
                                                <p className="text-sm text-muted-foreground">Check-out</p>
                                                <p className="font-medium">{formatShortDate(s.checkout_local)}</p>
                                            </div>
                                        )}
                                    </div>

                                    <div className="flex gap-2">
                                        {s.has_breakfast && <Badge>🍳 Breakfast</Badge>}
                                        {s.confirmation_number && <Badge variant="outline">#{s.confirmation_number}</Badge>}
                                    </div>

                                    {s.expense_amount && (
                                        <>
                                            <Separator />
                                            <div>
                                                <p className="text-sm text-muted-foreground">Cost</p>
                                                <p className="font-medium">
                                                    {s.expense_currency || ""} {s.expense_amount.toLocaleString()}
                                                </p>
                                            </div>
                                        </>
                                    )}
                                </>
                            );
                        })()}
                    </CardContent>
                </Card>
            )}

            {/* Activity Details */}
            {item.type === "activity" && item.activity_items?.[0] && (
                <Card>
                    <CardHeader>
                        <CardTitle>Activity Details</CardTitle>
                    </CardHeader>
                    <CardContent className="space-y-4">
                        {(() => {
                            const a = item.activity_items[0];
                            return (
                                <>
                                    <div className="grid grid-cols-2 gap-4">
                                        {a.category && (
                                            <div>
                                                <p className="text-sm text-muted-foreground">Category</p>
                                                <Badge variant="secondary" className="capitalize">{a.category}</Badge>
                                            </div>
                                        )}
                                        {a.location_name && (
                                            <div>
                                                <p className="text-sm text-muted-foreground">Location</p>
                                                <p className="font-medium">{a.location_name}</p>
                                            </div>
                                        )}
                                        {a.city && (
                                            <div>
                                                <p className="text-sm text-muted-foreground">City</p>
                                                <p className="font-medium">{a.city}</p>
                                            </div>
                                        )}
                                    </div>

                                    {(a.start_local || a.end_local) && (
                                        <>
                                            <Separator />
                                            <div className="grid grid-cols-2 gap-4">
                                                {a.start_local && (
                                                    <div>
                                                        <p className="text-sm text-muted-foreground">Start</p>
                                                        <p className="font-medium">{formatTime(a.start_local)}</p>
                                                    </div>
                                                )}
                                                {a.end_local && (
                                                    <div>
                                                        <p className="text-sm text-muted-foreground">End</p>
                                                        <p className="font-medium">{formatTime(a.end_local)}</p>
                                                    </div>
                                                )}
                                            </div>
                                        </>
                                    )}

                                    {a.expense_amount && (
                                        <>
                                            <Separator />
                                            <div>
                                                <p className="text-sm text-muted-foreground">Cost</p>
                                                <p className="font-medium">
                                                    {a.expense_currency || ""} {a.expense_amount.toLocaleString()}
                                                </p>
                                            </div>
                                        </>
                                    )}
                                </>
                            );
                        })()}
                    </CardContent>
                </Card>
            )}

            {/* Note Details */}
            {item.type === "note" && (
                <Card>
                    <CardHeader>
                        <CardTitle>Note</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <p className="whitespace-pre-wrap">{item.description || "No content"}</p>
                    </CardContent>
                </Card>
            )}
        </div>
    );
}
