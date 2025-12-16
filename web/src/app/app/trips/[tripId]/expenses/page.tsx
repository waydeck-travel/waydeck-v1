import { notFound } from "next/navigation";
import Link from "next/link";
import { ArrowLeft, Plus, DollarSign, Wallet } from "lucide-react";
import { format } from "date-fns";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { getTrip } from "@/actions/trips";
import { getTripExpenses } from "@/actions/expenses";
import { AddExpenseDialog } from "@/components/trips/add-expense-dialog";

interface ExpensesPageProps {
    params: Promise<{ tripId: string }>;
}

export default async function TripExpensesPage({ params }: ExpensesPageProps) {
    const { tripId } = await params;
    const [trip, expenses] = await Promise.all([
        getTrip(tripId),
        getTripExpenses(tripId),
    ]);

    if (!trip) {
        notFound();
    }

    const currency = trip.currency || "USD";
    const totalExpenses = expenses.reduce((sum, item) => sum + item.amount, 0);

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
                    <h1 className="text-2xl font-bold">Expenses</h1>
                    <p className="text-muted-foreground">{trip.name}</p>
                </div>
                <AddExpenseDialog tripId={tripId} defaultCurrency={currency} />
            </div>

            {/* Summary Card */}
            <Card>
                <CardContent className="py-6 flex items-center justify-between">
                    <div>
                        <p className="text-sm text-muted-foreground mb-1">Total Expenses</p>
                        <h2 className="text-3xl font-bold">
                            {currency} {totalExpenses.toLocaleString()}
                        </h2>
                    </div>
                    <div className="rounded-full bg-primary/10 p-3">
                        <Wallet className="h-6 w-6 text-primary" />
                    </div>
                </CardContent>
            </Card>

            {/* Expenses List */}
            <div className="space-y-4">
                <h3 className="font-semibold text-lg">Transactions</h3>

                {expenses.length === 0 ? (
                    <div className="text-center py-12 border rounded-lg bg-muted/20">
                        <DollarSign className="h-8 w-8 mx-auto mb-3 text-muted-foreground opacity-50" />
                        <p className="text-muted-foreground mb-4">
                            No expenses recorded yet.
                        </p>
                        <AddExpenseDialog tripId={tripId} defaultCurrency={currency} />
                    </div>
                ) : (
                    <div className="space-y-3">
                        {expenses.map((expense) => (
                            <div
                                key={expense.id}
                                className="flex items-center justify-between p-4 rounded-lg border bg-card"
                            >
                                <div className="space-y-1">
                                    <p className="font-medium">{expense.description}</p>
                                    <div className="flex gap-2 text-xs text-muted-foreground">
                                        <span>{format(new Date(expense.date), "MMM d, yyyy")}</span>
                                        <span>•</span>
                                        <span>{expense.category}</span>
                                    </div>
                                </div>
                                <div className="font-semibold">
                                    {expense.currency} {expense.amount.toLocaleString()}
                                </div>
                            </div>
                        ))}
                    </div>
                )}
            </div>
        </div>
    );
}
