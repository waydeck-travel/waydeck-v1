/**
 * File validation utilities for document uploads
 */

export const ALLOWED_DOCUMENT_TYPES = [
    "application/pdf",
    "image/jpeg",
    "image/png",
    "image/webp",
] as const;

export const MAX_DOCUMENT_SIZE_MB = 10;
export const MAX_AVATAR_SIZE_MB = 5;

/**
 * Check if a MIME type is allowed for document uploads
 */
export function isAllowedMimeType(mimeType: string): boolean {
    return (ALLOWED_DOCUMENT_TYPES as readonly string[]).includes(mimeType);
}

/**
 * Check if a file size is within the allowed limit
 */
export function isFileSizeValid(sizeBytes: number, maxMb: number): boolean {
    const maxBytes = maxMb * 1024 * 1024;
    return sizeBytes <= maxBytes;
}

/**
 * Validate a file for upload
 * @returns Object with validation result and optional error message
 */
export function validateFile(
    file: File,
    options: {
        allowedTypes?: readonly string[];
        maxSizeMb?: number;
    } = {}
): { valid: boolean; error?: string } {
    const allowedTypes = options.allowedTypes ?? ALLOWED_DOCUMENT_TYPES;
    const maxSizeMb = options.maxSizeMb ?? MAX_DOCUMENT_SIZE_MB;

    // Check file type
    if (!(allowedTypes as readonly string[]).includes(file.type)) {
        const typeList = [...allowedTypes].map((t) => t.split("/")[1]).join(", ");
        return {
            valid: false,
            error: `Invalid file type. Allowed types: ${typeList}`,
        };
    }

    // Check file size
    if (!isFileSizeValid(file.size, maxSizeMb)) {
        return {
            valid: false,
            error: `File too large. Maximum size: ${maxSizeMb}MB`,
        };
    }

    return { valid: true };
}

/**
 * Get human-readable file size
 */
export function formatFileSize(bytes: number): string {
    if (bytes < 1024) return `${bytes} B`;
    if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
    return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
}
