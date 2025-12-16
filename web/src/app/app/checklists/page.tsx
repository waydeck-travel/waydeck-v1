import { CheckSquare, Plus, FileText } from "lucide-react";
import Link from "next/link";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { getChecklistTemplates } from "@/actions/checklists";
import { formatDistanceToNow } from "date-fns";

export const dynamic = "force-dynamic";

export default async function ChecklistsPage() {
    const templates = await getChecklistTemplates();

    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-2xl font-bold">Checklist Templates</h1>
                    <p className="text-muted-foreground">
                        Create reusable packing lists and pre-trip checklists
                    </p>
                </div>
                <Button asChild>
                    <Link href="/app/checklists/new">
                        <Plus className="h-4 w-4 mr-2" />
                        New Template
                    </Link>
                </Button>
            </div>

            {templates.length === 0 ? (
                <div className="text-center py-16">
                    <div className="rounded-full bg-muted p-4 mx-auto w-fit mb-4">
                        <CheckSquare className="h-8 w-8 text-muted-foreground" />
                    </div>
                    <h3 className="text-lg font-semibold mb-1">No templates yet</h3>
                    <p className="text-sm text-muted-foreground mb-6 max-w-sm mx-auto">
                        Create checklist templates that you can import into any trip. Never forget
                        essentials again.
                    </p>
                    <Button asChild>
                        <Link href="/app/checklists/new">
                            <Plus className="h-4 w-4 mr-2" />
                            Create Your First Template
                        </Link>
                    </Button>
                </div>
            ) : (
                <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
                    {templates.map((template) => (
                        <Link key={template.id} href={`/app/checklists/${template.id}`}>
                            <Card className="hover:bg-muted/50 transition-colors cursor-pointer h-full">
                                <CardHeader>
                                    <CardTitle className="flex items-center gap-2">
                                        <FileText className="h-4 w-4 text-primary" />
                                        {template.name}
                                    </CardTitle>
                                    <CardDescription>
                                        Updated {formatDistanceToNow(new Date(template.updated_at), { addSuffix: true })}
                                    </CardDescription>
                                </CardHeader>
                                {template.description && (
                                    <CardContent>
                                        <p className="text-sm text-muted-foreground line-clamp-3">
                                            {template.description}
                                        </p>
                                    </CardContent>
                                )}
                            </Card>
                        </Link>
                    ))}
                </div>
            )}
        </div>
    );
}
