"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { Menu, Plane } from "lucide-react";
import {
    Sheet,
    SheetContent,
    SheetHeader,
    SheetTitle,
    SheetTrigger,
    SheetClose,
} from "@/components/ui/sheet";
import { Button } from "@/components/ui/button";
import {
    Calendar,
    FileText,
    CheckSquare,
    User,
    Settings,
} from "lucide-react";
import { cn } from "@/lib/utils";

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

export function MobileNav() {
    const pathname = usePathname();

    return (
        <Sheet>
            <SheetTrigger asChild>
                <Button variant="ghost" size="icon" className="lg:hidden">
                    <Menu className="h-5 w-5" />
                    <span className="sr-only">Open menu</span>
                </Button>
            </SheetTrigger>
            <SheetContent side="left" className="w-64 p-0">
                <SheetHeader className="flex h-16 items-center px-6 border-b">
                    <SheetTitle className="flex items-center gap-2">
                        <Plane className="h-6 w-6 text-primary" />
                        <span className="text-xl font-semibold">Waydeck</span>
                    </SheetTitle>
                </SheetHeader>

                <nav className="flex-1 space-y-1 p-4">
                    {navigation.map((item) => {
                        const isActive = pathname.startsWith(item.href);
                        return (
                            <SheetClose asChild key={item.name}>
                                <Button
                                    variant={isActive ? "secondary" : "ghost"}
                                    className={cn("w-full justify-start gap-3")}
                                    asChild
                                >
                                    <Link href={item.href}>
                                        <item.icon className="h-4 w-4" />
                                        {item.name}
                                    </Link>
                                </Button>
                            </SheetClose>
                        );
                    })}
                </nav>

                <div className="border-t p-4 space-y-1">
                    {secondaryNav.map((item) => {
                        const isActive = pathname.startsWith(item.href);
                        return (
                            <SheetClose asChild key={item.name}>
                                <Button
                                    variant={isActive ? "secondary" : "ghost"}
                                    className="w-full justify-start gap-3"
                                    asChild
                                >
                                    <Link href={item.href}>
                                        <item.icon className="h-4 w-4" />
                                        {item.name}
                                    </Link>
                                </Button>
                            </SheetClose>
                        );
                    })}
                </div>
            </SheetContent>
        </Sheet>
    );
}
