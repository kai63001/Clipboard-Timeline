//
//  ClipboardMonitor.swift
//  Clipboard Timeline
//
//  Created by romeo on 30/5/2568 BE.
//

import AppKit

class ClipboardMonitor {
    private let pasteboard = NSPasteboard.general
    private var changeCount: Int

    init() {
        self.changeCount = pasteboard.changeCount
        startMonitoring()
    }

    private func startMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkForChanges()
        }
    }

    private func checkForChanges() {
        if pasteboard.changeCount != changeCount {
            changeCount = pasteboard.changeCount
            if let copiedString = pasteboard.string(forType: .string) {
                let appName = NSWorkspace.shared.frontmostApplication?.localizedName ?? "Unknown"
                let bundleID = NSWorkspace.shared.frontmostApplication?.bundleIdentifier ?? "Unknown"
                print("bundle ID \(bundleID)")
                ClipboardDatabase.shared.addClipboardItem(content: copiedString, appName: appName, appBundleId: bundleID)
                print("New clipboard text: \(copiedString) from \(appName)")
            }
        }
    }
}
