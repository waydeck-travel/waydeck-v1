import Link from "next/link";
import { Plane } from "lucide-react";
import { MobileNav } from "./mobile-nav";
import { ThemeToggle } from "@/components/theme-toggle";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";

export function TopBar() {
    return (
        <header className="sticky top-0 z-50 flex h-16 items-center justify-between border-b bg-background px-4">
            <div className="flex items-center gap-4">
                <MobileNav />
                <Link href="/app/trips" className="flex items-center gap-2 lg:hidden">
                    <Plane className="h-6 w-6 text-primary" />
                    <span className="text-xl font-semibold">Waydeck</span>
                </Link>
            </div>

            <div className="flex items-center gap-2">
                <ThemeToggle />
                <Button variant="ghost" size="icon" asChild>
                    <Link href="/app/profile">
                        <Avatar className="h-8 w-8">
                            <AvatarFallback>U</AvatarFallback>
                        </Avatar>
                    </Link>
                </Button>
            </div>
        </header>
    );
}
