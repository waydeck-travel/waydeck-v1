"use client";

import { useState } from "react";
import { Share2, Copy, Check, Mail } from "lucide-react";
import { toast } from "sonner";
import { Button } from "@/components/ui/button";
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogHeader,
    DialogTitle,
    DialogTrigger,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

interface ShareTripDialogProps {
    tripId: string;
    tripName: string;
}

export function ShareTripDialog({ tripId, tripName }: ShareTripDialogProps) {
    const [open, setOpen] = useState(false);
    const [copied, setCopied] = useState(false);

    // Generate share link (public read-only view)
    const shareUrl = `${typeof window !== "undefined" ? window.location.origin : ""}/share/trips/${tripId}`;

    const copyToClipboard = async () => {
        try {
            await navigator.clipboard.writeText(shareUrl);
            setCopied(true);
            toast.success("Link copied to clipboard");
            setTimeout(() => setCopied(false), 2000);
        } catch {
            toast.error("Failed to copy");
        }
    };

    const shareByEmail = () => {
        const subject = encodeURIComponent(`Check out my trip: ${tripName}`);
        const body = encodeURIComponent(`I wanted to share my trip itinerary with you.\n\nView it here: ${shareUrl}`);
        window.open(`mailto:?subject=${subject}&body=${body}`, "_blank");
    };

    return (
        <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild>
                <Button variant="outline" size="sm">
                    <Share2 className="h-4 w-4 mr-1" />
                    Share
                </Button>
            </DialogTrigger>
            <DialogContent className="sm:max-w-[425px]">
                <DialogHeader>
                    <DialogTitle>Share Trip</DialogTitle>
                    <DialogDescription>
                        Share your trip itinerary with friends and family.
                    </DialogDescription>
                </DialogHeader>
                <div className="space-y-4 py-4">
                    <div className="space-y-2">
                        <Label htmlFor="shareLink">Share Link</Label>
                        <div className="flex gap-2">
                            <Input
                                id="shareLink"
                                value={shareUrl}
                                readOnly
                                className="flex-1"
                            />
                            <Button
                                type="button"
                                size="icon"
                                variant="outline"
                                onClick={copyToClipboard}
                            >
                                {copied ? (
                                    <Check className="h-4 w-4 text-green-500" />
                                ) : (
                                    <Copy className="h-4 w-4" />
                                )}
                            </Button>
                        </div>
                        <p className="text-xs text-muted-foreground">
                            Anyone with this link can view your trip (read-only).
                        </p>
                    </div>

                    <div className="flex gap-2">
                        <Button
                            type="button"
                            variant="outline"
                            className="flex-1"
                            onClick={shareByEmail}
                        >
                            <Mail className="h-4 w-4 mr-2" />
                            Share via Email
                        </Button>
                    </div>
                </div>
            </DialogContent>
        </Dialog>
    );
}
