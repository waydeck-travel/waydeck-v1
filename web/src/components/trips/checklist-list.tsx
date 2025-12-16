"use client";

import { useState } from "react";
import { Checkbox } from "@/components/ui/checkbox";
import { Button } from "@/components/ui/button";
import { Trash2 } from "lucide-react";
import { toggleChecklistItem, deleteChecklistItem, ChecklistItem } from "@/actions/checklists";
import { toast } from "sonner";
import { cn } from "@/lib/utils";

interface ChecklistListProps {
    items: ChecklistItem[];
    tripId: string;
}

export function ChecklistList({ items, tripId }: ChecklistListProps) {
    const [optItems, setOptItems] = useState(items);

    const handleToggle = async (id: string, checked: boolean) => {
        // Optimistic update
        setOptItems((prev) =>
            prev.map((i) => (i.id === id ? { ...i, is_checked: checked } : i))
        );

        try {
            await toggleChecklistItem(id, tripId, checked);
        } catch {
            // Revert on error
            toast.error("Failed to update item");
            setOptItems(items);
        }
    };

    const handleDelete = async (id: string) => {
        if (!confirm("Delete this item?")) return;

        // Optimistic delete
        setOptItems((prev) => prev.filter((i) => i.id !== id));

        try {
            await deleteChecklistItem(id, tripId);
            toast.success("Item deleted");
        } catch {
            toast.error("Failed to delete item");
            setOptItems(items);
        }
    };

    // Group items locally since we are passed a flat list
    const groups = optItems.reduce((acc, item) => {
        const group = item.group_name || "General";
        if (!acc[group]) acc[group] = [];
        acc[group].push(item);
        return acc;
    }, {} as Record<string, ChecklistItem[]>);

    return (
        <div className="space-y-6">
            {Object.entries(groups).map(([groupName, groupItems]) => (
                <div key={groupName} className="space-y-2">
                    <h3 className="font-semibold text-sm text-muted-foreground uppercase tracking-wider">
                        {groupName}
                    </h3>
                    <div className="space-y-2">
                        {groupItems.map((item) => (
                            <div
                                key={item.id}
                                className="flex items-center gap-3 p-3 rounded-lg border bg-card group"
                            >
                                <Checkbox
                                    checked={item.is_checked}
                                    onCheckedChange={(checked) =>
                                        handleToggle(item.id, checked as boolean)
                                    }
                                />
                                <span
                                    className={cn(
                                        "flex-1",
                                        item.is_checked && "line-through text-muted-foreground"
                                    )}
                                >
                                    {item.description}
                                </span>
                                <Button
                                    variant="ghost"
                                    size="icon"
                                    className="opacity-0 group-hover:opacity-100 h-8 w-8 text-destructive"
                                    onClick={() => handleDelete(item.id)}
                                >
                                    <Trash2 className="h-4 w-4" />
                                </Button>
                            </div>
                        ))}
                    </div>
                </div>
            ))}
        </div>
    );
}
