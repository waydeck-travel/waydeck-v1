"use client";

import { useState, useTransition, use, useEffect } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { ArrowLeft, Plus, Trash2, Loader2, ListChecks } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { toast } from "sonner";
import {
    getChecklistTemplate,
    getTemplateItems,
    addTemplateItem,
    deleteTemplateItem,
    type ChecklistTemplate,
    type TemplateItem,
} from "@/actions/checklists";

interface TemplateDetailPageProps {
    params: Promise<{ templateId: string }>;
}

export default function TemplateDetailPage({ params }: TemplateDetailPageProps) {
    const { templateId } = use(params);
    const router = useRouter();
    const [template, setTemplate] = useState<ChecklistTemplate | null>(null);
    const [items, setItems] = useState<TemplateItem[]>([]);
    const [loading, setLoading] = useState(true);
    const [newItemText, setNewItemText] = useState("");
    const [isPending, startTransition] = useTransition();

    useEffect(() => {
        async function loadData() {
            const [templateData, itemsData] = await Promise.all([
                getChecklistTemplate(templateId),
                getTemplateItems(templateId),
            ]);
            setTemplate(templateData);
            setItems(itemsData);
            setLoading(false);
        }
        loadData();
    }, [templateId]);

    const handleAddItem = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!newItemText.trim()) return;

        startTransition(async () => {
            const newItem = await addTemplateItem(templateId, newItemText.trim());
            if (newItem) {
                setItems((prev) => [...prev, newItem]);
                setNewItemText("");
                toast.success("Item added");
            } else {
                toast.error("Failed to add item");
            }
        });
    };

    const handleDeleteItem = async (itemId: string) => {
        startTransition(async () => {
            const success = await deleteTemplateItem(itemId, templateId);
            if (success) {
                setItems((prev) => prev.filter((i) => i.id !== itemId));
                toast.success("Item deleted");
            } else {
                toast.error("Failed to delete item");
            }
        });
    };

    if (loading) {
        return (
            <div className="flex items-center justify-center py-12">
                <Loader2 className="h-8 w-8 animate-spin" />
            </div>
        );
    }

    if (!template) {
        router.push("/app/checklists");
        return null;
    }

    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex items-start gap-4">
                <Button variant="ghost" size="icon" asChild>
                    <Link href="/app/checklists">
                        <ArrowLeft className="h-4 w-4" />
                    </Link>
                </Button>
                <div className="flex-1">
                    <h1 className="text-2xl font-bold">{template.name}</h1>
                    {template.description && (
                        <p className="text-muted-foreground">{template.description}</p>
                    )}
                </div>
            </div>

            {/* Add Item Form */}
            <Card>
                <CardHeader>
                    <CardTitle className="text-lg">Add Item</CardTitle>
                </CardHeader>
                <CardContent>
                    <form onSubmit={handleAddItem} className="flex gap-2">
                        <Input
                            placeholder="Enter item description..."
                            value={newItemText}
                            onChange={(e) => setNewItemText(e.target.value)}
                            disabled={isPending}
                        />
                        <Button type="submit" disabled={isPending || !newItemText.trim()}>
                            {isPending ? (
                                <Loader2 className="h-4 w-4 animate-spin" />
                            ) : (
                                <>
                                    <Plus className="h-4 w-4 mr-1" />
                                    Add
                                </>
                            )}
                        </Button>
                    </form>
                </CardContent>
            </Card>

            {/* Items List */}
            <Card>
                <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                        <ListChecks className="h-5 w-5" />
                        Template Items ({items.length})
                    </CardTitle>
                </CardHeader>
                <CardContent>
                    {items.length === 0 ? (
                        <p className="text-muted-foreground text-center py-8">
                            No items yet. Add items above to build your checklist template.
                        </p>
                    ) : (
                        <ul className="space-y-2">
                            {items.map((item) => (
                                <li
                                    key={item.id}
                                    className="flex items-center justify-between p-3 rounded-lg bg-muted/50 group"
                                >
                                    <span>{item.description}</span>
                                    <Button
                                        variant="ghost"
                                        size="icon"
                                        className="opacity-0 group-hover:opacity-100 transition-opacity text-destructive hover:text-destructive"
                                        onClick={() => handleDeleteItem(item.id)}
                                        disabled={isPending}
                                    >
                                        <Trash2 className="h-4 w-4" />
                                    </Button>
                                </li>
                            ))}
                        </ul>
                    )}
                </CardContent>
            </Card>
        </div>
    );
}
