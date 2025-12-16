"use client";

import { useState } from "react";
import { Loader2, Calculator } from "lucide-react";
import { toast } from "sonner";
import { Button } from "@/components/ui/button";
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
    DialogTrigger,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { setTripBudget, TripBudget } from "@/actions/budgets";

interface SetBudgetDialogProps {
    tripId: string;
    currency: string;
    currentBudgets: TripBudget[];
}

const CATEGORIES = [
    "Transport",
    "Accommodation",
    "Activities",
    "Food",
    "Other",
];

export function SetBudgetDialog({ tripId, currency, currentBudgets }: SetBudgetDialogProps) {
    const [open, setOpen] = useState(false);
    const [loading, setLoading] = useState(false);

    // State for form fields
    const [category, setCategory] = useState(CATEGORIES[0]);
    const [amount, setAmount] = useState("");

    const handleOpenChange = (open: boolean) => {
        setOpen(open);
        if (open) {
            // Reset or populate based on selection
            const existing = currentBudgets.find(b => b.category === category);
            setAmount(existing ? existing.amount.toString() : "");
        }
    };

    const handleCategoryChange = (val: string) => {
        setCategory(val);
        const existing = currentBudgets.find(b => b.category === val);
        setAmount(existing ? existing.amount.toString() : "");
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        const numAmount = parseFloat(amount);
        if (isNaN(numAmount) || numAmount < 0) return;

        setLoading(true);
        try {
            await setTripBudget(tripId, category, numAmount, currency);
            toast.success("Budget updated");
            setOpen(false);
        } catch (error) {
            console.error(error);
            toast.error("Failed to update budget");
        } finally {
            setLoading(false);
        }
    };

    return (
        <Dialog open={open} onOpenChange={handleOpenChange}>
            <DialogTrigger asChild>
                <Button size="sm">
                    <Calculator className="h-4 w-4 mr-1" />
                    Set Budget
                </Button>
            </DialogTrigger>
            <DialogContent className="sm:max-w-[425px]">
                <DialogHeader>
                    <DialogTitle>Set Category Budget</DialogTitle>
                    <DialogDescription>
                        Allocate a budget for {category.toLowerCase()} expenses.
                    </DialogDescription>
                </DialogHeader>
                <form onSubmit={handleSubmit} className="space-y-4">
                    <div className="space-y-2">
                        <Label htmlFor="category">Category</Label>
                        <Select value={category} onValueChange={handleCategoryChange}>
                            <SelectTrigger>
                                <SelectValue />
                            </SelectTrigger>
                            <SelectContent>
                                {CATEGORIES.map((cat) => (
                                    <SelectItem key={cat} value={cat}>
                                        {cat}
                                    </SelectItem>
                                ))}
                            </SelectContent>
                        </Select>
                    </div>

                    <div className="space-y-2">
                        <Label htmlFor="amount">Amount ({currency})</Label>
                        <Input
                            id="amount"
                            type="number"
                            min="0"
                            step="0.01"
                            value={amount}
                            onChange={(e) => setAmount(e.target.value)}
                            placeholder="0.00"
                            required
                        />
                    </div>

                    <DialogFooter>
                        <Button
                            type="button"
                            variant="outline"
                            onClick={() => setOpen(false)}
                            disabled={loading}
                        >
                            Cancel
                        </Button>
                        <Button type="submit" disabled={loading || !amount}>
                            {loading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                            Save Budget
                        </Button>
                    </DialogFooter>
                </form>
            </DialogContent>
        </Dialog>
    );
}
