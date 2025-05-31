import AppKit
import SwiftUI

class ClipboardPopupManager {
    static let shared = ClipboardPopupManager()
    private var window: NSWindow?

    func showPopup() {
        if window != nil {
            closePopup()
            return
        }
        let popup = ClipboardPopupView(onSelect: { snippet in
            ClipboardActionHandler.pasteSnippet(snippet)
            self.closePopup()
        })
        let hosting = NSHostingController(rootView: popup)
        let newWindow = NSWindow(contentViewController: hosting)
        newWindow.styleMask = [.titled, .fullSizeContentView]
        newWindow.isOpaque = false
        newWindow.backgroundColor = NSColor.clear
        newWindow.level = .floating
        newWindow.center()
        newWindow.makeKeyAndOrderFront(nil)
        newWindow.makeFirstResponder(hosting)
        window = newWindow
    }

    func closePopup() {
        window?.close()
        window = nil
    }
}
