import { Users } from "lucide-react";
import { AddTravellerDialog } from "@/components/travellers/add-traveller-dialog";
import { TravellerList } from "@/components/travellers/traveller-list";
import { getTravellers } from "@/actions/travellers";

export default async function TravellersPage() {
    const travellers = await getTravellers();

    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-2xl font-bold">Travellers</h1>
                    <p className="text-muted-foreground">
                        Manage your travel companions and their details
                    </p>
                </div>
                <AddTravellerDialog />
            </div>

            {travellers.length === 0 ? (
                <div className="text-center py-16">
                    <div className="rounded-full bg-muted p-4 mx-auto w-fit mb-4">
                        <Users className="h-8 w-8 text-muted-foreground" />
                    </div>
                    <h3 className="text-lg font-semibold mb-1">No travellers yet</h3>
                    <p className="text-sm text-muted-foreground mb-6 max-w-sm mx-auto">
                        Add your family and friends to quickly assign them to flight and hotel bookings.
                    </p>
                    <AddTravellerDialog />
                </div>
            ) : (
                <TravellerList travellers={travellers} />
            )}
        </div>
    );
}
