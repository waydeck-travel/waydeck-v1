import { Calendar, Plane } from "lucide-react";

// Placeholder for now - will be connected to Supabase later
export default function TodayPage() {
    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex items-center gap-3">
                <div className="rounded-full bg-primary/10 p-2">
                    <Calendar className="h-5 w-5 text-primary" />
                </div>
                <div>
                    <h1 className="text-2xl font-bold">Today</h1>
                    <p className="text-muted-foreground">
                        {new Date().toLocaleDateString('en-US', {
                            weekday: 'long',
                            year: 'numeric',
                            month: 'long',
                            day: 'numeric'
                        })}
                    </p>
                </div>
            </div>

            {/* Content */}
            <div className="text-center py-16">
                <div className="rounded-full bg-muted p-4 mx-auto w-fit mb-4">
                    <Plane className="h-8 w-8 text-muted-foreground" />
                </div>
                <h3 className="text-lg font-semibold mb-1">No active trips</h3>
                <p className="text-sm text-muted-foreground mb-6 max-w-sm mx-auto">
                    When you have an active trip, today&apos;s itinerary items will appear here.
                </p>
            </div>
        </div>
    );
}
