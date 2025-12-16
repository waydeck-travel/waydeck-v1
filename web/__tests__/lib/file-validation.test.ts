import { describe, it, expect } from "vitest";
import {
    isAllowedMimeType,
    isFileSizeValid,
    validateFile,
    formatFileSize,
    ALLOWED_DOCUMENT_TYPES,
    MAX_DOCUMENT_SIZE_MB,
} from "@/lib/file-validation";

describe("isAllowedMimeType", () => {
    it.each(ALLOWED_DOCUMENT_TYPES)("returns true for %s", (mimeType) => {
        expect(isAllowedMimeType(mimeType)).toBe(true);
    });

    it.each([
        "application/javascript",
        "text/html",
        "application/octet-stream",
        "image/gif",
        "video/mp4",
    ])("returns false for %s", (mimeType) => {
        expect(isAllowedMimeType(mimeType)).toBe(false);
    });
});

describe("isFileSizeValid", () => {
    it("returns true for file under limit", () => {
        const fiveMb = 5 * 1024 * 1024;
        expect(isFileSizeValid(fiveMb, MAX_DOCUMENT_SIZE_MB)).toBe(true);
    });

    it("returns true for file at limit", () => {
        const tenMb = 10 * 1024 * 1024;
        expect(isFileSizeValid(tenMb, MAX_DOCUMENT_SIZE_MB)).toBe(true);
    });

    it("returns false for file over limit", () => {
        const elevenMb = 11 * 1024 * 1024;
        expect(isFileSizeValid(elevenMb, MAX_DOCUMENT_SIZE_MB)).toBe(false);
    });

    it("returns true for empty file", () => {
        expect(isFileSizeValid(0, MAX_DOCUMENT_SIZE_MB)).toBe(true);
    });
});

describe("validateFile", () => {
    const createMockFile = (
        name: string,
        type: string,
        sizeBytes: number
    ): File => {
        const blob = new Blob(["x".repeat(sizeBytes)], { type });
        return new File([blob], name, { type });
    };

    it("returns valid for allowed PDF", () => {
        const file = createMockFile("doc.pdf", "application/pdf", 1024);
        expect(validateFile(file).valid).toBe(true);
    });

    it("returns valid for allowed JPEG", () => {
        const file = createMockFile("image.jpg", "image/jpeg", 1024);
        expect(validateFile(file).valid).toBe(true);
    });

    it("returns valid for allowed PNG", () => {
        const file = createMockFile("image.png", "image/png", 1024);
        expect(validateFile(file).valid).toBe(true);
    });

    it("returns valid for allowed WebP", () => {
        const file = createMockFile("image.webp", "image/webp", 1024);
        expect(validateFile(file).valid).toBe(true);
    });

    it("returns invalid for disallowed type", () => {
        const file = createMockFile("script.js", "application/javascript", 1024);
        const result = validateFile(file);
        expect(result.valid).toBe(false);
        expect(result.error).toContain("Invalid file type");
    });

    it("returns invalid for file too large", () => {
        const file = createMockFile("large.pdf", "application/pdf", 15 * 1024 * 1024);
        const result = validateFile(file);
        expect(result.valid).toBe(false);
        expect(result.error).toContain("File too large");
    });

    it("respects custom size limit", () => {
        const file = createMockFile("doc.pdf", "application/pdf", 3 * 1024 * 1024);
        const result = validateFile(file, { maxSizeMb: 2 });
        expect(result.valid).toBe(false);
        expect(result.error).toContain("Maximum size: 2MB");
    });
});

describe("formatFileSize", () => {
    it("formats bytes", () => {
        expect(formatFileSize(512)).toBe("512 B");
    });

    it("formats kilobytes", () => {
        expect(formatFileSize(2048)).toBe("2.0 KB");
    });

    it("formats megabytes", () => {
        expect(formatFileSize(5 * 1024 * 1024)).toBe("5.0 MB");
    });

    it("formats partial megabytes", () => {
        expect(formatFileSize(2.5 * 1024 * 1024)).toBe("2.5 MB");
    });
});
