//
//  ContentView.swift
//  Clipboard Timeline
//
//  Created by romeo on 30/5/2568 BE.
//

import SwiftUI

struct ClipboardSnippet: Identifiable {
    let id: UUID
    let content: String
    let appName: String
    let timestamp: Date
}

struct ContentView: View {
    @ObservedObject var database = ClipboardDatabase.shared
    @State private var searchText: String = ""

    var filteredSnippets: [ClipboardSnippet] {
        let snippets = database.clipboardItems.map { item in
            ClipboardSnippet(
                id: UUID(),
                content: item.content,
                appName: item.appName ?? "Unknown",
                timestamp: parseTimestamp(item.timestamp)
            )
        }
        if searchText.isEmpty {
            return snippets
        } else {
            return snippets.filter {
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        VStack {
            HStack {
                Text("📋 Clipboard Timeline")
                    .font(.headline)
                Spacer()
                Button(action: { /* Show settings */  }) {
                    Image(systemName: "gearshape")
                }
                .buttonStyle(BorderlessButtonStyle())
            }.padding()
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal)
            Divider()

            // Snippet List
            List {
                Section(
                    header: Text("Today").font(.caption).foregroundColor(
                        .secondary
                    )
                ) {
                    ForEach(filteredSnippets) { snippet in
                        SnippetRow(snippet: snippet)
                    }
                }
            }
            .listStyle(PlainListStyle())
            .frame(minHeight: 300)

            Spacer()
        }.onAppear {
            database.clipboardItems = database.fetchClipboardItems()
        }
    }
    
    private func parseTimestamp(_ timestampString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return formatter.date(from: timestampString) ?? Date()
    }
    
}
//
//#Preview {
//    ContentView()
//}
