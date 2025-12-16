"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import {
    Plane,
    Calendar,
    FileText,
    CheckSquare,
    User,
    Settings,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";

const navigation = [
    { name: "Trips", href: "/app/trips", icon: Plane },
    { name: "Today", href: "/app/today", icon: Calendar },
    { name: "Documents", href: "/app/documents", icon: FileText },
    { name: "Checklists", href: "/app/checklists", icon: CheckSquare },
];

const secondaryNav = [
    { name: "Profile", href: "/app/profile", icon: User },
    { name: "Settings", href: "/app/settings", icon: Settings },
];

export function Sidebar() {
    const pathname = usePathname();

    return (
        <aside className="flex h-full w-64 flex-col bg-background border-r">
            {/* Logo */}
            <div className="flex h-16 items-center px-6 border-b">
                <Link href="/app/trips" className="flex items-center gap-2">
                    <Plane className="h-6 w-6 text-primary" />
                    <span className="text-xl font-semibold">Waydeck</span>
                </Link>
            </div>

            {/* Navigation */}
            <nav className="flex-1 space-y-1 p-4">
                {navigation.map((item) => {
                    const isActive = pathname.startsWith(item.href);
                    return (
                        <Button
                            key={item.name}
                            variant={isActive ? "secondary" : "ghost"}
                            className={cn("w-full justify-start gap-3")}
                            asChild
                        >
                            <Link href={item.href}>
                                <item.icon className="h-4 w-4" />
                                {item.name}
                            </Link>
                        </Button>
                    );
                })}
            </nav>

            {/* Footer */}
            <div className="border-t p-4 space-y-1">
                {secondaryNav.map((item) => {
                    const isActive = pathname.startsWith(item.href);
                    return (
                        <Button
                            key={item.name}
                            variant={isActive ? "secondary" : "ghost"}
                            className="w-full justify-start gap-3"
                            asChild
                        >
                            <Link href={item.href}>
                                <item.icon className="h-4 w-4" />
                                {item.name}
                            </Link>
                        </Button>
                    );
                })}
            </div>
        </aside>
    );
}
