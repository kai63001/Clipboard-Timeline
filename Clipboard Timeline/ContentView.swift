//
//  ContentView.swift
//  Clipboard Timeline
//
//  Created by romeo on 30/5/2568 BE.
//

import SwiftUI

struct ClipboardSnippet: Identifiable {
    let id: Int64
    let content: String
    let appName: String
    let appBundleId: String
    let timestamp: Date
}

struct ContentView: View {
    @ObservedObject var database = ClipboardDatabase.shared
    @State private var searchText: String = ""
    @State private var isExpanded = false
    @State private var selected = "Today"
    let items = ["Today", "Yesterday", "All"]

    var filteredSnippets: [ClipboardSnippet] {
        let snippets = database.clipboardItems.map { item in
            ClipboardSnippet(
                id: item.id,
                content: item.content,
                appName: item.appName ?? "Unknown",
                appBundleId: item.appBundleId ?? "Unknown",
                timestamp: parseTimestamp(item.timestamp)
            )
        }
        return snippets
    }

    //    var yesterdayClipboardSnippets: [ClipboardSnippet] {
    //        let snippets = database.fetchClipboardItems(type: "yesterday").map {
    //            ClipboardSnippet(
    //                id: $0.id,
    //                content: $0.content,
    //                appName: $0.appName ?? "Unknown",
    //                appBundleId: $0.appBundleId ?? "Unknown",
    //                timestamp: parseTimestamp($0.timestamp)
    //            )
    //        }
    //
    //        return snippets
    //    }

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
                VStack(alignment: .leading, spacing: 0) {
                    Button(action: {
                        withAnimation { isExpanded.toggle() }
                    }) {
                        HStack(spacing: 0) {
                            Text("\(selected) (16)")
                                .foregroundColor(.primary)

                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 0)
                        .padding(.vertical, 0)
                        .fixedSize()
                    }
                    .buttonStyle(.plain)
                    if isExpanded {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(items, id: \.self) { item in
                                Button(action: {
                                    selected = item
                                    isExpanded = false
                                    loadClipboardItems()
                                }) {
                                    Text(item)
                                        .foregroundColor(.primary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 4)
                                        .background(
                                            Color(NSColor.windowBackgroundColor)
                                        )
                                        .cornerRadius(4)
                                        .frame(
                                            maxWidth: .infinity,
                                            alignment: .leading
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }

                Section() {
                    ForEach(filteredSnippets) { snippet in
                        SnippetRow(snippet: snippet)
                    }
                }
                //                Section( header: Text("Yesterday").font(.caption).foregroundColor(
                //                        .secondary
                //                    )
                //                ) {
                //                    ForEach(yesterdayClipboardSnippets) { snippet in
                //                        SnippetRow(snippet: snippet)
                //                    }
                //                }
            }
            .listStyle(SidebarListStyle())
            .frame(minHeight: 300)

            Spacer()
        }.onAppear {
            loadClipboardItems()
        }
    }

    private func loadClipboardItems() {
        let type = selected.lowercased()
        database.clipboardItems = database.fetchClipboardItems(type: type)
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
