//
//  SnippetRow.swift
//  Clipboard Timeline
//
//  Created by romeo on 30/5/2568 BE.
//

import SwiftUI
import AppKit

struct SnippetRow: View {
    let snippet: ClipboardSnippet
    
    private func appIcon(for appIconBundleId: String) -> NSImage {
            let workspace = NSWorkspace.shared
            if let appURL = workspace.urlForApplication(withBundleIdentifier: appIconBundleId) {
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
            }
        }
        .padding(.vertical, 4)
    }
}
