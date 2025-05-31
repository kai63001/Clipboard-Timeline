import SwiftUI
import AppKit

struct SnippetRowPopUp: View {
    let snippet: ClipboardSnippet
    let onCopy: () -> Void

    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 8) {
            Image(nsImage: appIcon(for: snippet.appBundleId))
                .resizable()
                .frame(width: 20, height: 20)
                .cornerRadius(4)

            Text(snippet.content)
                .lineLimit(1)
                .truncationMode(.tail)

            Spacer()

            Text(snippet.timestamp, style: .time)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isHovering ? Color.gray.opacity(0.2) : Color.clear)
                .animation(.easeInOut(duration: 0.2), value: isHovering)
        )
        .onHover { hovering in
            withAnimation {
                isHovering = hovering
            }
        }
        .onTapGesture {
            copyToPasteboard(snippet.content)
            onCopy()
        }
    }

    private func appIcon(for bundleId: String) -> NSImage {
        let workspace = NSWorkspace.shared
        if let appURL = workspace.urlForApplication(withBundleIdentifier: bundleId) {
            return workspace.icon(forFile: appURL.path)
        } else {
            return NSImage(named: NSImage.applicationIconName) ?? NSImage()
        }
    }

    private func copyToPasteboard(_ content: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(content, forType: .string)
    }
}
