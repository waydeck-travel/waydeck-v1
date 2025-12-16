import { FileText, Plus } from "lucide-react";
import { Button } from "@/components/ui/button";
import { DocumentGrid } from "@/components/documents/document-grid";
import { getGlobalDocuments } from "@/actions/documents";
import { UploadDocumentDialog } from "@/components/documents/upload-document-dialog";

export const dynamic = "force-dynamic";

export default async function DocumentsPage() {
    const documents = await getGlobalDocuments();

    // Group documents by type
    const passportDocs = documents.filter((d) => d.doc_type === "passport");
    const visaDocs = documents.filter((d) => d.doc_type === "visa");
    const insuranceDocs = documents.filter((d) => d.doc_type === "insurance");
    const otherDocs = documents.filter(
        (d) => !["passport", "visa", "insurance"].includes(d.doc_type)
    );

    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-2xl font-bold">My Documents</h1>
                    <p className="text-muted-foreground">
                        Store your passports, visas, and travel insurance
                    </p>
                </div>
                <UploadDocumentDialog type="global" />
            </div>

            {documents.length === 0 ? (
                <div className="text-center py-16">
                    <div className="rounded-full bg-muted p-4 mx-auto w-fit mb-4">
                        <FileText className="h-8 w-8 text-muted-foreground" />
                    </div>
                    <h3 className="text-lg font-semibold mb-1">No documents yet</h3>
                    <p className="text-sm text-muted-foreground mb-6 max-w-sm mx-auto">
                        Upload your passport, visa, or insurance documents. They&apos;ll be
                        available across all your trips.
                    </p>
                    <UploadDocumentDialog type="global" trigger={
                        <Button>
                            <Plus className="h-4 w-4 mr-2" />
                            Upload Your First Document
                        </Button>
                    } />
                </div>
            ) : (
                <div className="space-y-8">
                    {/* Passports */}
                    {passportDocs.length > 0 && (
                        <section>
                            <h2 className="text-lg font-semibold mb-4">Passports</h2>
                            <DocumentGrid documents={passportDocs} type="global" />
                        </section>
                    )}

                    {/* Visas */}
                    {visaDocs.length > 0 && (
                        <section>
                            <h2 className="text-lg font-semibold mb-4">Visas</h2>
                            <DocumentGrid documents={visaDocs} type="global" />
                        </section>
                    )}

                    {/* Insurance */}
                    {insuranceDocs.length > 0 && (
                        <section>
                            <h2 className="text-lg font-semibold mb-4">Insurance</h2>
                            <DocumentGrid documents={insuranceDocs} type="global" />
                        </section>
                    )}

                    {/* Other */}
                    {otherDocs.length > 0 && (
                        <section>
                            <h2 className="text-lg font-semibold mb-4">Other Documents</h2>
                            <DocumentGrid documents={otherDocs} type="global" />
                        </section>
                    )}
                </div>
            )}
        </div>
    );
}
