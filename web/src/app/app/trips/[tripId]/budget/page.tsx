import { notFound } from "next/navigation";
import Link from "next/link";
import { ArrowLeft, Calculator, Plus, Plane, Hotel, Ticket, ShoppingBag, Utensils } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Progress } from "@/components/ui/progress";
import { getTrip } from "@/actions/trips";
import { getTripBudgets } from "@/actions/budgets";
import { SetBudgetDialog } from "@/components/trips/set-budget-dialog";

interface BudgetPageProps {
    params: Promise<{ tripId: string }>;
}

const CATEGORY_ICONS: Record<string, any> = {
    Transport: Plane,
    Accommodation: Hotel,
    Activities: Ticket,
    Food: Utensils,
    Other: ShoppingBag,
};

const CATEGORY_COLORS: Record<string, string> = {
    Transport: "bg-blue-500",
    Accommodation: "bg-green-500",
    Activities: "bg-purple-500",
    Food: "bg-orange-500",
    Other: "bg-gray-500",
};

export default async function TripBudgetPage({ params }: BudgetPageProps) {
    const { tripId } = await params;
    const [trip, budgets] = await Promise.all([
        getTrip(tripId),
        getTripBudgets(tripId),
    ]);

    if (!trip) {
        notFound();
    }

    const currency = trip.currency || "USD";

    // Prepare categories with budget data
    // Note: 'spent' is currently placeholder 0 until expenses aggregation is implemented
    const categories = Object.keys(CATEGORY_ICONS).map((name) => {
        const budgetItem = budgets.find((b) => b.category === name);
        const budgetAmount = budgetItem?.amount || 0;

        return {
            name,
            icon: CATEGORY_ICONS[name],
            budget: budgetAmount,
            spent: 0, // Placeholder
            color: CATEGORY_COLORS[name],
        };
    });

    const totalBudget = categories.reduce((sum, cat) => sum + cat.budget, 0);
    const totalSpent = categories.reduce((sum, cat) => sum + cat.spent, 0);
    const totalProgress = totalBudget > 0 ? (totalSpent / totalBudget) * 100 : 0;

    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex items-start gap-4">
                <Button variant="ghost" size="icon" asChild>
                    <Link href={`/app/trips/${tripId}`}>
                        <ArrowLeft className="h-4 w-4" />
                    </Link>
                </Button>
                <div className="flex-1">
                    <h1 className="text-2xl font-bold">Budget</h1>
                    <p className="text-muted-foreground">{trip.name}</p>
                </div>
                <SetBudgetDialog
                    tripId={tripId}
                    currency={currency}
                    currentBudgets={budgets}
                />
            </div>

            {/* Total Budget */}
            <Card>
                <CardContent className="py-6 space-y-4">
                    <div className="flex justify-between items-end">
                        <div>
                            <p className="text-sm text-muted-foreground mb-1">Total Budget</p>
                            <p className="text-3xl font-bold">
                                {currency} {totalBudget.toLocaleString()}
                            </p>
                        </div>
                        <div className="text-right">
                            <p className="text-sm text-muted-foreground mb-1">Spent</p>
                            <p className="text-xl font-semibold">
                                {currency} {totalSpent.toLocaleString()}
                            </p>
                        </div>
                    </div>
                    <Progress value={totalProgress} className="h-3" />
                    <p className="text-sm text-muted-foreground text-center">
                        {totalProgress.toFixed(0)}% of budget used
                    </p>
                </CardContent>
            </Card>

            {/* Category Budgets */}
            <div className="space-y-4">
                <h2 className="text-lg font-semibold">By Category</h2>
                {categories.map((cat) => {
                    const Icon = cat.icon;
                    const progress = cat.budget > 0 ? (cat.spent / cat.budget) * 100 : 0;
                    return (
                        <Card key={cat.name}>
                            <CardContent className="py-4">
                                <div className="flex items-center gap-3 mb-3">
                                    <div className={`rounded-lg p-2 ${cat.color.replace('bg-', 'bg-')}/10`}>
                                        <Icon className={`h-4 w-4 ${cat.color.replace('bg-', 'text-')}`} />
                                    </div>
                                    <div className="flex-1">
                                        <h3 className="font-medium">{cat.name}</h3>
                                    </div>
                                    <div className="text-right">
                                        <p className="font-medium">
                                            {currency} {cat.spent.toLocaleString()}
                                        </p>
                                        <p className="text-sm text-muted-foreground">
                                            of {currency} {cat.budget.toLocaleString()}
                                        </p>
                                    </div>
                                </div>
                                <Progress value={progress} className={`h-2 ${cat.color}`} />
                            </CardContent>
                        </Card>
                    );
                })}
            </div>

            {/* Empty State */}
            {totalBudget === 0 && (
                <div className="text-center py-8">
                    <Calculator className="h-8 w-8 mx-auto mb-3 text-muted-foreground opacity-50" />
                    <p className="text-muted-foreground">
                        No budget set yet. Set category budgets to track your spending.
                    </p>
                    <SetBudgetDialog
                        tripId={tripId}
                        currency={currency}
                        currentBudgets={budgets}
                    />
                </div>
            )}
        </div>
    );
}
