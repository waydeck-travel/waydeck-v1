import Link from "next/link";
import Image from "next/image";
import {
    Plane,
    FileText,
    Wallet,
    CheckSquare,
    ArrowRight,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { createClient } from "@/lib/supabase/server";

const features = [
    {
        icon: Plane,
        title: "Complete Itineraries",
        description:
            "Plan flights, trains, hotels, and activities. Keep your entire trip organized in one place.",
    },
    {
        icon: FileText,
        title: "Document Storage",
        description:
            "Store all your tickets, vouchers, visas, and confirmations. Access them anytime, anywhere.",
    },
    {
        icon: Wallet,
        title: "Budget Tracking",
        description:
            "Set budgets for each category and track your expenses. Never overspend on trips again.",
    },
    {
        icon: CheckSquare,
        title: "Smart Checklists",
        description:
            "Create reusable packing lists and pre-trip checklists. Never forget essentials.",
    },
];

const steps = [
    {
        number: "1",
        title: "Create a Trip",
        description: "Add your destination and travel dates to get started.",
    },
    {
        number: "2",
        title: "Add Your Itinerary",
        description: "Add flights, hotels, activities, and notes to your timeline.",
    },
    {
        number: "3",
        title: "Attach Documents",
        description: "Upload tickets and vouchers so everything is in one place.",
    },
];

export default async function LandingPage() {
    const supabase = await createClient();
    const {
        data: { user },
    } = await supabase.auth.getUser();

    return (
        <div className="flex flex-col">
            {/* Hero Section */}
            <section className="container max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16 md:py-24 lg:py-32">
                <div className="grid lg:grid-cols-2 gap-12 items-center">
                    {/* Text Content */}
                    <div className="flex flex-col gap-6 text-center lg:text-left">
                        <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold tracking-tight">
                            Your Complete{" "}
                            <span className="text-primary">Travel Companion</span>
                        </h1>
                        <p className="text-lg md:text-xl text-muted-foreground">
                            Plan trips. Store tickets. Track expenses. All in one place.
                            Waydeck keeps your travels organized so you can focus on the
                            adventure.
                        </p>
                        <div className="flex flex-col sm:flex-row gap-4 justify-center lg:justify-start">
                            {user ? (
                                <Button size="lg" asChild>
                                    <Link href="/app/trips">
                                        My Trips
                                        <ArrowRight className="ml-2 h-4 w-4" />
                                    </Link>
                                </Button>
                            ) : (
                                <>
                                    <Button size="lg" asChild>
                                        <Link href="/auth/sign-up">
                                            Get Started Free
                                            <ArrowRight className="ml-2 h-4 w-4" />
                                        </Link>
                                    </Button>
                                    <Button size="lg" variant="outline" asChild>
                                        <Link href="/auth/sign-in">Sign In</Link>
                                    </Button>
                                </>
                            )}
                        </div>
                    </div>

                    {/* Hero Image */}
                    <div className="flex justify-center lg:justify-end">
                        <div className="relative w-full max-w-lg aspect-square">
                            <Image
                                src="/hero-travel.png"
                                alt="Travel planning illustration"
                                fill
                                className="object-contain"
                                priority
                            />
                        </div>
                    </div>
                </div>
            </section>

            {/* Features Section */}
            <section className="bg-muted/50 py-16 md:py-24">
                <div className="container max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                    <div className="text-center mb-12">
                        <h2 className="text-3xl md:text-4xl font-bold mb-4">
                            Why Waydeck?
                        </h2>
                        <p className="text-muted-foreground max-w-2xl mx-auto">
                            Everything you need to plan, organize, and enjoy your trips.
                        </p>
                    </div>
                    <div className="grid gap-8 md:grid-cols-2 lg:grid-cols-4">
                        {features.map((feature) => (
                            <div
                                key={feature.title}
                                className="flex flex-col items-center text-center p-6 rounded-xl bg-background border"
                            >
                                <div className="rounded-full bg-primary/10 p-3 mb-4">
                                    <feature.icon className="h-6 w-6 text-primary" />
                                </div>
                                <h3 className="text-lg font-semibold mb-2">{feature.title}</h3>
                                <p className="text-sm text-muted-foreground">
                                    {feature.description}
                                </p>
                            </div>
                        ))}
                    </div>
                </div>
            </section>

            {/* How it Works Section */}
            <section className="container max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16 md:py-24">
                <div className="text-center mb-12">
                    <h2 className="text-3xl md:text-4xl font-bold mb-4">How it Works</h2>
                    <p className="text-muted-foreground max-w-2xl mx-auto">
                        Get started in minutes with these simple steps.
                    </p>
                </div>
                <div className="grid gap-8 md:grid-cols-3 max-w-4xl mx-auto">
                    {steps.map((step) => (
                        <div key={step.number} className="flex flex-col items-center text-center">
                            <div className="w-12 h-12 rounded-full bg-primary text-primary-foreground flex items-center justify-center text-xl font-bold mb-4">
                                {step.number}
                            </div>
                            <h3 className="text-lg font-semibold mb-2">{step.title}</h3>
                            <p className="text-sm text-muted-foreground">
                                {step.description}
                            </p>
                        </div>
                    ))}
                </div>
            </section>

            {/* CTA Section */}
            <section className="bg-primary text-primary-foreground py-16 md:py-24">
                <div className="container max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
                    <h2 className="text-3xl md:text-4xl font-bold mb-4">
                        Ready to start planning?
                    </h2>
                    <p className="text-lg opacity-90 mb-8 max-w-2xl mx-auto">
                        Join thousands of travelers who use Waydeck to organize their
                        adventures. It&apos;s free to get started.
                    </p>
                    <div className="flex justify-center gap-4">
                        {user ? (
                            <Button size="lg" variant="secondary" asChild>
                                <Link href="/app/trips">
                                    My Trips
                                    <ArrowRight className="ml-2 h-4 w-4" />
                                </Link>
                            </Button>
                        ) : (
                            <Button size="lg" variant="secondary" asChild>
                                <Link href="/auth/sign-up">
                                    Create Your Free Account
                                    <ArrowRight className="ml-2 h-4 w-4" />
                                </Link>
                            </Button>
                        )}
                    </div>
                </div>
            </section>
        </div>
    );
}
