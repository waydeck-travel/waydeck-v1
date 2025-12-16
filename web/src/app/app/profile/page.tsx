"use client";

import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import {
    LogOut,
    User,
    Loader2,
    Mail,
    Phone,
    Calendar,
    MapPin,
    Edit,
    Save,
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
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { Separator } from "@/components/ui/separator";
import { toast } from "sonner";

interface UserProfile {
    email: string;
    name: string;
    phone?: string;
    home_city?: string;
    date_of_birth?: string;
}

export default function ProfilePage() {
    const router = useRouter();
    const [isSigningOut, setIsSigningOut] = useState(false);
    const [isEditing, setIsEditing] = useState(false);
    const [isSaving, setIsSaving] = useState(false);
    const [user, setUser] = useState<UserProfile | null>(null);
    const [formData, setFormData] = useState<UserProfile>({
        email: "",
        name: "",
        phone: "",
        home_city: "",
    });

    useEffect(() => {
        async function fetchUser() {
            const supabase = createClient();
            const { data: { user: authUser } } = await supabase.auth.getUser();
            if (authUser) {
                const profile: UserProfile = {
                    email: authUser.email || "",
                    name: authUser.user_metadata?.full_name || authUser.user_metadata?.name || "",
                    phone: authUser.user_metadata?.phone || "",
                    home_city: authUser.user_metadata?.home_city || "",
                };
                setUser(profile);
                setFormData(profile);
            }
        }
        fetchUser();
    }, []);

    const handleSignOut = async () => {
        setIsSigningOut(true);
        const supabase = createClient();
        await supabase.auth.signOut();
        router.push("/");
        router.refresh();
    };

    const handleSave = async () => {
        setIsSaving(true);
        try {
            const supabase = createClient();
            const { error } = await supabase.auth.updateUser({
                data: {
                    full_name: formData.name,
                    phone: formData.phone,
                    home_city: formData.home_city,
                },
            });

            if (error) {
                toast.error("Failed to update profile");
            } else {
                setUser(formData);
                setIsEditing(false);
                toast.success("Profile updated!");
            }
        } catch {
            toast.error("An error occurred");
        } finally {
            setIsSaving(false);
        }
    };

    const getInitials = (name: string) => {
        return name
            .split(" ")
            .map((n) => n[0])
            .join("")
            .toUpperCase()
            .slice(0, 2);
    };

    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-2xl font-bold">Profile</h1>
                    <p className="text-muted-foreground">
                        Manage your account and preferences
                    </p>
                </div>
                {!isEditing ? (
                    <Button variant="outline" onClick={() => setIsEditing(true)}>
                        <Edit className="h-4 w-4 mr-2" />
                        Edit
                    </Button>
                ) : (
                    <div className="flex gap-2">
                        <Button variant="outline" onClick={() => setIsEditing(false)}>
                            Cancel
                        </Button>
                        <Button onClick={handleSave} disabled={isSaving}>
                            {isSaving ? (
                                <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                            ) : (
                                <Save className="h-4 w-4 mr-2" />
                            )}
                            Save
                        </Button>
                    </div>
                )}
            </div>

            {/* Profile Card */}
            <Card>
                <CardHeader>
                    <div className="flex items-center gap-4">
                        <Avatar className="h-20 w-20">
                            <AvatarFallback className="text-xl bg-primary/10 text-primary">
                                {user?.name ? getInitials(user.name) : <User className="h-8 w-8" />}
                            </AvatarFallback>
                        </Avatar>
                        <div>
                            <CardTitle className="text-xl">
                                {user?.name || "Your Name"}
                            </CardTitle>
                            <CardDescription className="text-base">
                                {user?.email}
                            </CardDescription>
                        </div>
                    </div>
                </CardHeader>
                <CardContent className="space-y-6">
                    {isEditing ? (
                        <div className="grid gap-4 sm:grid-cols-2">
                            <div className="space-y-2">
                                <Label htmlFor="name">Full Name</Label>
                                <Input
                                    id="name"
                                    value={formData.name}
                                    onChange={(e) =>
                                        setFormData({ ...formData, name: e.target.value })
                                    }
                                    placeholder="Enter your name"
                                />
                            </div>
                            <div className="space-y-2">
                                <Label htmlFor="email">Email</Label>
                                <Input
                                    id="email"
                                    value={formData.email}
                                    disabled
                                    className="bg-muted"
                                />
                            </div>
                            <div className="space-y-2">
                                <Label htmlFor="phone">Phone</Label>
                                <Input
                                    id="phone"
                                    value={formData.phone || ""}
                                    onChange={(e) =>
                                        setFormData({ ...formData, phone: e.target.value })
                                    }
                                    placeholder="+1 234 567 8900"
                                />
                            </div>
                            <div className="space-y-2">
                                <Label htmlFor="city">Home City</Label>
                                <Input
                                    id="city"
                                    value={formData.home_city || ""}
                                    onChange={(e) =>
                                        setFormData({ ...formData, home_city: e.target.value })
                                    }
                                    placeholder="Enter your city"
                                />
                            </div>
                        </div>
                    ) : (
                        <div className="grid gap-4 sm:grid-cols-2">
                            <div className="flex items-center gap-3">
                                <Mail className="h-4 w-4 text-muted-foreground" />
                                <div>
                                    <p className="text-sm font-medium">Email</p>
                                    <p className="text-sm text-muted-foreground">
                                        {user?.email || "Not set"}
                                    </p>
                                </div>
                            </div>
                            <div className="flex items-center gap-3">
                                <Phone className="h-4 w-4 text-muted-foreground" />
                                <div>
                                    <p className="text-sm font-medium">Phone</p>
                                    <p className="text-sm text-muted-foreground">
                                        {user?.phone || "Not set"}
                                    </p>
                                </div>
                            </div>
                            <div className="flex items-center gap-3">
                                <MapPin className="h-4 w-4 text-muted-foreground" />
                                <div>
                                    <p className="text-sm font-medium">Home City</p>
                                    <p className="text-sm text-muted-foreground">
                                        {user?.home_city || "Not set"}
                                    </p>
                                </div>
                            </div>
                        </div>
                    )}

                    <Separator />

                    {/* Quick Links */}
                    <div>
                        <p className="text-sm font-medium mb-3">Quick Links</p>
                        <div className="flex flex-wrap gap-2">
                            <Button variant="outline" size="sm" asChild>
                                <Link href="/app/settings">Settings</Link>
                            </Button>
                            <Button variant="outline" size="sm" asChild>
                                <Link href="/app/documents">My Documents</Link>
                            </Button>
                            <Button variant="outline" size="sm" asChild>
                                <Link href="/app/checklists">Checklist Templates</Link>
                            </Button>
                        </div>
                    </div>

                    <Separator />

                    {/* Sign Out */}
                    <div className="flex items-center justify-between">
                        <div>
                            <p className="text-sm font-medium">Sign Out</p>
                            <p className="text-sm text-muted-foreground">
                                Sign out of your account
                            </p>
                        </div>
                        <Button
                            variant="destructive"
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
                    </div>
                </CardContent>
            </Card>
        </div>
    );
}
