import Foundation
import SwiftUI
#if canImport(ActivityKit) && os(iOS)
import ActivityKit
#endif

/// One active package as the widgets and the share extension see it. The app writes these after every check.
struct Snap: Codable, Hashable {
    var number: String
    var name: String
    var status: String
    var eta: Date?
    var delivered: Bool
}

/// Code the app, the widgets and the share extension all compile.
enum Shared {
    static let group = "group.com.nulljosh.carton"
    static let accent = Color(red: 0x8c / 255, green: 0x5a / 255, blue: 0x2c / 255)  // kraft deep, brand/tokens.css
    static var defaults: UserDefaults { UserDefaults(suiteName: group) ?? .standard }

    /// A bare number or a pasted tracking link, as the UPS number it holds.
    static func trackingNumber(in text: String) -> String? {
        text.range(of: "1Z[0-9A-Z]{16}", options: [.regularExpression, .caseInsensitive]).map { String(text[$0]).uppercased() }
    }

    /// Whole calendar days from `now` to `date`.
    static func days(to date: Date, from now: Date = .now) -> Int {
        let c = Calendar.current
        return c.dateComponents([.day], from: c.startOfDay(for: now), to: c.startOfDay(for: date)).day ?? 0
    }

    /// The package arriving soonest that hasn't arrived: what the countdown widget shows.
    static func next(_ snaps: [Snap], now: Date = .now) -> Snap? {
        snaps.filter { s in !s.delivered && s.eta.map { days(to: $0, from: now) >= 0 } == true }
            .min { $0.eta! < $1.eta! }
    }

    static func loadSnaps() -> [Snap] {
        defaults.data(forKey: "snaps").flatMap { try? JSONDecoder().decode([Snap].self, from: $0) } ?? []
    }

    static func saveSnaps(_ snaps: [Snap]) {
        defaults.set(try? JSONEncoder().encode(snaps), forKey: "snaps")
    }

    /// Numbers the share extension picked up, waiting for the app to add them.
    static var pending: [String] {
        get { defaults.stringArray(forKey: "pending") ?? [] }
        set { defaults.set(newValue, forKey: "pending") }
    }
}

#if canImport(ActivityKit) && os(iOS)
/// The Lock Screen and Dynamic Island countdown for one package.
struct DeliveryAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var status: String
        var eta: Date?
        var delivered: Bool
    }
    var number: String
    var name: String
}
#endif
