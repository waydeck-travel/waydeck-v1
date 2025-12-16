import Link from "next/link";
import { redirect } from "next/navigation";
import { Plane } from "lucide-react";
import { createClient } from "@/lib/supabase/server";

export default async function AuthLayout({
    children,
}: {
    children: React.ReactNode;
}) {
    // Server-side auth check - redirect authenticated users away from auth pages
    const supabase = await createClient();
    const {
        data: { user },
    } = await supabase.auth.getUser();

    if (user) {
        redirect("/app/trips");
    }

    return (
        <div className="min-h-screen flex flex-col items-center justify-center p-4 bg-muted/30">
            <div className="mb-8">
                <Link href="/" className="flex items-center gap-2">
                    <Plane className="h-8 w-8 text-primary" />
                    <span className="text-2xl font-semibold">Waydeck</span>
                </Link>
            </div>
            <div className="w-full max-w-md">{children}</div>
        </div>
    );
}
