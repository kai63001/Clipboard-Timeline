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
    @State private var searchText: String = ""
    @State private var snippets: [ClipboardSnippet] = []

    var filteredSnippets: [ClipboardSnippet] {
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

            Divider()
            Spacer()
        }
    }
}

//#Preview {
//    ContentView()
//}
