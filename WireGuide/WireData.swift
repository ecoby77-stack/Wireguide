import Foundation

/// Hardcoded copper THHN ampacity and circuit quick-match data for WireGuide.
/// Ampacity values are from NEC 2023 Table 310.16 (copper), ambient 30 °C,
/// not more than three current-carrying conductors.
/// THHN is a 90 °C conductor type; usable ampacity is still limited by
/// termination temperature ratings (NEC 110.14(C)) and, for 14–10 AWG,
/// by the small-conductor rules in NEC 240.4(D).

struct WireAmpacity: Identifiable, Hashable {
    let id: String
    let size: String
    let ampacity60C: Int
    let ampacity75C: Int
    let ampacity90C: Int
}

struct QuickMatch: Identifiable, Hashable {
    let id: String
    let use: String
    let wire: String
    let breaker: String
}

struct SmallConductorLimit: Identifiable, Hashable {
    let id: String
    let size: String
    let maxOvercurrent: Int
}

enum WireData {
    /// Copper ampacity from NEC 2023 Table 310.16, 14 AWG through 4/0 AWG.
    static let copperTHHN: [WireAmpacity] = [
        WireAmpacity(id: "14", size: "14 AWG", ampacity60C: 15, ampacity75C: 20, ampacity90C: 25),
        WireAmpacity(id: "12", size: "12 AWG", ampacity60C: 20, ampacity75C: 25, ampacity90C: 30),
        WireAmpacity(id: "10", size: "10 AWG", ampacity60C: 30, ampacity75C: 35, ampacity90C: 40),
        WireAmpacity(id: "8", size: "8 AWG", ampacity60C: 40, ampacity75C: 50, ampacity90C: 55),
        WireAmpacity(id: "6", size: "6 AWG", ampacity60C: 55, ampacity75C: 65, ampacity90C: 75),
        WireAmpacity(id: "4", size: "4 AWG", ampacity60C: 70, ampacity75C: 85, ampacity90C: 95),
        WireAmpacity(id: "3", size: "3 AWG", ampacity60C: 85, ampacity75C: 100, ampacity90C: 115),
        WireAmpacity(id: "2", size: "2 AWG", ampacity60C: 95, ampacity75C: 115, ampacity90C: 130),
        WireAmpacity(id: "1", size: "1 AWG", ampacity60C: 110, ampacity75C: 130, ampacity90C: 145),
        WireAmpacity(id: "1/0", size: "1/0 AWG", ampacity60C: 125, ampacity75C: 150, ampacity90C: 170),
        WireAmpacity(id: "2/0", size: "2/0 AWG", ampacity60C: 145, ampacity75C: 175, ampacity90C: 195),
        WireAmpacity(id: "3/0", size: "3/0 AWG", ampacity60C: 165, ampacity75C: 200, ampacity90C: 225),
        WireAmpacity(id: "4/0", size: "4/0 AWG", ampacity60C: 195, ampacity75C: 230, ampacity90C: 260),
    ]

    /// NEC 240.4(D) small-conductor overcurrent protection limits (copper).
    static let smallConductorLimits: [SmallConductorLimit] = [
        SmallConductorLimit(id: "14", size: "14 AWG", maxOvercurrent: 15),
        SmallConductorLimit(id: "12", size: "12 AWG", maxOvercurrent: 20),
        SmallConductorLimit(id: "10", size: "10 AWG", maxOvercurrent: 30),
    ]

    /// Everyday circuit-to-wire-to-breaker quick matches (job-site rules of thumb).
    static let quickMatches: [QuickMatch] = [
        QuickMatch(id: "lighting", use: "Lighting & receptacles", wire: "14 AWG", breaker: "15 A"),
        QuickMatch(id: "kitchen", use: "Kitchen & bath", wire: "12 AWG", breaker: "20 A"),
        QuickMatch(id: "dryer", use: "Dryer", wire: "10 AWG", breaker: "30 A"),
        QuickMatch(id: "range", use: "Range", wire: "8 AWG", breaker: "40–50 A"),
        QuickMatch(id: "water-heater", use: "Water heater", wire: "10 AWG", breaker: "30 A"),
        QuickMatch(id: "ev", use: "EV charger", wire: "8–6 AWG", breaker: "40–60 A"),
        QuickMatch(id: "subpanel-100", use: "Subpanel feeder", wire: "2 AWG", breaker: "100 A"),
        QuickMatch(id: "subpanel-200", use: "Subpanel feeder", wire: "2/0 AWG", breaker: "200 A"),
    ]

    static let disclaimer =
        "For reference only. Verify with the 2025 CEC and your local building department."

    static let smallConductorFootnote =
        "NEC 240.4(D): overcurrent protection shall not exceed 15 A for 14 AWG, 20 A for 12 AWG, or 30 A for 10 AWG copper (unless otherwise permitted)."
}
