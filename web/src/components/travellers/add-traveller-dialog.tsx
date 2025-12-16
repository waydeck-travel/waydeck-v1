"use client";

import { useState } from "react";
import { Loader2, Plus, UserPlus } from "lucide-react";
import { toast } from "sonner";
import { Button } from "@/components/ui/button";
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
    DialogTrigger,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { createTraveller } from "@/actions/travellers";

export function AddTravellerDialog() {
    const [open, setOpen] = useState(false);
    const [loading, setLoading] = useState(false);

    const [firstName, setFirstName] = useState("");
    const [lastName, setLastName] = useState("");
    const [email, setEmail] = useState("");
    const [phone, setPhone] = useState("");
    const [passportNumber, setPassportNumber] = useState("");
    const [nationality, setNationality] = useState("");

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!firstName.trim() || !lastName.trim()) return;

        setLoading(true);
        try {
            await createTraveller({
                first_name: firstName,
                last_name: lastName,
                email: email || null,
                phone: phone || null,
                passport_number: passportNumber || null,
                nationality: nationality || null,
                date_of_birth: null,
                passport_expiry: null,
                passport_country: null,
                avatar_url: null,
                notes: null,
            });
            toast.success("Traveller added");
            setOpen(false);

            // Reset
            setFirstName("");
            setLastName("");
            setEmail("");
            setPhone("");
            setPassportNumber("");
            setNationality("");
        } catch (error) {
            console.error(error);
            toast.error("Failed to add traveller");
        } finally {
            setLoading(false);
        }
    };

    return (
        <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild>
                <Button>
                    <Plus className="h-4 w-4 mr-2" />
                    Add Traveller
                </Button>
            </DialogTrigger>
            <DialogContent className="sm:max-w-[425px]">
                <DialogHeader>
                    <DialogTitle>Add Traveller</DialogTitle>
                    <DialogDescription>
                        Add a new companion to manage their bookings.
                    </DialogDescription>
                </DialogHeader>
                <form onSubmit={handleSubmit} className="space-y-4">
                    <div className="grid grid-cols-2 gap-4">
                        <div className="space-y-2">
                            <Label htmlFor="firstName">First Name *</Label>
                            <Input
                                id="firstName"
                                value={firstName}
                                onChange={(e) => setFirstName(e.target.value)}
                                placeholder="John"
                                required
                            />
                        </div>
                        <div className="space-y-2">
                            <Label htmlFor="lastName">Last Name *</Label>
                            <Input
                                id="lastName"
                                value={lastName}
                                onChange={(e) => setLastName(e.target.value)}
                                placeholder="Doe"
                                required
                            />
                        </div>
                    </div>

                    <div className="space-y-2">
                        <Label htmlFor="email">Email (Optional)</Label>
                        <Input
                            id="email"
                            type="email"
                            value={email}
                            onChange={(e) => setEmail(e.target.value)}
                            placeholder="john.doe@example.com"
                        />
                    </div>

                    <div className="space-y-2">
                        <Label htmlFor="phone">Phone (Optional)</Label>
                        <Input
                            id="phone"
                            type="tel"
                            value={phone}
                            onChange={(e) => setPhone(e.target.value)}
                            placeholder="+1 234 567 890"
                        />
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                        <div className="space-y-2">
                            <Label htmlFor="passport">Passport Number</Label>
                            <Input
                                id="passport"
                                value={passportNumber}
                                onChange={(e) => setPassportNumber(e.target.value)}
                                placeholder="A1234567"
                            />
                        </div>
                        <div className="space-y-2">
                            <Label htmlFor="nationality">Nationality</Label>
                            <Input
                                id="nationality"
                                value={nationality}
                                onChange={(e) => setNationality(e.target.value)}
                                placeholder="US"
                            />
                        </div>
                    </div>

                    <DialogFooter>
                        <Button
                            type="button"
                            variant="outline"
                            onClick={() => setOpen(false)}
                            disabled={loading}
                        >
                            Cancel
                        </Button>
                        <Button type="submit" disabled={loading || !firstName || !lastName}>
                            {loading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                            Save Traveller
                        </Button>
                    </DialogFooter>
                </form>
            </DialogContent>
        </Dialog>
    );
}
