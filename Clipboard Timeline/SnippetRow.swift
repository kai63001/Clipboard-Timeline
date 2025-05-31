//
//  SnippetRow.swift
//  Clipboard Timeline
//
//  Created by romeo on 30/5/2568 BE.
//

import AppKit
import SwiftUI

struct SnippetRow: View {
    let snippet: ClipboardSnippet
    @ObservedObject var database = ClipboardDatabase.shared
    @State private var isHovering = false

    private func appIcon(for appIconBundleId: String) -> NSImage {
        let workspace = NSWorkspace.shared
        if let appURL = workspace.urlForApplication(
            withBundleIdentifier: appIconBundleId
        ) {
            return workspace.icon(forFile: appURL.path)
        } else {
            return NSImage(named: NSImage.applicationIconName) ?? NSImage()
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(snippet.content)
                .lineLimit(2)
            HStack {
                Image(nsImage: appIcon(for: snippet.appBundleId))
                    .resizable()
                    .frame(width: 16, height: 16)
                Text(snippet.appName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(snippet.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)

                if isHovering {
                    Button(action: {
                        database.deleteClipboardItem(id: snippet.id)
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
        }
        .padding(5)
        .background(isHovering ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1))
        .cornerRadius(5)
        .onHover { hovering in
            withAnimation {
                isHovering = hovering
            }
        }
    }
}
