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
        newWindow.styleMask = [.borderless]
        newWindow.isOpaque = false
        newWindow.backgroundColor = .clear
        newWindow.hasShadow = true
        newWindow.level = .floating

        // Center window manually
        if let screenFrame = NSScreen.main?.frame {
            let popupSize = NSSize(width: 400, height: 450)
            let origin = NSPoint(
                x: (screenFrame.width - popupSize.width) / 2,
                y: (screenFrame.height - popupSize.height) / 2
            )
            newWindow.setFrame(NSRect(origin: origin, size: popupSize), display: true)
        }

        newWindow.makeKeyAndOrderFront(nil)
        window = newWindow
    }

    func closePopup() {
        window?.close()
        window = nil
    }
}
