"use client";

import { useState } from "react";
import { useParams } from "next/navigation";
import { Loader2, Upload, Calendar as CalendarIcon, FileText } from "lucide-react";
import { format } from "date-fns";
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
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from "@/components/ui/select";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Calendar } from "@/components/ui/calendar";
import {
    Popover,
    PopoverContent,
    PopoverTrigger,
} from "@/components/ui/popover";
import { cn } from "@/lib/utils";
import { uploadDocument, uploadGlobalDocument } from "@/actions/documents";

interface UploadDocumentDialogProps {
    type: "trip" | "global";
    tripId?: string;
    tripItemId?: string;
    trigger?: React.ReactNode;
    onSuccess?: () => void;
}

const DOC_TYPES = {
    passport: "Passport",
    visa: "Visa",
    insurance: "Insurance",
    ticket: "Ticket",
    voucher: "Voucher",
    receipt: "Receipt",
    confirmation: "Confirmation",
    other: "Other",
};

export function UploadDocumentDialog({
    type,
    tripId,
    tripItemId,
    trigger,
    onSuccess,
}: UploadDocumentDialogProps) {
    const params = useParams();
    const effectiveTripId = tripId || (params.tripId as string);

    const [open, setOpen] = useState(false);
    const [loading, setLoading] = useState(false);
    const [file, setFile] = useState<File | null>(null);
    const [docType, setDocType] = useState("other");
    const [label, setLabel] = useState("");
    const [expiresAt, setExpiresAt] = useState<Date>();
    const [countryCode, setCountryCode] = useState("");

    const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        if (e.target.files && e.target.files[0]) {
            const selectedFile = e.target.files[0];
            setFile(selectedFile);
            if (!label) {
                // Auto-set label from filename without extension
                const name = selectedFile.name.split(".").slice(0, -1).join(".");
                setLabel(name);
            }
        }
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!file) return;

        setLoading(true);
        try {
            const formData = new FormData();
            formData.append("file", file);
            formData.append("docType", docType);
            formData.append("label", label);
            if (expiresAt) formData.append("expiresAt", expiresAt.toISOString());

            if (type === "trip" && effectiveTripId) {
                formData.append("tripId", effectiveTripId);
                if (tripItemId) formData.append("tripItemId", tripItemId);
                await uploadDocument(formData);
            } else {
                if (countryCode) formData.append("countryCode", countryCode);
                await uploadGlobalDocument(formData);
            }

            toast.success("Document uploaded successfully");
            setOpen(false);
            setFile(null);
            setLabel("");
            setDocType("other");
            setExpiresAt(undefined);
            onSuccess?.();
        } catch (error) {
            console.error(error);
            toast.error("Failed to upload document");
        } finally {
            setLoading(false);
        }
    };

    return (
        <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild>
                {trigger || (
                    <Button size="sm">
                        <Upload className="h-4 w-4 mr-2" />
                        Upload
                    </Button>
                )}
            </DialogTrigger>
            <DialogContent className="sm:max-w-[425px]">
                <DialogHeader>
                    <DialogTitle>Upload Document</DialogTitle>
                    <DialogDescription>
                        {type === "trip"
                            ? "Add a document to this trip."
                            : "Add a document to your global wallet."}
                    </DialogDescription>
                </DialogHeader>
                <form onSubmit={handleSubmit} className="space-y-4">
                    <div className="grid w-full max-w-sm items-center gap-1.5">
                        <Label htmlFor="file">File</Label>
                        <Input
                            id="file"
                            type="file"
                            onChange={handleFileChange}
                            required
                        />
                    </div>

                    <div className="space-y-2">
                        <Label htmlFor="type">Document Type</Label>
                        <Select value={docType} onValueChange={setDocType}>
                            <SelectTrigger>
                                <SelectValue placeholder="Select type" />
                            </SelectTrigger>
                            <SelectContent>
                                {Object.entries(DOC_TYPES).map(([value, label]) => (
                                    <SelectItem key={value} value={value}>
                                        {label}
                                    </SelectItem>
                                ))}
                            </SelectContent>
                        </Select>
                    </div>

                    <div className="space-y-2">
                        <Label htmlFor="label">Label</Label>
                        <Input
                            id="label"
                            value={label}
                            onChange={(e) => setLabel(e.target.value)}
                            placeholder="e.g. Flight to Paris"
                            required
                        />
                    </div>

                    {type === "global" && (
                        <div className="space-y-2">
                            <Label htmlFor="country">Country Code (Optional)</Label>
                            <Input
                                id="country"
                                value={countryCode}
                                onChange={(e) => setCountryCode(e.target.value.toUpperCase())}
                                placeholder="e.g. US, FR"
                                maxLength={2}
                            />
                        </div>
                    )}

                    <div className="space-y-2">
                        <Label>Expires At (Optional)</Label>
                        <Popover>
                            <PopoverTrigger asChild>
                                <Button
                                    variant={"outline"}
                                    className={cn(
                                        "w-full justify-start text-left font-normal",
                                        !expiresAt && "text-muted-foreground"
                                    )}
                                >
                                    <CalendarIcon className="mr-2 h-4 w-4" />
                                    {expiresAt ? (
                                        format(expiresAt, "PPP")
                                    ) : (
                                        <span>Pick a date</span>
                                    )}
                                </Button>
                            </PopoverTrigger>
                            <PopoverContent className="w-auto p-0">
                                <Calendar
                                    mode="single"
                                    selected={expiresAt}
                                    onSelect={setExpiresAt}
                                    initialFocus
                                />
                            </PopoverContent>
                        </Popover>
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
                        <Button type="submit" disabled={!file || loading}>
                            {loading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                            Upload
                        </Button>
                    </DialogFooter>
                </form>
            </DialogContent>
        </Dialog>
    );
}
