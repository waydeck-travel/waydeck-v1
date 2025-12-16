import { format, formatDistanceToNow, isAfter, isBefore, isToday, parseISO } from "date-fns";

export function formatDate(date: string | Date | null | undefined): string {
    if (!date) return "";
    const d = typeof date === "string" ? parseISO(date) : date;
    return format(d, "d MMM yyyy");
}

export function formatShortDate(date: string | Date | null | undefined): string {
    if (!date) return "";
    const d = typeof date === "string" ? parseISO(date) : date;
    return format(d, "d MMM");
}

export function formatDateRange(
    startDate: string | null | undefined,
    endDate: string | null | undefined
): string {
    if (!startDate && !endDate) return "Dates not set";
    if (startDate && !endDate) return `From ${formatDate(startDate)}`;
    if (!startDate && endDate) return `Until ${formatDate(endDate)}`;
    return `${formatShortDate(startDate)} – ${formatDate(endDate)}`;
}

export function formatRelativeTime(date: string | Date): string {
    const d = typeof date === "string" ? parseISO(date) : date;
    return formatDistanceToNow(d, { addSuffix: true });
}

export function formatTime(time: string | Date | null | undefined): string {
    if (!time) return "";
    const d = typeof time === "string" ? parseISO(time) : time;
    return format(d, "HH:mm");
}

export function formatDateTime(date: string | Date | null | undefined): string {
    if (!date) return "";
    const d = typeof date === "string" ? parseISO(date) : date;
    return format(d, "d MMM yyyy 'at' HH:mm");
}

export function isTripActive(
    startDate: string | null | undefined,
    endDate: string | null | undefined
): boolean {
    if (!startDate || !endDate) return false;
    const today = new Date();
    const start = parseISO(startDate);
    const end = parseISO(endDate);
    return (isAfter(today, start) || isToday(start)) && (isBefore(today, end) || isToday(end));
}

export function getDurationDays(
    startDate: string | null | undefined,
    endDate: string | null | undefined
): number | null {
    if (!startDate || !endDate) return null;
    const start = parseISO(startDate);
    const end = parseISO(endDate);
    const diffTime = Math.abs(end.getTime() - start.getTime());
    return Math.ceil(diffTime / (1000 * 60 * 60 * 24)) + 1;
}
