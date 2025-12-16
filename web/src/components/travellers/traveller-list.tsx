"use client";

import { UserCircle, Mail, Phone, Globe, FileText, Trash2, Edit2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { deleteTraveller } from "@/actions/travellers";
import { toast } from "sonner";
import { Traveller } from "@/types/traveller";

interface TravellerListProps {
    travellers: Traveller[];
}

export function TravellerList({ travellers }: TravellerListProps) {
    const handleDelete = async (id: string, name: string) => {
        if (!confirm(`Are you sure you want to delete ${name}?`)) return;

        try {
            await deleteTraveller(id);
            toast.success("Traveller deleted");
        } catch (error) {
            console.error(error);
            toast.error("Failed to delete traveller");
        }
    };

    return (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {travellers.map((traveller) => (
                <Card key={traveller.id} className="relative group">
                    <CardHeader className="pb-2 flex flex-row items-center gap-4">
                        <div className="h-10 w-10 rounded-full bg-primary/10 flex items-center justify-center">
                            <span className="text-lg font-semibold text-primary">
                                {traveller.first_name[0]}{traveller.last_name[0]}
                            </span>
                        </div>
                        <div className="flex-1 min-w-0">
                            <CardTitle className="text-base truncate">
                                {traveller.first_name} {traveller.last_name}
                            </CardTitle>
                        </div>
                    </CardHeader>
                    <CardContent className="space-y-2 text-sm text-muted-foreground">
                        {traveller.email && (
                            <div className="flex items-center gap-2">
                                <Mail className="h-3 w-3" />
                                <span className="truncate">{traveller.email}</span>
                            </div>
                        )}
                        {traveller.phone && (
                            <div className="flex items-center gap-2">
                                <Phone className="h-3 w-3" />
                                <span>{traveller.phone}</span>
                            </div>
                        )}
                        {traveller.nationality && (
                            <div className="flex items-center gap-2">
                                <Globe className="h-3 w-3" />
                                <span>{traveller.nationality}</span>
                            </div>
                        )}
                        {traveller.passport_number && (
                            <div className="flex items-center gap-2">
                                <FileText className="h-3 w-3" />
                                <span>Passport: {traveller.passport_number}</span>
                            </div>
                        )}

                        <div className="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity flex gap-1">
                            {/* Edit disabled for now as we don't have update dialog yet */}
                            <Button
                                variant="ghost"
                                size="icon"
                                className="h-8 w-8 text-muted-foreground"
                                disabled
                            >
                                <Edit2 className="h-4 w-4" />
                            </Button>
                            <Button
                                variant="ghost"
                                size="icon"
                                className="h-8 w-8 text-destructive"
                                onClick={() => handleDelete(traveller.id, traveller.first_name)}
                            >
                                <Trash2 className="h-4 w-4" />
                            </Button>
                        </div>
                    </CardContent>
                </Card>
            ))}
        </div>
    );
}
