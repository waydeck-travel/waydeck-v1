import { describe, it, expect } from "vitest";
import {
    formatDate,
    formatShortDate,
    formatDateRange,
    formatTime,
    formatDateTime,
    isTripActive,
    getDurationDays,
    formatRelativeTime,
} from "@/lib/dates";

describe("formatDate", () => {
    it("formats a date string correctly", () => {
        expect(formatDate("2025-12-01")).toBe("1 Dec 2025");
    });

    it("formats a Date object correctly", () => {
        expect(formatDate(new Date(2025, 11, 15))).toBe("15 Dec 2025");
    });

    it("returns empty string for null", () => {
        expect(formatDate(null)).toBe("");
    });

    it("returns empty string for undefined", () => {
        expect(formatDate(undefined)).toBe("");
    });
});

describe("formatShortDate", () => {
    it("formats date without year", () => {
        expect(formatShortDate("2025-12-01")).toBe("1 Dec");
    });

    it("returns empty string for null", () => {
        expect(formatShortDate(null)).toBe("");
    });
});

describe("formatDateRange", () => {
    it("shows range when both dates provided", () => {
        expect(formatDateRange("2025-12-01", "2025-12-15")).toBe(
            "1 Dec – 15 Dec 2025"
        );
    });

    it("shows from when only start date", () => {
        expect(formatDateRange("2025-12-01", null)).toBe("From 1 Dec 2025");
    });

    it("shows until when only end date", () => {
        expect(formatDateRange(null, "2025-12-15")).toBe("Until 15 Dec 2025");
    });

    it("shows dates not set when both null", () => {
        expect(formatDateRange(null, null)).toBe("Dates not set");
    });
});

describe("formatTime", () => {
    it("formats time from ISO string", () => {
        expect(formatTime("2025-12-01T14:30:00Z")).toMatch(/\d{2}:\d{2}/);
    });

    it("returns empty string for null", () => {
        expect(formatTime(null)).toBe("");
    });
});

describe("formatDateTime", () => {
    it("formats date and time together", () => {
        const result = formatDateTime("2025-12-01T14:30:00Z");
        expect(result).toMatch(/Dec 2025 at/);
    });

    it("returns empty string for null", () => {
        expect(formatDateTime(null)).toBe("");
    });
});

describe("isTripActive", () => {
    it("returns true when today is within trip dates", () => {
        const today = new Date();
        const start = new Date(today);
        start.setDate(start.getDate() - 1);
        const end = new Date(today);
        end.setDate(end.getDate() + 1);

        expect(
            isTripActive(start.toISOString().split("T")[0], end.toISOString().split("T")[0])
        ).toBe(true);
    });

    it("returns false when trip is in future", () => {
        const future = new Date();
        future.setDate(future.getDate() + 30);
        const futureEnd = new Date(future);
        futureEnd.setDate(futureEnd.getDate() + 7);

        expect(
            isTripActive(
                future.toISOString().split("T")[0],
                futureEnd.toISOString().split("T")[0]
            )
        ).toBe(false);
    });

    it("returns false when trip is in past", () => {
        const past = new Date();
        past.setDate(past.getDate() - 30);
        const pastEnd = new Date(past);
        pastEnd.setDate(pastEnd.getDate() + 7);

        expect(
            isTripActive(
                past.toISOString().split("T")[0],
                pastEnd.toISOString().split("T")[0]
            )
        ).toBe(false);
    });

    it("returns false when dates are null", () => {
        expect(isTripActive(null, null)).toBe(false);
    });
});

describe("getDurationDays", () => {
    it("calculates duration correctly for same day", () => {
        expect(getDurationDays("2025-12-01", "2025-12-01")).toBe(1);
    });

    it("calculates duration correctly for multi-day trip", () => {
        expect(getDurationDays("2025-12-01", "2025-12-15")).toBe(15);
    });

    it("returns null when dates are null", () => {
        expect(getDurationDays(null, null)).toBe(null);
    });

    it("returns null when start is null", () => {
        expect(getDurationDays(null, "2025-12-15")).toBe(null);
    });

    it("returns null when end is null", () => {
        expect(getDurationDays("2025-12-01", null)).toBe(null);
    });
});

describe("formatRelativeTime", () => {
    it("returns a relative time string", () => {
        const result = formatRelativeTime(new Date());
        expect(result).toContain("ago");
    });
});
