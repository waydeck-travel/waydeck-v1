import Link from "next/link";
import { Plane } from "lucide-react";
import { Button } from "@/components/ui/button";
import { ThemeToggle } from "@/components/theme-toggle";

export default function MarketingLayout({
    children,
}: {
    children: React.ReactNode;
}) {
    return (
        <div className="min-h-screen flex flex-col">
            {/* Header */}
            <header className="sticky top-0 z-50 w-full border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
                <div className="container flex h-16 items-center justify-between max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                    <div className="flex items-center gap-6">
                        <Link href="/" className="flex items-center gap-2">
                            <Plane className="h-6 w-6 text-primary" />
                            <span className="text-xl font-semibold">Waydeck</span>
                        </Link>
                        <nav className="hidden md:flex items-center gap-4">
                            <Link
                                href="/about"
                                className="text-sm font-medium text-muted-foreground hover:text-foreground transition-colors"
                            >
                                About
                            </Link>
                            <Link
                                href="/how-it-works"
                                className="text-sm font-medium text-muted-foreground hover:text-foreground transition-colors"
                            >
                                How it Works
                            </Link>
                        </nav>
                    </div>
                    <div className="flex items-center gap-2">
                        <ThemeToggle />
                        <div className="hidden sm:flex items-center gap-2">
                            <Button variant="ghost" asChild>
                                <Link href="/auth/sign-in">Sign In</Link>
                            </Button>
                            <Button asChild>
                                <Link href="/auth/sign-up">Get Started</Link>
                            </Button>
                        </div>
                        {/* Mobile: Single CTA */}
                        <Button asChild className="sm:hidden" size="sm">
                            <Link href="/auth/sign-up">Get Started</Link>
                        </Button>
                    </div>
                </div>
            </header>

            {/* Main Content */}
            <main className="flex-1">{children}</main>

            {/* Footer */}
            <footer className="border-t py-8">
                <div className="container max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                    <div className="flex flex-col md:flex-row items-center justify-between gap-4">
                        <div className="flex items-center gap-2">
                            <Plane className="h-5 w-5 text-muted-foreground" />
                            <span className="text-sm text-muted-foreground">
                                © 2025 Waydeck. All rights reserved.
                            </span>
                        </div>
                        <div className="flex items-center gap-4">
                            <Link
                                href="/about"
                                className="text-sm text-muted-foreground hover:text-foreground transition-colors"
                            >
                                About
                            </Link>
                            <Link
                                href="/contact"
                                className="text-sm text-muted-foreground hover:text-foreground transition-colors"
                            >
                                Contact
                            </Link>
                            <Link
                                href="/privacy"
                                className="text-sm text-muted-foreground hover:text-foreground transition-colors"
                            >
                                Privacy
                            </Link>
                        </div>
                    </div>
                </div>
            </footer>
        </div>
    );
}
