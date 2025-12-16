"use client";

import {
    FileText,
    File,
    Image,
    MoreVertical,
    Download,
    Trash2,
    ExternalLink,
    AlertTriangle,
} from "lucide-react";
import { formatDistanceToNow, parseISO, isBefore, addMonths } from "date-fns";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import {
    AlertDialog,
    AlertDialogAction,
    AlertDialogCancel,
    AlertDialogContent,
    AlertDialogDescription,
    AlertDialogFooter,
    AlertDialogHeader,
    AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import { useState } from "react";
import { deleteDocument, deleteGlobalDocument, getSignedUrl } from "@/actions/documents";
import { toast } from "sonner";
import type { Document, GlobalDocument } from "@/actions/documents";

const docTypeIcons: Record<string, typeof FileText> = {
    pdf: FileText,
    image: Image,
    default: File,
};

const docTypeLabels: Record<string, string> = {
    passport: "Passport",
    visa: "Visa",
    insurance: "Insurance",
    ticket: "Ticket",
    voucher: "Voucher",
    receipt: "Receipt",
    confirmation: "Confirmation",
    other: "Document",
};

function getDocIcon(mimeType: string | null) {
    if (!mimeType) return File;
    if (mimeType.startsWith("image/")) return Image;
    if (mimeType === "application/pdf") return FileText;
    return File;
}

function isExpiringSoon(expiresAt: string | null): boolean {
    if (!expiresAt) return false;
    const expiry = parseISO(expiresAt);
    const sixMonthsFromNow = addMonths(new Date(), 6);
    return isBefore(expiry, sixMonthsFromNow);
}

function isExpired(expiresAt: string | null): boolean {
    if (!expiresAt) return false;
    return isBefore(parseISO(expiresAt), new Date());
}

interface DocumentCardProps {
    document: Document | GlobalDocument;
    type: "trip" | "global";
    tripId?: string;
}

function DocumentCard({ document, type, tripId }: DocumentCardProps) {
    const [showDeleteDialog, setShowDeleteDialog] = useState(false);
    const [isDeleting, setIsDeleting] = useState(false);

    const Icon = getDocIcon(document.mime_type);
    const label = document.label || docTypeLabels[document.doc_type] || "Document";
    const expired = isExpired(document.expires_at);
    const expiringSoon = !expired && isExpiringSoon(document.expires_at);

    const handleView = async () => {
        const url = await getSignedUrl(document.storage_path);
        if (url) {
            window.open(url, "_blank");
        } else {
            toast.error("Failed to load document");
        }
    };

    const handleDownload = async () => {
        const url = await getSignedUrl(document.storage_path);
        if (url) {
            const a = globalThis.document.createElement("a");
            a.href = url;
            a.download = label;
            a.click();
        } else {
            toast.error("Failed to download document");
        }
    };

    const handleDelete = async () => {
        setIsDeleting(true);
        const success =
            type === "global"
                ? await deleteGlobalDocument(document.id)
                : await deleteDocument(document.id, tripId);

        if (success) {
            toast.success("Document deleted");
        } else {
            toast.error("Failed to delete document");
        }
        setIsDeleting(false);
        setShowDeleteDialog(false);
    };

    return (
        <>
            <Card className="overflow-hidden hover:shadow-md transition-shadow">
                <CardContent className="p-4">
                    <div className="flex items-start gap-3">
                        <div className="rounded-lg bg-muted p-2">
                            <Icon className="h-5 w-5 text-muted-foreground" />
                        </div>
                        <div className="flex-1 min-w-0">
                            <h4 className="font-medium truncate">{label}</h4>
                            <p className="text-sm text-muted-foreground">
                                {docTypeLabels[document.doc_type] || document.doc_type}
                            </p>
                            {document.expires_at && (
                                <div className="flex items-center gap-1 mt-1">
                                    {(expired || expiringSoon) && (
                                        <AlertTriangle
                                            className={`h-3 w-3 ${expired ? "text-destructive" : "text-amber-500"}`}
                                        />
                                    )}
                                    <span
                                        className={`text-xs ${expired ? "text-destructive" : expiringSoon ? "text-amber-600" : "text-muted-foreground"}`}
                                    >
                                        {expired
                                            ? "Expired"
                                            : `Expires ${formatDistanceToNow(parseISO(document.expires_at), { addSuffix: true })}`}
                                    </span>
                                </div>
                            )}
                        </div>
                        <DropdownMenu>
                            <DropdownMenuTrigger asChild>
                                <Button variant="ghost" size="icon" className="shrink-0">
                                    <MoreVertical className="h-4 w-4" />
                                </Button>
                            </DropdownMenuTrigger>
                            <DropdownMenuContent align="end">
                                <DropdownMenuItem onClick={handleView}>
                                    <ExternalLink className="h-4 w-4 mr-2" />
                                    View
                                </DropdownMenuItem>
                                <DropdownMenuItem onClick={handleDownload}>
                                    <Download className="h-4 w-4 mr-2" />
                                    Download
                                </DropdownMenuItem>
                                <DropdownMenuItem
                                    onClick={() => setShowDeleteDialog(true)}
                                    className="text-destructive focus:text-destructive"
                                >
                                    <Trash2 className="h-4 w-4 mr-2" />
                                    Delete
                                </DropdownMenuItem>
                            </DropdownMenuContent>
                        </DropdownMenu>
                    </div>
                </CardContent>
            </Card>

            <AlertDialog open={showDeleteDialog} onOpenChange={setShowDeleteDialog}>
                <AlertDialogContent>
                    <AlertDialogHeader>
                        <AlertDialogTitle>Delete Document?</AlertDialogTitle>
                        <AlertDialogDescription>
                            This will permanently delete &quot;{label}&quot;. This action cannot be
                            undone.
                        </AlertDialogDescription>
                    </AlertDialogHeader>
                    <AlertDialogFooter>
                        <AlertDialogCancel disabled={isDeleting}>Cancel</AlertDialogCancel>
                        <AlertDialogAction
                            onClick={handleDelete}
                            disabled={isDeleting}
                            className="bg-destructive hover:bg-destructive/90"
                        >
                            {isDeleting ? "Deleting..." : "Delete"}
                        </AlertDialogAction>
                    </AlertDialogFooter>
                </AlertDialogContent>
            </AlertDialog>
        </>
    );
}

interface DocumentGridProps {
    documents: (Document | GlobalDocument)[];
    type: "trip" | "global";
    tripId?: string;
}

export function DocumentGrid({ documents, type, tripId }: DocumentGridProps) {
    if (documents.length === 0) {
        return (
            <div className="text-center py-12 text-muted-foreground">
                <FileText className="h-8 w-8 mx-auto mb-3 opacity-50" />
                <p>No documents yet.</p>
                <p className="text-sm mt-1">Upload your first document to get started.</p>
            </div>
        );
    }

    return (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {documents.map((doc) => (
                <DocumentCard key={doc.id} document={doc} type={type} tripId={tripId} />
            ))}
        </div>
    );
}
