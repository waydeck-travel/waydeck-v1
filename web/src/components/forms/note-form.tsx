"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Loader2, ArrowLeft } from "lucide-react";
import Link from "next/link";

import { Button } from "@/components/ui/button";
import {
    Form,
    FormControl,
    FormField,
    FormItem,
    FormLabel,
    FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { createNoteItem } from "@/actions/item-create";
import { toast } from "sonner";

const noteFormSchema = z.object({
    title: z.string().min(1, "Title is required"),
    content: z.string().optional(),
});

type NoteFormValues = z.infer<typeof noteFormSchema>;

interface NoteFormProps {
    tripId: string;
}

export function NoteForm({ tripId }: NoteFormProps) {
    const router = useRouter();
    const [isSubmitting, setIsSubmitting] = useState(false);

    const form = useForm<NoteFormValues>({
        resolver: zodResolver(noteFormSchema),
        defaultValues: {},
    });

    async function onSubmit(data: NoteFormValues) {
        setIsSubmitting(true);

        const result = await createNoteItem({
            trip_id: tripId,
            title: data.title,
            description: data.content,
        });

        if (result) {
            toast.success("Note added!");
            router.push(`/app/trips/${tripId}`);
        } else {
            toast.error("Failed to add note");
            setIsSubmitting(false);
        }
    }

    return (
        <div className="space-y-6">
            <div className="flex items-center gap-4">
                <Button variant="ghost" size="icon" asChild>
                    <Link href={`/app/trips/${tripId}`}>
                        <ArrowLeft className="h-4 w-4" />
                    </Link>
                </Button>
                <div>
                    <h1 className="text-2xl font-bold">Add Note</h1>
                    <p className="text-muted-foreground">Add tips, reminders, or information</p>
                </div>
            </div>

            <Form {...form}>
                <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
                    <FormField
                        control={form.control}
                        name="title"
                        render={({ field }) => (
                            <FormItem>
                                <FormLabel>Title *</FormLabel>
                                <FormControl>
                                    <Input
                                        placeholder="e.g., Visa Requirements"
                                        {...field}
                                    />
                                </FormControl>
                                <FormMessage />
                            </FormItem>
                        )}
                    />

                    <FormField
                        control={form.control}
                        name="content"
                        render={({ field }) => (
                            <FormItem>
                                <FormLabel>Content</FormLabel>
                                <FormControl>
                                    <Textarea
                                        placeholder="Write your note here..."
                                        className="resize-none"
                                        rows={8}
                                        {...field}
                                    />
                                </FormControl>
                                <FormMessage />
                            </FormItem>
                        )}
                    />

                    {/* Actions */}
                    <div className="flex gap-4">
                        <Button type="submit" disabled={isSubmitting}>
                            {isSubmitting && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                            Add Note
                        </Button>
                        <Button
                            type="button"
                            variant="outline"
                            onClick={() => router.back()}
                            disabled={isSubmitting}
                        >
                            Cancel
                        </Button>
                    </div>
                </form>
            </Form>
        </div>
    );
}
