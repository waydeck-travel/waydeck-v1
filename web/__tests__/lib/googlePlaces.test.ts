import { describe, it, expect } from "vitest";
import { matchAirportCode } from "@/lib/googlePlaces";

describe("matchAirportCode", () => {
    it("returns IATA code for exact airport name match", () => {
        expect(matchAirportCode("Suvarnabhumi Airport")).toBe("BKK");
    });

    it("returns IATA code for partial match (lowercase)", () => {
        expect(matchAirportCode("heathrow airport")).toBe("LHR");
    });

    it("returns IATA code for Mumbai airport", () => {
        expect(matchAirportCode("Chhatrapati Shivaji Maharaj International Airport")).toBe("BOM");
    });

    it("returns IATA code for Delhi airport", () => {
        expect(matchAirportCode("Indira Gandhi International Airport")).toBe("DEL");
    });

    it("returns IATA code for Singapore airport", () => {
        expect(matchAirportCode("Changi Airport")).toBe("SIN");
    });

    it("returns undefined for unknown airport", () => {
        expect(matchAirportCode("Some Unknown Regional Airport")).toBeUndefined();
    });

    it("returns undefined for empty string", () => {
        expect(matchAirportCode("")).toBeUndefined();
    });

    it("handles airports with partial name match", () => {
        // Should match "dubai international airport"
        expect(matchAirportCode("Dubai International")).toBe("DXB");
    });
});
