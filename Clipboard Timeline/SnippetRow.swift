//
//  SnippetRow.swift
//  Clipboard Timeline
//
//  Created by romeo on 30/5/2568 BE.
//

import SwiftUI

struct SnippetRow: View {
    let snippet: ClipboardSnippet
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(snippet.content)
                .lineLimit(2)
            HStack {
                Image(systemName: "app.fill")
                    .foregroundColor(.secondary)
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
