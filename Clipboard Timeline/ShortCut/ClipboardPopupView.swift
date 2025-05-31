import SwiftUI
import AppKit

struct ClipboardPopupView: View {
    @State private var snippets: [ClipboardSnippet] = []
    let onSelect: (ClipboardSnippet) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("📋 Clipboard History")
                .font(.headline)
                .padding(.bottom, 4)

            ForEach(Array(snippets.prefix(10).enumerated()), id: \.1.id) { (index, snippet) in
                SnippetRowPopUp(snippet: snippet) {
                    onSelect(snippet)
                }
            }
        }
        .padding()
        .frame(width: 400, height: 450)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.windowBackgroundColor))
                .shadow(radius: 10)
        )
        .padding()
        .onAppear {
            loadData()
        }
    }

    private func loadData() {
        let items = ClipboardDatabase.shared.fetchClipboardItems()
        snippets = items.map {
            ClipboardSnippet(
                id: $0.id,
                content: $0.content,
                appName: $0.appName ?? "Unknown",
                appBundleId: $0.appBundleId ?? "",
                timestamp: parseTimestamp($0.timestamp)
            )
        }
    }

    private func parseTimestamp(_ timestampString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: timestampString) ?? Date()
    }
}
