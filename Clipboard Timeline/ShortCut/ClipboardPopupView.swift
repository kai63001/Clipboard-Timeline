import SwiftUI

struct ClipboardPopupView: View {
    @State private var snippets: [ClipboardSnippet] = []
    let onSelect: (ClipboardSnippet) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Text("📋 Clipboard History")
                .font(.headline)
                .padding(.bottom, 4)

            List {
                ForEach(Array(snippets.prefix(10).enumerated()), id: \.1.id) { (index, snippet) in
                    HStack {
                        Text("\(index + 1).")
                            .bold()
                        Text(snippet.content.prefix(50))
                            .lineLimit(1)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onSelect(snippet)
                    }
                }
            }
            .frame(width: 400, height: 300)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .onAppear {
            loadData()
        }
        .onAppear {
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                handleKeyEvent(event)
                return event
            }
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

    private func handleKeyEvent(_ event: NSEvent) {
        guard event.modifierFlags.contains(.command) else { return }
        let keyIndex: Int?
        switch event.keyCode {
        case 18: keyIndex = 0 // 1
        case 19: keyIndex = 1 // 2
        case 20: keyIndex = 2 // 3
        case 21: keyIndex = 3 // 4
        case 23: keyIndex = 4 // 5
        case 22: keyIndex = 5 // 6
        case 26: keyIndex = 6 // 7
        case 28: keyIndex = 7 // 8
        case 25: keyIndex = 8 // 9
        default: keyIndex = nil
        }
        if let index = keyIndex, index < snippets.count {
            onSelect(snippets[index])
        }
    }

    private func parseTimestamp(_ timestampString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: timestampString) ?? Date()
    }
}
