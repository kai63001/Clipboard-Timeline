import AppKit

class ClipboardActionHandler {
    static func pasteSnippet(_ snippet: ClipboardSnippet) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(snippet.content, forType: .string)

        // ส่ง Cmd+V
        let src = CGEventSource(stateID: .hidSystemState)
        let keyVDown = CGEvent(keyboardEventSource: src, virtualKey: 9, keyDown: true)
        keyVDown?.flags = .maskCommand
        let keyVUp = CGEvent(keyboardEventSource: src, virtualKey: 9, keyDown: false)
        keyVUp?.flags = .maskCommand
        keyVDown?.post(tap: .cghidEventTap)
        keyVUp?.post(tap: .cghidEventTap)
    }
}
