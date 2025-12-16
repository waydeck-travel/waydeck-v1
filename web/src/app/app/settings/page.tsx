"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import {
    User,
    Users,
    FileText,
    CheckSquare,
    Palette,
    Bell,
    Shield,
    LogOut,
    Loader2,
    ChevronRight,
} from "lucide-react";
import { createClient } from "@/lib/supabase/client";
import { Button } from "@/components/ui/button";
import {
    Card,
    CardContent,
    CardDescription,
    CardHeader,
    CardTitle,
} from "@/components/ui/card";
import { Separator } from "@/components/ui/separator";
import { Switch } from "@/components/ui/switch";
import { signOutAction } from "@/actions/auth";

interface SettingItem {
    icon: React.ElementType;
    label: string;
    description: string;
    href?: string;
    action?: "toggle" | "link";
    disabled?: boolean;
}

export default function SettingsPage() {
    // router removed
    const [isSigningOut, setIsSigningOut] = useState(false);
    const [user, setUser] = useState<{ email: string; name?: string } | null>(null);
    const [darkMode, setDarkMode] = useState(false);

    useEffect(() => {
        async function fetchUser() {
            const supabase = createClient();

            const { data: { user: authUser } } = await supabase.auth.getUser();
            if (authUser) {
                setUser({
                    email: authUser.email || "",
                    name: authUser.user_metadata?.full_name || authUser.user_metadata?.name,
                });
            }
        }
        fetchUser();
    }, []);

    const handleSignOut = async () => {
        setIsSigningOut(true);
        await signOutAction();
    };

    const accountSettings: SettingItem[] = [
        {
            icon: User,
            label: "Edit Profile",
            description: "Update your name, email, and preferences",
            href: "/app/profile",
        },
        {
            icon: Users,
            label: "Travellers",
            description: "Manage your travel companions",
            href: "/app/travellers",
        },
        {
            icon: FileText,
            label: "Global Documents",
            description: "Passports, IDs, and travel documents",
            href: "/app/documents",
        },
        {
            icon: CheckSquare,
            label: "Checklist Templates",
            description: "Create reusable packing lists",
            href: "/app/checklists",
        },
    ];

    const appSettings: SettingItem[] = [
        {
            icon: Palette,
            label: "Appearance",
            description: "Dark mode and theme settings",
            action: "toggle",
        },
        {
            icon: Bell,
            label: "Notifications",
            description: "Trip reminders and alerts",
            disabled: true,
        },
        {
            icon: Shield,
            label: "Privacy & Security",
            description: "Password and account security",
            disabled: true,
        },
    ];

    return (
        <div className="space-y-6">
            {/* Header */}
            <div>
                <h1 className="text-2xl font-bold">Settings</h1>
                <p className="text-muted-foreground">
                    Manage your account and app preferences
                </p>
            </div>

            {/* User Info */}
            <Card>
                <CardHeader className="flex flex-row items-center gap-4">
                    <div className="h-12 w-12 rounded-full bg-primary/10 flex items-center justify-center">
                        <User className="h-6 w-6 text-primary" />
                    </div>
                    <div>
                        <CardTitle className="text-lg">
                            {user?.name || "User"}
                        </CardTitle>
                        <CardDescription>
                            {user?.email || "Loading..."}
                        </CardDescription>
                    </div>
                </CardHeader>
            </Card>

            {/* Account Settings */}
            <Card>
                <CardHeader>
                    <CardTitle className="text-base">Account</CardTitle>
                </CardHeader>
                <CardContent className="p-0">
                    {accountSettings.map((item, index) => {
                        const Icon = item.icon;
                        const content = (
                            <div
                                className={`flex items-center gap-4 px-6 py-4 ${!item.disabled ? "hover:bg-muted/50 cursor-pointer" : "opacity-50"
                                    }`}
                            >
                                <div className="h-10 w-10 rounded-lg bg-primary/10 flex items-center justify-center">
                                    <Icon className="h-5 w-5 text-primary" />
                                </div>
                                <div className="flex-1 min-w-0">
                                    <p className="font-medium">{item.label}</p>
                                    <p className="text-sm text-muted-foreground truncate">
                                        {item.description}
                                    </p>
                                </div>
                                <ChevronRight className="h-5 w-5 text-muted-foreground" />
                            </div>
                        );

                        return (
                            <div key={item.label}>
                                {item.href && !item.disabled ? (
                                    <Link href={item.href}>{content}</Link>
                                ) : (
                                    content
                                )}
                                {index < accountSettings.length - 1 && <Separator />}
                            </div>
                        );
                    })}
                </CardContent>
            </Card>

            {/* App Settings */}
            <Card>
                <CardHeader>
                    <CardTitle className="text-base">App Settings</CardTitle>
                </CardHeader>
                <CardContent className="p-0">
                    {appSettings.map((item, index) => {
                        const Icon = item.icon;
                        return (
                            <div key={item.label}>
                                <div
                                    className={`flex items-center gap-4 px-6 py-4 ${item.disabled ? "opacity-50" : ""
                                        }`}
                                >
                                    <div className="h-10 w-10 rounded-lg bg-primary/10 flex items-center justify-center">
                                        <Icon className="h-5 w-5 text-primary" />
                                    </div>
                                    <div className="flex-1 min-w-0">
                                        <p className="font-medium">{item.label}</p>
                                        <p className="text-sm text-muted-foreground truncate">
                                            {item.description}
                                        </p>
                                    </div>
                                    {item.action === "toggle" && (
                                        <Switch
                                            checked={darkMode}
                                            onCheckedChange={setDarkMode}
                                            disabled={item.disabled}
                                        />
                                    )}
                                    {!item.action && !item.disabled && (
                                        <ChevronRight className="h-5 w-5 text-muted-foreground" />
                                    )}
                                </div>
                                {index < appSettings.length - 1 && <Separator />}
                            </div>
                        );
                    })}
                </CardContent>
            </Card>

            {/* Sign Out */}
            <Card>
                <CardContent className="py-4">
                    <Button
                        variant="destructive"
                        className="w-full"
                        onClick={handleSignOut}
                        disabled={isSigningOut}
                    >
                        {isSigningOut ? (
                            <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                        ) : (
                            <LogOut className="mr-2 h-4 w-4" />
                        )}
                        Sign Out
                    </Button>
                </CardContent>
            </Card>

            {/* Footer */}
            <div className="text-center text-sm text-muted-foreground py-4">
                <p>Waydeck v1.0</p>
                <p className="mt-1">Made with ❤️ for travelers</p>
            </div>
        </div>
    );
}
