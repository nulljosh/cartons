import ActivityKit
import SwiftUI
import WidgetKit

@main
struct CartonsWidgets: WidgetBundle {
    var body: some Widget {
        Countdown()
        DeliveryActivity()
    }
}

// MARK: Countdown widget: the next package to arrive, on the Home Screen and the Lock Screen

struct Entry: TimelineEntry {
    let date: Date
    let next: Snap?
    let onTheWay: Int
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> Entry { Entry(date: .now, next: nil, onTheWay: 0) }

    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) { completion(entry(at: .now)) }

    /// One entry now and one at each of the next seven midnights, so the day count ticks down without the app.
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let today = Calendar.current.startOfDay(for: .now)
        let midnights = (1...7).compactMap { Calendar.current.date(byAdding: .day, value: $0, to: today) }
        completion(Timeline(entries: [entry(at: .now)] + midnights.map(entry), policy: .atEnd))
    }

    private func entry(at date: Date) -> Entry {
        let snaps = Shared.loadSnaps()
        return Entry(date: date, next: Shared.next(snaps, now: date), onTheWay: snaps.filter { !$0.delivered }.count)
    }
}

struct Countdown: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Countdown", provider: Provider()) { CountdownView(entry: $0) }
            .configurationDisplayName("Countdown")
            .description("Days until your next package arrives.")
            .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

private func title(_ s: Snap) -> String { s.name.isEmpty ? String(localized: "Your package") : s.name }

private func dayWord(_ d: Int) -> String {
    d <= 0 ? String(localized: "Today") : d == 1 ? String(localized: "Tomorrow") : String(localized: "\(d) days")
}

struct CountdownView: View {
    @Environment(\.widgetFamily) private var family
    let entry: Entry

    var body: some View {
        content.containerBackground(for: .widget) { Color(.systemBackground) }
    }

    @ViewBuilder private var content: some View {
        let d = entry.next.flatMap { $0.eta }.map { Shared.days(to: $0, from: entry.date) }
        switch family {
        case .accessoryInline:
            if let n = entry.next, let d { Text("\(title(n)): \(dayWord(d))") } else { Text("No packages on the way") }
        case .accessoryCircular:
            VStack(spacing: 0) {
                Image(systemName: "shippingbox").font(.caption)
                Text(d.map { $0 <= 0 ? String(localized: "Now") : "\($0)" } ?? "-").font(.title3.bold())
            }
            .accessibilityLabel(d.map(dayWord) ?? String(localized: "No packages on the way"))
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                if let n = entry.next, let d {
                    Text(dayWord(d)).font(.headline)
                    Text(title(n)).font(.caption).lineLimit(1)
                    if !n.status.isEmpty { Text(n.status).font(.caption2).foregroundStyle(.secondary).lineLimit(1) }
                } else {
                    Text("No packages on the way").font(.caption)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        default:
            home(d)
        }
    }

    @ViewBuilder private func home(_ d: Int?) -> some View {
        if let n = entry.next, let d {
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Label("Cartons", systemImage: "shippingbox.fill").font(.caption.weight(.semibold)).foregroundStyle(Shared.accent)
                    Spacer(minLength: 0)
                    Text(d <= 0 ? String(localized: "Today") : "\(d)")
                        .font(.system(size: d <= 0 ? 34 : 48, weight: .bold, design: .rounded)).foregroundStyle(Shared.accent)
                        .minimumScaleFactor(0.6)
                    Text(d <= 0 ? String(localized: "arriving") : d == 1 ? String(localized: "day to go") : String(localized: "days to go"))
                        .font(.caption).foregroundStyle(.secondary)
                    Text(title(n)).font(.subheadline.weight(.semibold)).lineLimit(1)
                }
                if family == .systemMedium {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 6) {
                        if !n.status.isEmpty { Text(n.status).font(.subheadline) }
                        if let eta = n.eta { Text(eta, format: .dateTime.weekday(.wide).month().day()).font(.caption).foregroundStyle(.secondary) }
                        if entry.onTheWay > 1 {
                            Text("\(entry.onTheWay) on the way").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .accessibilityElement(children: .combine)
        } else {
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: "shippingbox").font(.title2).foregroundStyle(Shared.accent)
                Text("No packages on the way").font(.subheadline.weight(.semibold))
                Text("Add a UPS number in Cartons.").font(.caption).foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }
}

// MARK: Live Activity: one followed package on the Lock Screen and in the Dynamic Island

struct DeliveryActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DeliveryAttributes.self) { context in
            LockScreen(name: context.attributes.name, state: context.state)
                .padding(16)
                .activityBackgroundTint(Color(.systemBackground))
        } dynamicIsland: { context in
            let s = context.state
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label(context.attributes.name.isEmpty ? String(localized: "Package") : context.attributes.name, systemImage: "shippingbox.fill")
                        .font(.subheadline.weight(.semibold)).lineLimit(1)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(short(s)).font(.title3.bold()).foregroundStyle(Shared.accent)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(s.status).font(.caption).foregroundStyle(.secondary)
                }
            } compactLeading: {
                Image(systemName: "shippingbox.fill").foregroundStyle(Shared.accent)
            } compactTrailing: {
                Text(short(s)).font(.caption.bold())
            } minimal: {
                Image(systemName: s.delivered ? "checkmark" : "shippingbox.fill").foregroundStyle(Shared.accent)
            }
        }
    }
}

/// "3d", "Today" or "Here": fits the compact Dynamic Island.
private func short(_ s: DeliveryAttributes.ContentState) -> String {
    if s.delivered { return String(localized: "Here") }
    guard let eta = s.eta else { return "-" }
    let d = Shared.days(to: eta)
    return d <= 0 ? String(localized: "Today") : "\(d)d"
}

private struct LockScreen: View {
    let name: String
    let state: DeliveryAttributes.ContentState

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: state.delivered ? "checkmark.circle.fill" : "shippingbox.fill")
                .font(.title).foregroundStyle(Shared.accent)
            VStack(alignment: .leading, spacing: 2) {
                Text(name.isEmpty ? String(localized: "Your package") : name).font(.headline).lineLimit(1)
                Text(state.delivered ? String(localized: "Delivered") : state.status).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            if !state.delivered, let eta = state.eta {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(dayWord(Shared.days(to: eta))).font(.title3.bold()).foregroundStyle(Shared.accent)
                    Text(eta, format: .dateTime.weekday(.wide)).font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}
