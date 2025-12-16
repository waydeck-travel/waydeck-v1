import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Sidebar } from "@/components/layout/sidebar";
import { TopBar } from "@/components/layout/topbar";

export default async function AppLayout({
    children,
}: {
    children: React.ReactNode;
}) {
    // Server-side auth check
    const supabase = await createClient();
    const {
        data: { user },
    } = await supabase.auth.getUser();

    if (!user) {
        redirect("/auth/sign-in");
    }

    return (
        <div className="flex h-screen">
            {/* Desktop Sidebar */}
            <div className="hidden lg:flex">
                <Sidebar />
            </div>

            {/* Main Content Area */}
            <div className="flex flex-1 flex-col overflow-hidden">
                <TopBar />
                <main className="flex-1 overflow-auto">
                    <div className="container max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
                        {children}
                    </div>
                </main>
            </div>
        </div>
    );
}
