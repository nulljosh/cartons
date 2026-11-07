import SwiftUI
import UIKit
import UniformTypeIdentifiers

/// Share a UPS email, link or text to Cartons. The number waits in the App Group until Cartons next opens and adds it.
final class ShareViewController: UIViewController {
    private let model = ShareModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        let host = UIHostingController(rootView: ShareView(model: model) { [weak self] in
            self?.extensionContext?.completeRequest(returningItems: nil)
        })
        addChild(host)
        host.view.frame = view.bounds
        host.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(host.view)
        host.didMove(toParent: self)
        Task { await read() }
    }

    /// Looks through everything shared (the link, the page title, the selected text) for a UPS number.
    private func read() async {
        var text = ""
        for item in extensionContext?.inputItems as? [NSExtensionItem] ?? [] {
            text += " " + (item.attributedContentText?.string ?? "")
            for provider in item.attachments ?? [] {
                for type in [UTType.url, .plainText] where provider.hasItemConformingToTypeIdentifier(type.identifier) {
                    let value = try? await provider.loadItem(forTypeIdentifier: type.identifier)
                    if let url = value as? URL { text += " " + url.absoluteString }
                    if let s = value as? String { text += " " + s }
                }
            }
        }
        guard let number = Shared.trackingNumber(in: text) else { model.state = .none; return }
        if !Shared.pending.contains(number) { Shared.pending.append(number) }
        model.state = .added(number)
    }
}

@MainActor
final class ShareModel: ObservableObject {
    enum State { case reading, added(String), none }
    @Published var state = State.reading
}

private struct ShareView: View {
    @ObservedObject var model: ShareModel
    let done: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            switch model.state {
            case .reading:
                ProgressView().accessibilityLabel("Reading")
            case .added(let number):
                Image(systemName: "shippingbox.fill").font(.system(size: 44)).foregroundStyle(Shared.accent).accessibilityHidden(true)
                Text("Added to Cartons").font(.title3.bold())
                Text(number).font(.subheadline.monospaced()).foregroundStyle(.secondary)
                Text("It shows up with its countdown the next time you open Cartons.")
                    .font(.footnote).foregroundStyle(.secondary).multilineTextAlignment(.center)
            case .none:
                Image(systemName: "questionmark.circle").font(.system(size: 44)).foregroundStyle(.secondary).accessibilityHidden(true)
                Text("No UPS number here").font(.title3.bold())
                Text("Share a UPS email, tracking link or a number that starts with 1Z.")
                    .font(.footnote).foregroundStyle(.secondary).multilineTextAlignment(.center)
            }
            Button(action: done) {
                Text("Done").font(.headline).foregroundStyle(.white).frame(maxWidth: .infinity, minHeight: 48)
                    .background(Capsule().fill(Shared.accent))
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}
